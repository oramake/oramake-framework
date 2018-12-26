create or replace package body pkg_DynamicSqlCache is
/* package body: pkg_DynamicSqlCache::body */



/* group: Типы */

/* itype: IntegerStringT
  Тип для сохранения значения типа integer в виде строки.
  Из-за технических ограничений на ключ ассоциативных массивов данный тип
  используется вместо integer.
*/
subtype IntegerStringT is varchar2(38);

/* itype: CursorCacheKeyT
  Тип ключа для кэша открытых курсоров.
  В качестве ключа используется Id курсора в виде строки.
*/
subtype CursorCacheKeyT is IntegerStringT;

/* itype: CursorByLastUsedKeyT
  Тип ключа для списка кэшированных курсоров по номеру последнего использования.
  В качестве ключа используется номер последнего использования, дополненный
  слева ведущими нулями ( для обеспечения сортировки в соответствии с числовым
  значением).
*/
subtype CursorByLastUsedKeyT is IntegerStringT;

/* itype: CursorCacheItemT
  Тип элемента для кэша открытых курсоров.
*/
type CursorCacheItemT is record
(

  -- Id кэша, к которому относится курсор
  cacheId integer

  -- Текст SQL, разобранный в курсоре
  , sqlText clob

  -- Id курсора
  , cursorId integer

  -- Признак текущего использования курсора ( курсор был возвращен функцией
  -- <getCursor> и после этого не была вызвана функция <freeCursor>)
  , isUsed boolean

  -- Число использований курсора
  , usedCount integer

  -- Порядковый номер последнего использования ( в виде строки)
  , lastUsedKey CursorByLastUsedKeyT
);

/* itype: CursorCacheT
  Тип кэша открытых курсоров.
*/
type CursorCacheT is table of CursorCacheItemT index by CursorCacheKeyT;

/* itype: CursorByLastUsedT
  Тип для упорядоченного по номеру последнего использования списка курсоров
  кэша. Обеспечивает эффективный поиск давно используемых курсоров.
*/
type CursorByLastUsedT is table of
  CursorCacheKeyT
index by
  CursorByLastUsedKeyT
;

/* itype: CursorCacheKeyColT
  Тип для списка ключей элементов в кэше куроров.
*/
type CursorCacheKeyColT is table of
  CursorCacheKeyT
index by
  CursorCacheKeyT
;

/* itype: CursorBySqlLengthItemT
  Тип элемента для индексирования курсоров кэша под длине SQL.
  Ключом коллекции является длина SQL в виде строки.
*/
type CursorBySqlLengthItemT is table of
  CursorCacheKeyColT
index by
  pls_integer
;

/* itype: CursorBySqlLengthT
  Тип для индексирования курсоров кэша по длине соответствующего им текста SQL.
  Используется для эффективного поиска курсоров по тексту SQL.
  Ключом коллекции является Id кэша в виде строки.
*/
type CursorBySqlLengthT is table of
  CursorBySqlLengthItemT
index by
  IntegerStringT
;



/* group: Константы */

/* iconst: MaxCachedCursor_Default
  Максимальное число кэшируемых курсоров ( значение по умолчанию).
  Если 0, то для каждого запроса открывается новый курсор.
*/
MaxCachedCursor_Default constant pls_integer := 80;



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_DynamicSqlCache'
);

/* ivar: maxCachedCursor
  Максимальное число кэшируемых курсоров.
*/
maxCachedCursor pls_integer := MaxCachedCursor_Default;

/* ivar: lastCacheId
  Id последнего созданного в сессии кэша курсоров.
*/
lastCacheId integer;

/* ivar: cursorCacheUsedNumber
  Порядковый номер использования кэша курсоров в сессии.
*/
cursorCacheUsedNumber integer;

/* ivar: cursorCache
  Кэш открытых курсоров.
*/
cursorCache CursorCacheT;

/* ivar: cursorByLastUsed
  Упорядоченный по номеру последнего использования спискок курсоров кэша.
*/
cursorByLastUsed CursorByLastUsedT;

/* ivar: cursorBySqlLength
  Списки курсоров по длине соответствующего им текста SQL.
*/
cursorBySqlLength CursorBySqlLengthT;



/* group: Функции */



/* group: Реализация интерфейса <dyn_cursor_cache_t> */


/* func: getNextCacheId
  Возвращает Id для нового объекта кэша ( уникальный в рамках сессии).
*/
function getNextCacheId
return integer
is
begin
  lastCacheId := coalesce( lastCacheId, 0) + 1;
  return lastCacheId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при возврате Id для нового объекта кэша курсоров.'
      )
    , true
  );
end getNextCacheId;

/* proc: closeCursor
  Закрывает курсор.

  Параметры:
  cursorId                    - Id курсора
                                ( значение устанавливается в null)
  cacheId                     - Id объекта кэша курсоров
                                ( если указано, то выполняется проверка
                                принадлежности курсора указанному кэшу в случае
                                наличия курсора в кэше)
*/
procedure closeCursor(
  cursorId in out integer
  , cacheId integer := null
)
is

  -- Ключ курсора в кэше
  cursorKey CursorCacheKeyT;

begin
  cursorKey := to_char( cursorId);
  if cursorCache.exists( cursorKey) then
    if nullif( cacheId, cursorCache( cursorKey).cacheId) is not null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Курсор относится к другому кэшу ('
          || ' cacheId=' || cursorCache( cursorKey).cacheId
          || ').'
      );
    end if;
    cursorByLastUsed.delete( cursorCache( cursorKey).lastUsedKey);
    cursorBySqlLength
      ( to_char( cursorCache( cursorKey).cacheId))
      ( length( cursorCache( cursorKey).sqlText))
      .delete( cursorKey)
    ;
    cursorCache.delete( cursorKey);
  end if;
  dbms_sql.close_cursor( cursorId);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при закрытии курсора ('
        || ' cursorId=' || cursorId
        || ', cacheId=' || cacheId
        || ').'
      )
    , true
  );
end closeCursor;

/* ifunc: closeUnusedCursor
  Пытается закрыть указанное число неиспользуемых курсоров.

  Параметры:
  cursorCount                 - число курсоров для закрытия

  Возврат:
  истина в случае удачного выполнения, иначе ложь.
*/
function closeUnusedCursor(
  cursorCount pls_integer
)
return boolean
is

  -- Число закрытых курсоров
  nClosed pls_integer := 0;

  -- Ключ текущего элемента в коллекции по последнему использованию
  lastUsedKey CursorByLastUsedKeyT;

  -- Ключ текущего курсора
  cursorKey CursorCacheKeyT;

  -- Id курсора для закрытия
  cursorId integer;

begin
  lastUsedKey := cursorByLastUsed.first();
  while lastUsedKey is not null and nClosed < cursorCount loop
    cursorKey := cursorByLastUsed( lastUsedKey);

    -- переходим до возможного удаления элемента
    lastUsedKey := cursorByLastUsed.next( lastUsedKey);

    if not cursorCache( cursorKey).isUsed then
      cursorId := cursorCache( cursorKey).cursorId;
      closeCursor( cursorId);
      nClosed := nClosed + 1;
    end if;
  end loop;
  return nClosed = cursorCount;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при попытке закрытия неиспользуемых курсоров ('
        || ' cursorCount=' || cursorCount
        || ').'
      )
    , true
  );
end closeUnusedCursor;

/* func: getCursor
  Возвращает курсор для выполнения указанного динамического SQL.

  Параметры:
  cacheId                     - Id объекта кэша курсоров
  sqlText                     - текст SQL для выполнения в курсоре
  isSave                      - допустимость сохранения курсора в кэше
                                в случае создания нового курсора
                                ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  Id открытого курсора из пакета dbms_sql, в котором был выполнен разбор
  указаного текста SQL ( null если в sqlText передан null)
*/
function getCursor(
  cacheId integer
  , sqlText clob
  , isSave integer := null
)
return integer
is

  -- Id курсора
  cursorId integer;

  -- Id кэша в виде строки
  cacheIdString IntegerStringT;

  -- Длина текста SQL
  sqlLength pls_integer;

  -- Возможность сохранения нового курсора в кэше
  isAllowSave boolean :=
    coalesce( isSave, 1) != 0
    and maxCachedCursor > 0
  ;



  /*
    Устанавливает новое значение последнего использования курсора.
  */
  procedure setLastUsed(
    lastUsedKey in out nocopy CursorByLastUsedKeyT
    , cursorKey CursorCacheKeyT
  )
  is
  begin
    if lastUsedKey is not null then
      cursorByLastUsed.delete( lastUsedKey);
    end if;
    cursorCacheUsedNumber := coalesce( cursorCacheUsedNumber, 0) + 1;
    lastUsedKey := to_char( cursorCacheUsedNumber);
    cursorByLastUsed( lastUsedKey) := cursorKey;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при обновлении значения последнего использоваия курсора.'
        )
      , true
    );
  end setLastUsed;



  /*
    Ищет подходящий курсор в кэше.
  */
  procedure findCursor
  is



    /*
      Ищет подходящий курсор среди указанных в коллекции.
    */
    procedure find(
      keyCol CursorCacheKeyColT
    )
    is

      -- Ключ проверяемого курсора
      cursorKey CursorCacheKeyT := keyCol.first();

    -- find
    begin
      while cursorKey is not null loop
        if cursorCache( cursorKey).sqlText = sqlText then
          if cursorCache( cursorKey).isUsed then
            logger.debug(
              'Ignore already used cursor from cache'
              || ' ( cursorId=' || cursorCache( cursorKey).cursorId || ').'
            );

            -- Запрещаем сохранение нового курсора в кэше, т.к. такой курсор уже
            -- есть
            isAllowSave := false;
          else
            cursorCache( cursorKey).isUsed := true;
            cursorCache( cursorKey).usedCount :=
              cursorCache( cursorKey).usedCount + 1
            ;
            setLastUsed(
              lastUsedKey => cursorCache( cursorKey).lastUsedKey
              , cursorKey => cursorKey
            );
            cursorId := cursorCache( cursorKey).cursorId;
          end if;

          -- Завершаем поиск, т.к. в кэш не добавляются курсоры с идентичным
          -- SQL
          exit;
        end if;
        cursorKey := keyCol.next( cursorKey);
      end loop;
    end find;



  -- findCursor
  begin
    if cursorBySqlLength.exists( cacheIdString)
        and cursorBySqlLength( cacheIdString).exists( sqlLength)
        then
      find( cursorBySqlLength( cacheIdString)( sqlLength));
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при поиске курсора в кэше.'
        )
      , true
    );
  end findCursor;



  /*
    Создает новый курсор.
  */
  procedure createCursor
  is
  begin

    -- Открываем курсор
    cursorId := dbms_sql.open_cursor();

    -- Парсим текст запроса
    dbms_sql.parse( cursorId, sqlText, dbms_sql.native);

    logger.trace(
      'createCursor: cursorId=' || cursorId
      || ', sqlText=' || substr( sqlText, 1, 50) || '...'
    );
  exception when others then
    if cursorId is not null then
      dbms_sql.close_cursor( cursorId);
    end if;
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при создании курсора.'
        )
      , true
    );
  end createCursor;



  /*
    Сохраняет курсор в кэше.
  */
  procedure saveCursor
  is

    -- Ключ курсора в кэше
    cursorKey CursorCacheKeyT;

    -- Данные по курсору для сохранения в кэше
    ci CursorCacheItemT;

    -- Пустые ассоциативные массивы для инициализации кэша
    cbslItem CursorBySqlLengthItemT;
    cckCol CursorCacheKeyColT;

  begin
    cursorKey := to_char( cursorId);

    ci.cacheId      := cacheId;
    ci.sqlText      := sqlText;
    ci.cursorId     := cursorId;
    ci.isUsed       := true;
    ci.usedCount    := 1;
    setLastUsed(
      lastUsedKey => ci.lastUsedKey
      , cursorKey => cursorKey
    );

    cursorCache( cursorKey) := ci;
    if not cursorBySqlLength.exists( cacheIdString) then
      cursorBySqlLength( cacheIdString) := cbslItem;
    end if;
    if not cursorBySqlLength( cacheIdString).exists( sqlLength) then
      cursorBySqlLength( cacheIdString)( sqlLength) := cckCol;
    end if;
    cursorBySqlLength( cacheIdString)( sqlLength)( cursorKey) := cursorKey;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при сохранении курсора в кэше.'
        )
      , true
    );
  end saveCursor;



-- getCursor
begin
  if sqlText is not null then
    cacheIdString := to_char( cacheId);
    sqlLength := length( sqlText);
    findCursor();

    -- Создаем новый курсор, если не был найден подходящий курсор в кэше
    if cursorId is null then
      createCursor();

      -- Пытаемся сохранить курсор в кэше
      if isAllowSave then
        if cursorCache.count() < maxCachedCursor
            or closeUnusedCursor(
                cursorCache.count() - maxCachedCursor + 1
              )
            then
          saveCursor();
        end if;
      end if;
    end if;
  end if;
  return cursorId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении курсора для выполнения динамического SQL ('
        || ' cacheId=' || cacheId
        || ', isSave=' || isSave
        || ').'
      )
    , true
  );
end getCursor;

/* proc: freeCursor
  Освобождает курсор после завершения выполнения в нем SQL.

  Параметры:
  cacheId                     - Id объекта кэша курсоров
  cursorId                    - Id курсора
                                ( значение устанавливается в null)

  Замечания:
  - если курсор не был сохранен в кэше функцией <getCursor>, то он
    закрывается иначе курсор сохраняется для повторного использования;
*/
procedure freeCursor(
  cacheId integer
  , cursorId in out integer
)
is

  -- Ключ курсора в кэше
  cursorKey CursorCacheKeyT;

begin
  cursorKey := to_char( cursorId);
  if cursorCache.exists( cursorKey) then
    if cursorCache( cursorKey).cacheId != cacheId then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Курсор относится к другому кэшу ('
          || ' cacheId=' || cursorCache( cursorKey).cacheId
          || ').'
      );
    end if;
    cursorCache( cursorKey).isUsed := false;
  else
    closeCursor(
      cursorId  => cursorId
      , cacheId => cacheId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при освобождении курсора ('
        || ' cacheId=' || cacheId
        || ', cursorId=' || cursorId
        || ').'
      )
    , true
  );
end freeCursor;

/* proc: clear
  Очишает указанный кэш курсоров, закрывая все относящиеся к нему курсоры.

  Параметры:
  cacheId                     - Id объекта кэша курсоров
*/
procedure clear(
  cacheId integer
)
is

  -- Id кэша в виде строки
  cacheIdString IntegerStringT;

  -- Длина текста SQL
  sqlLength pls_integer;

  -- Ключ текущего курсора
  cursorKey CursorCacheKeyT;

  -- Id курсора для закрытия
  cursorId integer;

  -- Число закрытых курсоров
  nClosed pls_integer := 0;

begin
  cacheIdString := to_char( cacheId);
  if cursorBySqlLength.exists( cacheIdString) then
    sqlLength := cursorBySqlLength( cacheIdString).first();
    while sqlLength is not null loop
      cursorKey := cursorBySqlLength( cacheIdString)( sqlLength).first();
      while cursorKey is not null loop
        cursorId := cursorCache( cursorKey).cursorId;

        -- переходим до удаления элемента
        cursorKey := cursorBySqlLength( cacheIdString)( sqlLength)
          .next( cursorKey)
        ;
        closeCursor( cursorId);
        nClosed := nClosed + 1;
      end loop;
      sqlLength := cursorBySqlLength( cacheIdString).next( sqlLength);
    end loop;
    cursorBySqlLength.delete( cacheIdString);
  end if;
  logger.debug(
    'clear: close cached cursor: ' || nClosed
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при очистке кэша курсоров ('
        || ' cacheId=' || cacheId
        || ').'
      )
    , true
  );
end clear;

/* func: getCursorUsedCount
  Возвращает число использований курсора.

  Параметры:
  cacheId                     - Id объекта кэша курсоров
  cursorId                    - Id курсора

  Возврат:
  число использований курсора ( число вызовов функции <getCursor>, в результате
  которых был возвращен курсор), 0 в случае отсутствия курсора с указанным Id
  в кэше.
*/
function getCursorUsedCount(
  cacheId integer
  , cursorId integer
)
return integer
is

  -- Ключ курсора в кэше
  cursorKey CursorCacheKeyT;

  usedCount integer := 0;

begin
  cursorKey := to_char( cursorId);
  if cursorCache.exists( cursorKey) then
    if cursorCache( cursorKey).cacheId != cacheId then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Курсор относится к другому кэшу ('
          || ' cacheId=' || cursorCache( cursorKey).cacheId
          || ').'
      );
    end if;
    usedCount := cursorCache( cursorKey).usedCount;
  end if;
  return usedCount;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении числа использований курсора ('
        || ' cacheId=' || cacheId
        || ', cursorId=' || cursorId
        || ').'
      )
    , true
  );
end getCursorUsedCount;



/* group: Отладочные функции */

/* proc: setMaxCachedCursor
  Устанавливает максимальное число кэшируемых курсоров ( суммарно по всем
  объектам кэша).


  Параметры:
  cursorCount                 - число курсоров
*/
procedure setMaxCachedCursor(
  cursorCount pls_integer
)
is
begin
  if cursorCount < 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Указано некорректное число курсоров.'
    );
  end if;
  maxCachedCursor := cursorCount;
  if cursorCache.count() > maxCachedCursor then
    if not closeUnusedCursor( cursorCache.count() - maxCachedCursor) then
      logger.debug(
        'setMaxCachedCursor: used cursors exceed limit: ' || cursorCache.count()
      );
    end if;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при установке максимального числа кэшируемых курсоров ('
        || ' cursorCount=' || cursorCount
        ||').'
      )
    , true
  );
end setMaxCachedCursor;

/* func: getCachedCursorCount
  Возвращает число кэшированных курсоров ( суммарно по всем объектам кэша).

  Возврат:
  число курсоров.
*/
function getCachedCursorCount
return integer
is
begin
  return cursorCache.count();
end getCachedCursorCount;

end pkg_DynamicSqlCache;
/
