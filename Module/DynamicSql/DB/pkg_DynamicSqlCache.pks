create or replace package pkg_DynamicSqlCache
authid current_user
is
/* package: pkg_DynamicSqlCache
  Реализация функционала по кэшированию курсоров пакета dbms_sql.

  В связи с возможным выполнением разбора переданного текста SQL, выполнение
  производится с правами вызывающего ( authid current_user).

  SVN root: Oracle/Module/DynamicSql
*/



/* group: Константы */

/* const: Module_Name
  Имя модуля, к которому относится пакет.
*/
Module_Name constant varchar2(20) := 'DynamicSql';



/* group: Функции */



/* group: Реализация интерфейса <dyn_cursor_cache_t> */

/* pfunc: getNextCacheId
  Возвращает Id для нового объекта кэша ( уникальный в рамках сессии).

  ( <body::getNextCacheId>)
*/
function getNextCacheId
return integer;

/* pproc: closeCursor
  Закрывает курсор.

  Параметры:
  cursorId                    - Id курсора
                                ( значение устанавливается в null)
  cacheId                     - Id объекта кэша курсоров
                                ( если указано, то выполняется проверка
                                принадлежности курсора указанному кэшу в случае
                                наличия курсора в кэше)

  ( <body::closeCursor>)
*/
procedure closeCursor(
  cursorId in out integer
  , cacheId integer := null
);

/* pfunc: getCursor
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

  ( <body::getCursor>)
*/
function getCursor(
  cacheId integer
  , sqlText varchar2
  , isSave integer := null
)
return integer;

/* pproc: freeCursor
  Освобождает курсор после завершения выполнения в нем SQL.

  Параметры:
  cacheId                     - Id объекта кэша курсоров
  cursorId                    - Id курсора
                                ( значение устанавливается в null)

  Замечания:
  - если курсор не был сохранен в кэше функцией <getCursor>, то он
    закрывается иначе курсор сохраняется для повторного использования;

  ( <body::freeCursor>)
*/
procedure freeCursor(
  cacheId integer
  , cursorId in out integer
);

/* pproc: clear
  Очишает указанный кэш курсоров, закрывая все относящиеся к нему курсоры.

  Параметры:
  cacheId                     - Id объекта кэша курсоров

  ( <body::clear>)
*/
procedure clear(
  cacheId integer
);

/* pfunc: getCursorUsedCount
  Возвращает число использований курсора.

  Параметры:
  cacheId                     - Id объекта кэша курсоров
  cursorId                    - Id курсора

  Возврат:
  число использований курсора ( число вызовов функции <getCursor>, в результате
  которых был возвращен курсор), 0 в случае отсутствия курсора с указанным Id
  в кэше.

  ( <body::getCursorUsedCount>)
*/
function getCursorUsedCount(
  cacheId integer
  , cursorId integer
)
return integer;



/* group: Отладочные функции */

/* pproc: setMaxCachedCursor
  Устанавливает максимальное число кэшируемых курсоров ( суммарно по всем
  объектам кэша).


  Параметры:
  cursorCount                 - число курсоров

  ( <body::setMaxCachedCursor>)
*/
procedure setMaxCachedCursor(
  cursorCount pls_integer
);

/* pfunc: getCachedCursorCount
  Возвращает число кэшированных курсоров ( суммарно по всем объектам кэша).

  Возврат:
  число курсоров.

  ( <body::getCachedCursorCount>)
*/
function getCachedCursorCount
return integer;

end pkg_DynamicSqlCache;
/
