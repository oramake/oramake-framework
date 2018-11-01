create or replace package body pkg_LoggingInternal is
/* package body: pkg_LoggingInternal::body */



/* group: Типы */

/* itype: IdStrT
  Представление числового идентификатора (целого числа) в виде строки (тип).
*/
subtype IdStrT is varchar2(39);

/* itype: FindModuleStringT
  Строка для определения Id модуля (тип).
  Максимальная длина должна быть не меньше, чем у поля module_name таблицы
  <lg_log>.
*/
subtype FindModuleStringT is varchar2(128);

/* itype: LogRecT
  Запись таблицы лога (тип).
*/
subtype LogRecT is lg_log%rowtype;

/* itype: TLoggerUid
  Уникальный идентификатор логера.
  Индетификатор соответствует маске ".[<loggerName>.]", где loggerName
  предстваляет собой регистрозависимое иерархическое имя логера, в котором
  точка используется в качестве разделителя ( при этом начальные/конечные точки
  и две точки подряд недопустимы). Для корневого логера используется
  идентификатор ".".
  Указанная схема обеспечивает правильную иерархическую последовательность
  логеров при сортировке по идентификатору и простую проверку наследования.
*/
subtype TLoggerUid is varchar2(250);

/* itype: TLogger
  Данные логера.
*/
type TLogger is record
(
  -- Имя модуля, которому относится логер (null для корневого логера)
  moduleName lg_log.module_name%type
  -- Имя объекта в модуле, которому относится логер (null для корневого логера)
  , objectName lg_log.object_name%type
  -- Id модуля, которому относится логер (если удалось определить)
  , moduleId integer
  -- Строка для определения moduleId
  , findModuleString FindModuleStringT
  -- Нужно попытаться определить moduleId
  -- (true - да, false - нет (была попытка), null - не требуется)
  , isNeedFindModuleId boolean
  -- Код назначенного уровня логирования
  , levelCode lg_level.level_code%type
  -- Признак аддитивности логера
  , additive boolean
  -- Uid родительского логера
  , parentUid TLoggerUid
);

/* itype: TColLogger
  Коллекция логеров.
*/
type TColLogger is table of TLogger index by TLoggerUid;

/* itype: TColLevelOrder
  Порядковые значения для уровней логирования.
*/
type TColLevelOrder is table of lg_level.level_order%type
  index by lg_level.level_code%type
;

/* itype: SetLoggerModuleIdCacheT
  Кэш результатов определения Id модуля (тип).
*/
type SetLoggerModuleIdCacheT is table of integer index by FindModuleStringT;



/* group: Константы */

/* iconst: Root_LoggerUid
  Идентификатор корневого логера.
*/
Root_LoggerUid constant varchar2(1) := '.';



/* group: Переменные */

/* ivar: logger
  Внутренний логер пакета (инициализируется в процедуре <initialize>).
*/
logger lg_logger_t := null;

/* ivar: internalLoggerUid
  Идентификатор внутренного логера пакета (инициализируется в процедуре
  <initialize>).
*/
internalLoggerUid TLoggerUid := null;


/* ivar: isAccessOperatorFound
  Признак доступности модуля AccessOperator.
*/
isAccessOperatorFound boolean := null;

/* ivar : previousDebugTimeStamp
  Переменная для хранения последней даты вывода отадочного сообщения
*/
previousDebugTimeStamp timestamp := null;

/* ivar: forcedDestinationCode
  Переопределение назначения для вывода сообщений.
*/
forcedDestinationCode varchar2(10) := null;

/* ivar: colLogger
  Логеры.
*/
colLogger TColLogger;

/* ivar: colLevelOrder
  Порядковые значения для уровней логирования.
  Загружается при первом обращении к пакету.
*/
colLevelOrder TColLevelOrder;

/* ivar: lastParentLogId
  Значение поля parent_log_id последней вставленной в таблицу <lg_log>
  записи
*/
lastParentLogId integer := null;

/* ivar: lastSessionid
  Значение поля sessionid последней вставленной в таблицу <lg_log>
  записи
*/
lastSessionid number := null;

/* ivar: setLoggerModuleIdCache
  Кэш результатов определения Id модуля (тип).
*/
setLoggerModuleIdCache SetLoggerModuleIdCacheT;



/* group: Контекст выполнения */

/* itype: GetContextTypeCacheKeyT
  Тип ключа ассоциативного массива <GetContextTypeCacheT>.
  Формируется как "<moduleId>:<contextTypeShortName>".
*/
subtype GetContextTypeCacheKeyT is varchar2(100);

/* itype: GetContextTypeCacheItemT
  Тип элемента ассоциативного массива <GetContextTypeCacheT>.
*/
type GetContextTypeCacheItemT is record(
  context_type_id lg_context_type.context_type_id%type
  , nested_flag lg_context_type.nested_flag%type
);

/* itype: GetContextTypeCacheT
  Кэш результатов определения параметров типа контекста функцией
  <getContextType> (тип).
*/
type GetContextTypeCacheT is table of
  GetContextTypeCacheItemT
index by
  GetContextTypeCacheKeyT
;

/* ivar: getContextTypeCache
  Кэш результатов определения параметров типа контекста функцией
  <getContextType>.
*/
getContextTypeCache GetContextTypeCacheT;

/* itype: OpenContextColT
  Данные открытых контекстов выполнения (тип).
*/
type OpenContextColT is table of LogRecT index by IdStrT;

/* ivar: openContextCol
  Данные открытых контекстов выполнения.
  Строковый идентификатор записи лога открытия контекста (получаемый функцией
  <getIdStr>) является индексом коллекции.
*/
openContextCol OpenContextColT;

/* itype: NestedCtxIdsColT
  Строковые идентификаторы открытых вложенных контекстов выполнения (тип).
*/
type NestedCtxIdsColT is table of IdStrT;

/* ivar: nestedCtxIdsCol
  Строковые идентификаторы открытых вложенных контекстов выполнения.
  Уровень вложенности является индексом в коллекции.
*/
nestedCtxIdsCol NestedCtxIdsColT := NestedCtxIdsColT();

/* itype: MappedCtxIdsColT
  Строковые идентификаторы открытых ассоциативных (не вложенных) контекстов
  выполнения (тип).
*/
type MappedCtxIdsColT is table of IdStrT index by pls_integer;

/* ivar: mappedCtxIdsCol
  Строковые идентификаторы ассоциативных (не вложенных) контекстов выполнения.
  Id типа контекста (context_type_id) является индексом в коллекции.
*/
mappedCtxIdsCol MappedCtxIdsColT;

/* itype: HiddenContextListT
  Открытые контексты выполнения, записи по которым не были добавлены в таблицу
  лога.
*/
type HiddenContextListT is table of boolean index by IdStrT;

/* ivar: hiddenContextList
  Открытые контексты выполнения, записи по которым не были добавлены в таблицу
  лога.
  Строковый идентификатор контекста выполнения является индексом коллекции,
  признак вывода записи по открытию контекста через dbms_output является
  элементом коллекции.
*/
hiddenContextList HiddenContextListT;



/* group: Функции */



/* group: Вспомогательные функции */

/* ifunc: getIdStr
  Возвращает представление числового идентификатора (целого числа) в виде
  строки.

  Параметры:
  id                          - Идентификатор (числовой)

  Возврат:
  строка с идентификатором (типа <IdStrT>).

  Замечания:
  - строковое представление обеспечивает тот же порядок сортировки, что и
    числовое значение;
*/
function getIdStr(
  id integer
)
return varchar2
is
begin
  return
    to_char(
      id
      , case when id < 0 then
            's00000000000000000000000000000000000009'
        else
          'fm000000000000000000000000000000000000009'
        end
    )
  ;
end getIdStr;



/* group: Базовые функции */

/* ifunc: getLoggerUidByName
  Возвращает идентификатор по имени логера.

  Параметры:
  loggerName                  - имя логера ( null соответсвует корневому логеру)

  Возврат:
  - идентификатор логера, соответствующий имени
*/
function getLoggerUidByName(
  loggerName varchar2
)
return varchar2
is
begin
  if loggerName like '.%' or loggerName like '%.' or loggerName like '%..%'
      then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Некорректное имя логера'
        || ' (точка в начале/конце имени либо две точки подряд).'
    );
  end if;
  return
    case when loggerName is null then
      Root_LoggerUid
    else
      Root_LoggerUid || loggerName || '.'
    end;
end getLoggerUidByName;

/* ifunc: getLoggerEffectiveLevel
  Возвращает эффективный уровень логирования.
  В качестве эффективного уровня логирования берется назначенный
  уровень логирования самого логера, а в случае его отсутствия уровень
  ближайшего предка с назначенным уровнем.

  Параметры:
  loggerUid                   - идентификатор логера

  Возврат:
  - код уровня логирования
*/
function getLoggerEffectiveLevel(
  loggerUid varchar2
)
return varchar2
is

  -- Uid логгера с установленным уровнем
  lu TLoggerUid := loggerUid;

begin
  while colLogger( lu).levelCode is null and lu <> Root_LoggerUid loop
    lu := colLogger( lu).parentUid;
  end loop;
  return colLogger( lu).levelCode;
end getLoggerEffectiveLevel;

/* ifunc: isMessageEnabled
  Определяет, будет ли логироваться сообщение.

  Параметры:
  loggerUid                   - идентификатор логера
  levelCode                   - код уровня сообщения

  Возврат:
  - истина, если сообщение будет логироваться
*/
function isMessageEnabled(
  loggerUid varchar2
  , levelCode varchar2
)
return boolean
is
begin
  return
    colLevelOrder( levelCode) >=
      colLevelOrder( getLoggerEffectiveLevel( loggerUid))
  ;
end isMessageEnabled;

/* iproc: initialize
  Выполняет инициализацию при первом обращении к пакету.
*/
procedure initialize
is



  /*
    Загружает порядковые значения уровней логирования.
  */
  procedure loadLevelOrder is

    cursor curLevel is
      select
        lv.level_code
        , lv.level_order
      from
        lg_level lv
    ;

    type TColLevel is table of curLevel%rowtype;
    colLevel TColLevel;

    -- Индекс в коллекции
    i pls_integer;

  begin
    open curLevel;
    fetch curLevel bulk collect into colLevel;
    close curLevel;
    i := colLevel.first;
    while i is not null loop
      colLevelOrder( colLevel( i).level_code) := colLevel( i).level_order;
      i := colLevel.next( i);
    end loop;
  end loadLevelOrder;



  /*
    Создает корневой и внутренний логеры.
    После выполнения процедуры можно вызывать функции пакета, использующие
    внутренее логирование.
  */
  procedure createInitialLogger
  is

    -- Данные логера
    r TLogger;

    -- Имя внутреннего логера пакета
    loggerName varchar2(200);

  begin

    -- Добавляем корневой логер
    r.levelCode := pkg_Logging.Off_LevelCode;
    r.additive := null;
    r.parentUid := null;
    colLogger( Root_LoggerUid) := r;

    -- Добавляем внутренний логер
    r.moduleName := pkg_Logging.Module_Name;
    r.objectName := 'pkg_LoggingInternal';
    r.findModuleString := pkg_Logging.Module_InitialPath;
    r.isNeedFindModuleId := true;
    r.levelCode := null;
    r.additive := true;
    r.parentUid := Root_LoggerUid;
    loggerName := r.moduleName || '.' || r.objectName;
    internalLoggerUid := getLoggerUidByName( loggerName);
    colLogger( internalLoggerUid) := r;

    -- Инициализируем внутренний логер ( неявно вызывается getLoggerUid)
    logger := lg_logger_t.getLogger( loggerName);
  end createInitialLogger;



  /*
    Выполняет настройку логеров.
  */
  procedure configLogger is

    -- Настраиваемый логер
    lgr lg_logger_t;

  begin

    -- Устанавливаем специальный уровень логирования для модуля по умолчанию
    lgr := lg_logger_t.getLogger(
      moduleName          => pkg_Logging.Module_Name
      , findModuleString  => pkg_Logging.Module_InitialPath
    );
    lgr.setLevel( pkg_Logging.Info_LevelCode);

    -- Настраиваем корневой логер
    lgr := lg_logger_t.getRootLogger();
    lgr.setLevel(
      case when pkg_Common.isProduction = 1 then
        pkg_Logging.Info_LevelCode
      else
        pkg_Logging.Debug_LevelCode
      end
    );
  end configLogger;



-- initialize
begin

  -- Загружаем порядок уровней
  loadLevelOrder;

  -- Создаем начальные логеры (корневой и внутренний пакета)
  createInitialLogger;

  -- Настройка логеров
  configLogger;
end initialize;

/* iproc: setLoggerModuleId
  Пытается заполнить Id модуля, к которому относится логер
  (поле moduleId данных логера <TLogger>).

  Параметры:
  loggerUid                   - Идентификатор используемого логера
  raiseNotFoundFlag           - Выбрасывать ли исключение в случае отсутствия
                                записи (1 да , 0 нет (по умолчанию))
*/
procedure setLoggerModuleId(
  loggerUid varchar2
  , raiseNotFoundFlag integer := null
)
is

  findModuleString FindModuleStringT;

  moduleId integer;

begin
  if colLogger( loggerUid).isNeedFindModuleId then

    -- Делаем только одну попытку
    colLogger( loggerUid).isNeedFindModuleId := false;

    findModuleString := coalesce(
      colLogger( loggerUid).findModuleString
      , colLogger( loggerUid).moduleName
    );

    -- Трассировка после сброса isNeedFindModuleId чтобы избежать зацикливания
    -- внутренного логера
    logger.trace(
      'setLoggerModuleId: loggerUid="' || loggerUid || '"'
      || ', for: "' || findModuleString || '"'
    );

    if setLoggerModuleIdCache.exists( findModuleString) then
      moduleId := setLoggerModuleIdCache( findModuleString);
      logger.trace( 'setLoggerModuleId: cached moduleId=' || moduleId);
    else
      moduleId := pkg_ModuleInfo.getModuleId(
        findModuleString      => findModuleString
          -- Игнорировать если Id модуля не найден (другие исключения возможны)
        , raiseExceptionFlag  => coalesce( raiseNotFoundFlag, 0)
      );
      setLoggerModuleIdCache( findModuleString) := moduleId;
      logger.trace( 'setLoggerModuleId: found moduleId=' || moduleId);
    end if;

    colLogger( loggerUid).moduleId := moduleId;
  end if;

  if raiseNotFoundFlag = 1 and colLogger( loggerUid).moduleId is null then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Не удалось определить Id модуля ('
        || ' findModuleString="'
          || coalesce(
              colLogger( loggerUid).findModuleString
              , colLogger( loggerUid).moduleName
            )
          || '"'
        || ').'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении Id модуля для логера ('
        || ' loggerUid="' || loggerUid || '"'
        || ').'
      )
    , true
  );
end setLoggerModuleId;

/* ifunc: getLoggerModuleId
  Возвращает Id модуля, к которому относится логер, при невозможности
  определить Id модуля выбрасывает исключение.

  Параметры:
  loggerUid                   - Идентификатор используемого логера

  Возврат:
  Id модуля, к которому относится логер.
*/
function getLoggerModuleId(
  loggerUid varchar2
)
return integer
is
begin
  if loggerUid = Root_LoggerUid then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Невозможно определить Id модуля для корневого логера.'
    );
  end if;
  if colLogger( loggerUid).moduleId is null then
    setLoggerModuleId(
      loggerUid             => loggerUid
      , raiseNotFoundFlag   => 1
    );
  end if;
  return colLogger( loggerUid).moduleId;
end getLoggerModuleId;

/* iproc: getContextType
  Возвращает параметры типа контекста выполнения.

  Параметры:
  contextTypeId               - Id типа контекста
                                (возврат)
  nestedFlag                  - Флаг вложенного контекста (1 да, 0 нет)
                                (возврат)
  moduleId                    - Id модуля, к которому относится тип контекста
  contextTypeShortName        - Краткое наименование типа контекста
  raiseNotFoundFlag           - Выбрасывать ли исключение в случае отсутствия
                                записи (1 да ( по умолчанию), 0 нет)
*/
procedure getContextType(
  contextTypeId out integer
  , nestedFlag out integer
  , moduleId integer
  , contextTypeShortName varchar2
  , raiseNotFoundFlag integer := null
)
is

  ckey GetContextTypeCacheKeyT;
  citem GetContextTypeCacheItemT;

begin
  ckey := substr( moduleId || ':'  || contextTypeShortName, 1, 100);
  if not getContextTypeCache.exists( ckey) then
    select
      min( t.context_type_id)
      , min( t.nested_flag)
    into contextTypeId, nestedFlag
    from
      lg_context_type t
    where
      t.module_id = moduleId
      and t.context_type_short_name = contextTypeShortName
      and t.deleted = 0
    ;
    if contextTypeId is not null then
      citem.context_type_id := contextTypeId;
      citem.nested_flag := nestedFlag;
      getContextTypeCache( ckey) := citem;
    end if;
  else
    contextTypeId := getContextTypeCache( ckey).context_type_id;
    nestedFlag := getContextTypeCache( ckey).nested_flag;
  end if;
  if contextTypeId is null and coalesce( raiseNotFoundFlag, 1) != 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Тип контекста не найден.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении параметров типа контекста ('
        || ' moduleId=' || moduleId
        || ', contextTypeShortName="' || contextTypeShortName || '"'
        || ', raiseNotFoundFlag=' || raiseNotFoundFlag
        || ').'
      )
    , true
  );
end getContextType;



/* group: Использование модуля AccessOperator */

/* func: getCurrentOperatorId
  Возвращает Id текущего зарегистрированного оператора при доступности модуля
  AccessOperator.

  Возврат:
  Id текущего оператора либо null в случае недоступности модуля AccessOperator
  или отсутствии текущего зарегистрированного оператора.
*/
function getCurrentOperatorId
return integer
is

  -- Id текущего оператора
  operatorId integer := null;

begin
  if coalesce( isAccessOperatorFound, true) then
    execute immediate
      'begin :operatorId := pkg_Operator.getCurrentUserId; end;'
    using
      out operatorId
    ;
  end if;
  return operatorId;
exception when others then
  if isAccessOperatorFound is null
      and (
        -- Не проверяем точно текст сообщения, т.к. он зависит от настроек NLS
        SQLERRM like
          -- PLS-00201: identifier 'PKG_OPERATOR' must be declared
          '%PLS-00201: % ''PKG_OPERATOR'' %'
        or SQLERRM like
          -- PLS-00201: identifier 'PKG_OPERATOR.%' must be declared
          '%PLS-00201: % ''PKG_OPERATOR.%'' %'
        or SQLERRM like
          -- PLS-00904: insufficient privilege to access object %.PKG_OPERATOR%
          '%PLS-00904: %.PKG_OPERATOR%'
        or SQLERRM like
          -- ORA-06508: PL/SQL: could not find program unit being called:
          '%ORA-06508: PL/SQL: %:%'
      )
      then
    isAccessOperatorFound := false;
  end if;
  return null;
end getCurrentOperatorId;



/* group: Настройки логирования */

/* proc: setDestination
  Устанавливает единственное назначения для вывода.

  Параметры:
  destinationCode             - код назначения
*/
procedure setDestination(
  destinationCode varchar2
)
is
begin
  if destinationCode is not null
      and destinationCode not in (
        pkg_Logging.DbmsOutput_DestinationCode
        , pkg_Logging.Table_DestinationCode
      )
  then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Вывод по коду "' || destinationCode || '" не реализован.'
    );
  end if;
  forcedDestinationCode := destinationCode;
end setDestination;



/* group: Логирование сообщений */

/* ifunc: logDbOut
  Выводит сообщение через dbms_output.
  Строки сообщения, длина которых больше 255 символов, при выводе автоматически
  разбиваются на строки допустимого размера ( в связи ограничением dbms_output).

  Параметры:
  messageText                 - текст сообщения

  Замечания:
  - разбивка при выводе слишком длинных строк сообщения по возможности
    производится по символу новой строки ( 0x0A) либо перед пробелом;
*/
procedure logDbOut(
  messageText varchar2
)
is

  -- Максимальная длина вывода
  Max_OutputLength constant pls_integer:= 255;

  -- Длина строки
  len pls_integer := coalesce( length( messageText), 0);

  -- Стартовая позиция для текущего вывода
  i pls_integer := 1;

  -- Стартовая позиция для следующего вывода
  i2 pls_integer;

  -- Конечная позиция для текущего вывода ( не включая)
  k pls_integer := null;

begin
  loop
    i2 := len + 1;
    if i2 - i > Max_OutputLength then
      i2 := i + Max_OutputLength;

      -- Пытаемся разбить строку по символу новой строки
      k := instr( messageText, chr(10), i2 - len - 1);
      if k >= i then
        i2 := k + 1;
      else
        k := instr( messageText, ' ', i2 - len - 1);
        if k > i then
          i2 := k;
        else
          k := i2;
        end if;
      end if;
    elsif i > 1 then
      k := i2;
    end if;
    dbms_output.put_line(
      case when k is not null then
        substr( messageText, i, k - i)
      else
        messageText
      end
    );
    exit when i2 > len;
    i := i2;
  end loop;
end logDbOut;

/* ifunc: logDebugDbOut
  Выводит отладочное сообщение через dbms_output c указанием времени с
  точностью до милисекунд, а также вычисляет время в милисекундах с момента
  вывода предыдущего сообщения.

  Параметры:
  messageText                 - текст сообщения
*/
procedure logDebugDbOut(
  messageText varchar2
)
is

  -- Текущее время ( до милисекунд)
  curTime timestamp:= systimestamp;

  -- Интервал между последними сообщениями
  timeInterval interval day to second :=
    curTime - previousDebugTimeStamp;

begin
  logDbOut(
    substr( to_char( curTime), 10, 12) || ': '
    || lpad(
         coalesce(
           case when
             extract ( HOUR from timeInterval) = 0
           then
             to_char(
                extract( SECOND from timeInterval) * 1000
                + extract( MINUTE from timeInterval) * 60000
             )
           -- Если прошло больше часа показываем время в часах
           when
             timeInterval is not null
           then
             to_char(
               extract ( HOUR from timeInterval)
               + extract ( DAY from timeInterval) * 24
               , 'FM9999990D00'
               , 'NLS_NUMERIC_CHARACTERS = ''. '''
             ) || 'h.'
           end
           , ' '
         )
         , 5
       )
    || ': ' || messageText
  );

  -- Запоминаем время вывода сообщения
  previousDebugTimeStamp := curTime;
end logDebugDbOut;

/* iproc: fillCommonField
  Заполняет общие поля сообщения.

  Параметры:
  logRec                      - Данные записи лога
                                (модификация)
  levelCode                   - Код уровня сообщения
  messageText                 - Текст сообщения
  messageValue                - Целочисленное значение, связанное с сообщением
  messageLabel                - Строковое значение, связанное с сообщением
  loggerUid                   - Идентификатор логера
  disableDboutFlag            - Запрет вывода сообщений через dbms_output
                                (в т.ч. порождаемых сообщений об ошибках)
                                (1 да, 0 нет)
*/
procedure fillCommonField(
  logRec in out nocopy LogRecT
  , levelCode varchar2
  , messageText varchar2
  , messageValue integer
  , messageLabel varchar2
  , loggerUid varchar2
  , disableDboutFlag integer
)
is
begin
  logRec.level_code := levelCode;
  logRec.message_text := substr( messageText, 1, 4000);
  logRec.message_value := messageValue;
  logRec.message_label := substr( messageLabel, 1, 128);

  if loggerUid is not null then
    logRec.module_name := colLogger( loggerUid).moduleName;
    logRec.object_name := colLogger( loggerUid).objectName;
    if colLogger( loggerUid).isNeedFindModuleId then
      begin
        setLoggerModuleId( loggerUid => loggerUid);
      exception when others then
        logMessage(
          levelCode           => pkg_Logging.Error_LevelCode
          , messageText       => logger.getErrorStack()
          , loggerUid         => internalLoggerUid
          , disableDboutFlag  => disableDboutFlag
        );
      end;
    end if;
    logRec.module_id := colLogger( loggerUid).moduleId;
  end if;

  -- Поддержка совместимости с Scheduler
  logRec.parent_log_id := lastParentLogId;
  logRec.message_type_code :=
    case levelCode
      when pkg_Logging.Fatal_LevelCode then
        Error_MessageTypeCode
      when pkg_Logging.Error_LevelCode then
        Error_MessageTypeCode
      when pkg_Logging.Warn_LevelCode then
        Warning_MessageTypeCode
      when pkg_Logging.Info_LevelCode then
        Info_MessageTypeCode
      when pkg_Logging.Debug_LevelCode then
        Debug_MessageTypeCode
      when pkg_Logging.Trace_LevelCode then
        Debug_MessageTypeCode
    end
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при заполнении общих полей записи лога.'
    , true
  );
end fillCommonField;

/* iproc: prepareLogRow
  Заполняет служебные поля записи таблицы <lg_log> перед вставкой.

  Параметры:
  logRec                      - Данные записи таблицы <lg_log>
                                (модификация)
*/
procedure prepareLogRow(
  logRec in out nocopy lg_log%rowtype
)
is
begin
  if logRec.log_id is null then
    logRec.log_id := lg_log_seq.nextval;
    if logRec.open_context_flag in ( 1, -1)
          and logRec.open_context_log_id is null
        then
      logRec.open_context_log_id := logRec.log_id;
    end if;
  end if;
  if logRec.log_time is null then
    logRec.log_time := current_timestamp;
    if logRec.open_context_flag in ( 1, -1)
          and logRec.open_context_log_time is null
        then
      logRec.open_context_log_time := logRec.log_time;
    end if;
  end if;
  if logRec.operator_id is null then
    logRec.operator_id := getCurrentOperatorId();
  end if;

  if lastSessionid is null then
    lastSessionid := sys_context('USERENV','SESSIONID');
    if nullif( lastSessionid, 0) is null then
      lastSessionid := - logRec.log_id;
    end if;
  end if;
  logRec.sessionid := lastSessionid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при заполнении служебных полей записи.'
    , true
  );
end prepareLogRow;

/* ifunc: logTable
  Добавляет сообщение в таблицу лога.

  Параметры:
  logRec                         - Запись с сообщением
*/
procedure logTable(
  logRec in out nocopy LogRecT
)
is

  pragma autonomous_transaction;

begin
  if logRec.date_ins is null then
    logRec.date_ins := sysdate;
  end if;
  insert into
    lg_log
  values
    logRec
  ;
  commit;
  --dbms_output.put_line(
  --  'logTable: log_id=' || logRec.log_id || ', text: ' || logRec.message_text
  --);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при добавлении сообщения в таблицу лога ('
      || 'log_id=' || logRec.log_id
      || ', context_level=' || logRec.context_level
      || ', context_type_id=' || logRec.context_type_id
      || ', context_value_id=' || logRec.context_value_id
      || ', open_context_log_id=' || logRec.open_context_log_id
      || ', open_context_flag=' || logRec.open_context_flag
      || ', context_type_level=' || logRec.context_type_level
      || ', module_id=' || logRec.module_id
      || ', parent_log_id=' || logRec.parent_log_id
      || ').'
    , true
  );
end logTable;

/* iproc: outputMessage
  Выводит сообщение.

  Параметры:
  isDboutEnabled              - Признак вывода через dbms_output
  isTableEnabled              - Признак вывода в таблицу лога
*/
procedure outputMessage(
  logRec in out nocopy LogRecT
  , isDboutEnabled boolean
  , isTableEnabled boolean
)
is
begin
  if isTableEnabled then
    logTable( logRec => logRec);
  end if;
  if isDboutEnabled then
    begin
      logDebugDbOut(
        rpad( logRec.level_code, 5) || ': ' || logRec.message_text
      );
    exception when others then
      logMessage(
        levelCode             => pkg_Logging.Error_LevelCode
        , messageText         =>
            'Ошибка вывода через dbms_output:'
            || chr(10) || logger.getErrorStack()
            || chr(10) || '(логируемое сообщение:'
            || ' levelCode="' || logRec.level_code || '"'
            || ', messageText="' || logRec.message_text || '").'
        , loggerUid           => internalLoggerUid
        , disableDboutFlag    => 1
      );
    end;
  end if;
end outputMessage;

/* proc: logMessage
  Логирует сообщение.

  Параметры:
  levelCode                   - Код уровня сообщения
  messageText                 - Текст сообщения
  messageValue                - Целочисленное значение, связанное с сообщением
                                (по умолчанию отсутствует)
  messageLabel                - Строковое значение, связанное с сообщением
                                (по умолчанию отсутствует)
  contextTypeShortName        - Краткое наименование типа
                                открываемого/закрываемого контекста выполнения
                                (по умолчанию отсутствует)
  contextValueId              - Идентификатор, связанный с
                                открываемым/закрываемым контекстом выполнения
                                (по умолчанию отсутствует)
  openContextFlag             - Флаг открытия контекста выполнения
                                (1 открытие контекста, 0 закрытие контекста,
                                -1 открытие и немедленное закрытие контекста,
                                null контекст не меняется)
                                (по умолчанию -1 если указан
                                contextTypeShortName, иначе null)
  contextTypeModuleId         - Id модуля в ModuleInfo, к которому относится
                                открываемый/закрываемый контекст выполнения
                                (по умолчанию Id модуля, к которому относится
                                логер)
  loggerUid                   - Идентификатор логера
                                (по умолчанию корневой логер)
  disableDboutFlag            - Запрет вывода сообщений через dbms_output
                                (в т.ч. порождаемых сообщений об ошибках)
                                (1 да, 0 нет (по умолчанию))


  Замечания:
  - текущая реализация по умолчанию выводит сообщения на промышленной БД
    в таблицу <lg_log>, а на тестовой БД также через dbms_output
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , messageValue integer := null
  , messageLabel varchar2 := null
  , contextTypeShortName varchar2 := null
  , contextValueId integer := null
  , openContextFlag integer := null
  , contextTypeModuleId integer := null
  , loggerUid varchar2 := null
  , disableDboutFlag integer := null
)
is

  -- Uid логера для данного сообщения
  messageLoggerUid TLoggerUid;

  -- Данные записи лога
  lgr LogRecT;

  -- Признак изменения контекста
  isChangeContext boolean := false;

  -- Разрешен вывод через dbms_output
  isDboutEnabled boolean := false;

  -- Разрешен вывод в таблицу
  isTableEnabled boolean := false;

  -- Признак вывода сообщения (любым способом)
  isOutput boolean := false;




  /*
    Заполняет поля вложенного контекста, возвращает false в случае ошибки.
  */
  function fillNestedContextField
  return boolean
  is

    -- Успешность выполнения
    isOk boolean := true;

    -- Строковый идентификатор предыдущего вложенного контекста с тем же типом
    -- и значением
    prevIds IdStrT;

    -- Строковый идентификатор предыдущего вложенного контекста с тем же типом
    prevTypeIds IdStrT;



    /*
      Поиск последнего открытого вложенного контекста с тем же типом и
      типом-значением.
    */
    procedure findOpenContext
    is

      i pls_integer;
      ids IdStrT;

    begin
      i := nestedCtxIdsCol.last();
      while i is not null loop
        ids := nestedCtxIdsCol( i);
        if openContextCol( ids).context_type_id = lgr.context_type_id then
          if prevTypeIds is null then
            prevTypeIds := ids;
          end if;
          if coalesce(
                openContextCol( ids).context_value_id = lgr.context_value_id
                , coalesce(
                    lgr.context_value_id
                    , openContextCol( ids).context_value_id
                  ) is null
              )
              then
            prevIds := ids;
            exit;
          end if;
        end if;
        i := nestedCtxIdsCol.prior( i);
      end loop;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Ошибка при поиске открытого контекста того же типа.'
        , true
      );
    end findOpenContext;



  -- fillNestedContextField
  begin
    findOpenContext();
    if lgr.open_context_flag in ( 1, -1) then
      lgr.context_level := nestedCtxIdsCol.count() + 1;
      lgr.context_type_level :=
        case when prevTypeIds is not null then
          openContextCol( prevTypeIds).context_type_level + 1
        else
          1
        end
      ;
    else
      if prevIds is not null then
        lgr.context_level       := openContextCol( prevIds).context_level;
        lgr.context_type_level  := openContextCol( prevIds).context_type_level;
        lgr.open_context_log_id := openContextCol( prevIds).log_id;
        lgr.open_context_log_time := openContextCol( prevIds).log_time;
      else
        isOk := false;
        logger.error(
          'Отсутствует соответствующий открытый вложенный контекст,'
          || ' закрытие проигнорировано ('
          || ' contextTypeShortName="' || contextTypeShortName || '"'
          || ', contextValueId=' || contextValueId
          || ', context_type_id=' || lgr.context_type_id
          || case when messageLoggerUid != Root_LoggerUid then
              ', logger.moduleName="'
                || colLogger( messageLoggerUid).moduleName || '"'
              || ', logger.objectName="'
                || colLogger( messageLoggerUid).objectName || '"'
            end
          || case when length( messageText) > 500 then
              ', messageText(first 500 chars)="'
                || substr( messageText, 1, 500) || '"'
            else
              ', messageText="' || messageText || '"'
            end
          || ').'
        );
      end if;
    end if;
    return isOk;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Ошибка при заполнении полей вложенного контекста.'
      , true
    );
  end fillNestedContextField;



  /*
    Заполняет поля ассоциативного контекста, возвращает false в случае ошибки.
  */
  function fillMappedContextField
  return boolean
  is

    -- Успешность выполнения
    isOk boolean := true;

  begin
    if lgr.open_context_flag = 0 then
      if mappedCtxIdsCol.exists( lgr.context_type_id) then
        lgr.open_context_log_id :=
          openContextCol( mappedCtxIdsCol( lgr.context_type_id)).log_id
        ;
        lgr.open_context_log_time :=
          openContextCol( mappedCtxIdsCol( lgr.context_type_id)).log_time
        ;
      else
        isOk := false;
        logger.error(
          'Отсутствует соответствующий открытый вложенный контекст,'
          || ' закрытие проигнорировано ('
          || ' contextTypeShortName="' || contextTypeShortName || '"'
          || ', context_type_id=' || lgr.context_type_id
          || case when messageLoggerUid != Root_LoggerUid then
              ', logger.moduleName="'
                || colLogger( messageLoggerUid).moduleName || '"'
              || ', logger.objectName="'
                || colLogger( messageLoggerUid).objectName || '"'
            end
          || case when length( messageText) > 500 then
              ', messageText(first 500 chars)="'
                || substr( messageText, 1, 500) || '"'
            else
              ', messageText="' || messageText || '"'
            end
          || ').'
        );
      end if;
    end if;
    return isOk;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Ошибка при заполнении полей ассоциативного контекста.'
      , true
    );
  end fillMappedContextField;



  /*
    Заполняет поля контекста выполнения.
  */
  procedure fillContextField
  is

    contextTypeModuleId integer := logMessage.contextTypeModuleId;

    -- Флаг вложенного контекста
    nestedFlag lg_context_type.nested_flag%type;

    -- Признак успешного выполнения
    isOk boolean;

  -- fillContextField
  begin
    if openContextFlag not in ( -1, 0, 1) then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Некорректное значение флага открытия контекста ('
          || ' openContextFlag=' || openContextFlag
          || ').'
      );
    end if;
    if contextTypeModuleId is null then
      contextTypeModuleId := getLoggerModuleId( loggerUid => messageLoggerUid);
    end if;
    getContextType(
      contextTypeId           => lgr.context_type_id
      , nestedFlag            => nestedFlag
      , moduleId              => contextTypeModuleId
      , contextTypeShortName  => contextTypeShortName
    );
    lgr.context_value_id := contextValueId;
    lgr.open_context_flag := coalesce( openContextFlag, -1);
    if nestedFlag = 1 then
      isOk := fillNestedContextField();
    else
      isOk := fillMappedContextField();
    end if;

    -- Очищаем поля контекста в случае ошибки
    if not isOk then
      lgr.context_type_id := null;
      lgr.context_value_id := null;
      lgr.open_context_flag := null;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Ошибка при заполнении полей контекста выполнения.'
      , true
    );
  end fillContextField;



  /*
    Выводит ранее не выведенные записи открытия контекста.
  */
  procedure outputSkipOpenContext
  is

    -- Признаки необходимости вывода через dbms_output
    isToDbout boolean;

    i IdStrT;

  begin
    i := hiddenContextList.first();
    while i is not null loop
      if openContextCol( i).context_level <= lgr.context_level
            -- при закрытии выводим автоматически закрываемые вложенные
            -- контексты
            or lgr.context_type_level is not null
              and lgr.open_context_flag = 0
          then
        isToDbout := isDboutEnabled and not hiddenContextList( i);
        if isToDbout or isTableEnabled then
          -- Корректируем данные до фактического вывода чтобы исключить
          -- повторную попытку вывода в случае исключения при выводе
          if isTableEnabled then
            hiddenContextList.delete( i);
          elsif isToDbout then
            hiddenContextList( i) := true;
          end if;
          outputMessage(
            logRec              => openContextCol( i)
            , isDboutEnabled    => isToDbout
            , isTableEnabled    => isTableEnabled
          );
        end if;
      end if;
      i := hiddenContextList.next( i);
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Ошибка при выводе записей открытия контекста.'
      , true
    );
  end outputSkipOpenContext;



  /*
    Выполняет автометическое закрытие контекста.
  */
  procedure autoCloseContext
  is



    /*
      Выполняет автоматическое закрытие контекста.
    */
    procedure processAutoClose(
      i varchar2
    )
    is

      -- Наличие записи в hiddenContextList
      isHidden boolean;

      -- Признаки необходимости вывода в соответствующее назначение
      isToDbout boolean;
      isToTable boolean;

      acr LogRecT;

    begin
      isHidden := hiddenContextList.exists( i);
      isToDbout := isDboutEnabled and not (isHidden and hiddenContextList( i));
      isToTable := isTableEnabled and not isHidden;
      if isHidden then
        hiddenContextList.delete( i);
      end if;
      if isToDbout or isToTable then
        acr.context_level         := nestedCtxIdsCol.count();
        acr.context_type_id       := openContextCol( i).context_type_id;
        acr.context_value_id      := openContextCol( i).context_value_id;
        acr.open_context_log_id   := openContextCol( i).open_context_log_id;
        acr.open_context_log_time := openContextCol( i).open_context_log_time;
        acr.open_context_flag     := 0;
        acr.context_type_level    := openContextCol( i).context_type_level;
        acr.module_name           := openContextCol( i).module_name;
        acr.object_name           := openContextCol( i).object_name;
        acr.module_id             := openContextCol( i).module_id;
        fillCommonField(
          logRec              => acr
          , levelCode         => openContextCol( i).level_code
          , messageText       => 'Автоматическое закрытие контекста'
          , messageValue      => null
          , messageLabel      => null
          , loggerUid         => null
          , disableDboutFlag  => disableDboutFlag
        );
        if isToTable then
          prepareLogRow( acr);
        end if;
      end if;
      openContextCol.delete( i);
      if isToDbout or isToTable then
        outputMessage(
          logRec              => acr
          , isDboutEnabled    => isToDbout
          , isTableEnabled    => isToTable
        );
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Ошибка при закрытии контекста ('
          || ' i="' || i || '"'
          || ').'
        , true
      );
    end processAutoClose;



  -- autoCloseContext
  begin
    if lgr.context_type_level is not null then
      for i in reverse
            lgr.context_level
              + case when lgr.open_context_flag = 0 then 1 else 0 end
            .. nestedCtxIdsCol.count()
          loop
        processAutoClose( nestedCtxIdsCol(i));
        nestedCtxIdsCol.trim( 1);
      end loop;
    else
      if lgr.open_context_flag in ( 1, -1)
            and mappedCtxIdsCol.exists( lgr.context_type_id)
          then
        processAutoClose( mappedCtxIdsCol( lgr.context_type_id));
        mappedCtxIdsCol.delete( lgr.context_type_id);
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Ошибка при выполнении автоматического закрытия контекста.'
      , true
    );
  end autoCloseContext;



  /*
    Изменяет текущий контекст.
  */
  procedure changeContext
  is

    -- Строковый идентификатор открытия контекста
    ids IdStrT;

  begin
    ids := getIdStr( lgr.open_context_log_id);

    -- Общие действия при открытии контекста любого типа
    if lgr.open_context_flag = 1 then
      openContextCol( ids) := lgr;
      if not ( isOutput and isTableEnabled) then
        hiddenContextList( ids) := isOutput and isDboutEnabled;
        --dbms_output.put_line( 'hiddenContextList: add: ' || ids);
      end if;
    end if;

    -- Действия для вложенного контекста
    if lgr.context_type_level is not null then
      if lgr.open_context_flag = 1 then
        nestedCtxIdsCol.extend( 1);
        nestedCtxIdsCol( lgr.context_level) := ids;
      else
        for i in reverse lgr.context_level .. nestedCtxIdsCol.count() loop
          if hiddenContextList.exists( nestedCtxIdsCol( i)) then
            hiddenContextList.delete( nestedCtxIdsCol( i));
          end if;
          openContextCol.delete( nestedCtxIdsCol( i));
          nestedCtxIdsCol.trim( 1);
        end loop;
      end if;
      if coalesce( nestedCtxIdsCol.count()
            != lgr.context_level + lgr.open_context_flag - 1, true)
          then
        raise_application_error(
          pkg_Error.ProcessError
          , 'Число элементов в nestedCtxIdsCol не соответствует уровню'
            || ' вложенности контекста ('
            || ' nestedCtxIdsCol.count()=' || nestedCtxIdsCol.count()
            || ', lgr.context_level=' || lgr.context_level
            || ', lgr.open_context_flag=' || lgr.open_context_flag
            || ').'
        );
      end if;

    -- Действия для ассоциативного контекста
    else
      if lgr.open_context_flag = 1 then
        mappedCtxIdsCol( lgr.context_type_id) := ids;
      else
        if hiddenContextList.exists( ids) then
          hiddenContextList.delete( ids);
        end if;
        openContextCol.delete( ids);
        mappedCtxIdsCol.delete( lgr.context_type_id);
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Ошибка при изменении текущего контекста.'
      , true
    );
  end changeContext;



  /*
    Возвращает истину, если открытие контекста было выведено через любое
    указанное назначение.
  */
  function isOutputForAny(
    openContextIds varchar2
    , forDbout boolean
    , forTable boolean
  )
  return boolean
  is

    isDbout boolean;
    isTable boolean;

  begin
    isTable := not hiddenContextList.exists( openContextIds);
    isDbout :=
      -- если в выведено в таблиц, что и через dbms_output тоже
      -- (т.к. точно в этом случае установить невозможно)
      isTable
      or not isTable
        and hiddenContextList( openContextIds)
    ;
    return
      forDbout and isDbout
      or forTable and isTable
    ;
  end isOutputForAny;



-- logMessage
begin
  --dbms_output.put_line( 'logMessage: text: '|| messageText);
  messageLoggerUid := coalesce( loggerUid, Root_LoggerUid);
  if contextTypeShortName is null
        and (
          contextValueId is not null
          or openContextFlag is not null
          or contextTypeModuleId is not null
        )
      then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не указан тип контекста выполнения (contextTypeShortName).'
    );
  end if;
  if contextTypeShortName is not null then
    fillContextField();
  end if;

  isChangeContext := lgr.open_context_flag is not null;
  if lgr.context_level is null then
    lgr.context_level := coalesce(
      nullif( nestedCtxIdsCol.count(), 0)
      , case when isChangeContext or mappedCtxIdsCol.count() > 0 then 0 end
    );
  end if;

  isDboutEnabled :=
    coalesce( disableDboutFlag, 0) != 1
    -- если явно задано либо ничего явно не задано в тестовой БД
    and (
      forcedDestinationCode = pkg_Logging.DbmsOutput_DestinationCode
      or forcedDestinationCode is null and pkg_Common.isProduction() = 0
    )
  ;
  isTableEnabled :=
    -- если ничего другого явно не задано
    nullif( forcedDestinationCode, pkg_Logging.Table_DestinationCode) is null
  ;
  isOutput :=
    ( isDboutEnabled or isTableEnabled)
      and isMessageEnabled( messageLoggerUid, levelCode)
    -- независимо от уровня сообщения выводим закрытие контекста если
    -- ранее было выведено открытие
    or lgr.open_context_flag = 0
      and isOutputForAny(
        openContextIds  => getIdStr( lgr.open_context_log_id)
        , forDbout      => isDboutEnabled
        , forTable      => isTableEnabled
      )
  ;
  if isOutput then
    outputSkipOpenContext();
  end if;
  if isChangeContext then
    autoCloseContext();
  end if;

  -- полностью готовим запись в случае открытия контекста (т.к. она может быть
  -- выведена позже в любое назначение)
  if lgr.open_context_flag = 1 or isOutput then
    fillCommonField(
      logRec              => lgr
      , levelCode         => levelCode
      , messageText       => messageText
      , messageValue      => messageValue
      , messageLabel      => messageLabel
      , loggerUid         => messageLoggerUid
      , disableDboutFlag  => disableDboutFlag
    );
    if lgr.open_context_flag = 1 or isTableEnabled then
      prepareLogRow( lgr);
    end if;
  end if;
  if isOutput then
    outputMessage(
      logRec              => lgr
      , isDboutEnabled    => isDboutEnabled
      , isTableEnabled    => isTableEnabled
    );
  end if;

  if lgr.open_context_flag != -1 then
    changeContext();
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при логировании сообщения ('
      || ' levelCode="' || levelCode || '"'
      || case when length( messageText) > 200 then
          ', messageText(first 200 chars)="'
            || substr( messageText, 1, 200) || '"'
        else
          ', messageText="' || messageText || '"'
        end
      || ', contextTypeShortName="' || contextTypeShortName || '"'
      || ', contextValueId=' || contextValueId
      || ', openContextFlag=' || openContextFlag
      || ', loggerUid="' || loggerUid || '"'
      || ').'
    , true
  );
end logMessage;



/* group: Реализация функций логера */

/* func: getOpenContextLogId
  Возвращает Id записи лога открытия текущего (последнего открытого)
  вложенного контекста (null при отсутствии текущего вложенного контекста).
*/
function getOpenContextLogId
return integer
is

  i pls_integer;

begin
  i := nestedCtxIdsCol.last();
  return
    case when i is not null then
      openContextCol( nestedCtxIdsCol( i)).open_context_log_id
    end
  ;
end getOpenContextLogId;

/* func: getLoggerUid
  Возвращает уникальный идентификатор логера.
  При отсутствии соответствующего логера создает новый.

  Параметры:
  loggerName                  - Имя логера
                                (по умолчанию формируется из moduleName и
                                objectName)
  moduleName                  - Имя модуля
                                (по умолчанию выделяется из loggerName)
  objectName                  - Имя объекта в модуле (пакета, типа, скрипта)
                                (по умолчанию выделяется из loggerName)
  findModuleString            - Строка для определения Id модуля в ModuleInfo
                                (может совпадать с одним из трех атрибутов
                                модуля: названием, путем к корневому каталогу,
                                первоначальным путем к корневому каталогу в
                                Subversion)
                                (по умолчанию используется moduleName)

  Возврат:
  - идентификатор существующего логера
*/
function getLoggerUid(
  loggerName varchar2
  , moduleName varchar2
  , objectName varchar2
  , findModuleString varchar2
)
return varchar2
is

  -- Uid логера
  loggerUid TLoggerUid;



  /*
    Использует logger.errorStack если доступен внутренний логер.
  */
  function errorStack(
    errorMessage varchar2
  )
  return varchar2
  is
  begin
    return
      case when logger is not null then
        logger.errorStack( errorMessage)
      else
        errorMessage
      end
    ;
  end errorStack;



  /*
    Создает прикладной логер.
  */
  procedure createLogger
  is

    -- Данные создаваемого логера
    r TLogger;

    -- Позиция разделителя после имени модуля в loggerName
    -- (может быть за концом строки)
    sepPos integer;

    -- Uid потомка
    childUid TLoggerUid;

  begin

    -- Инициализация данных
    if loggerName is null then
      r.moduleName := moduleName;
      r.objectName := objectName;
    else
      sepPos := instr( loggerName || '.', '.');
      r.moduleName := substr( loggerName, 1, sepPos - 1);
      r.objectName := substr( loggerName, sepPos + 1);
    end if;
    r.findModuleString := findModuleString;
    r.isNeedFindModuleId := true;
    r.levelCode := null;
    r.additive := true;
    colLogger( loggerUid) := r;

    -- Поиск собственного родителя
    r.parentUid := loggerUid;
    loop
      r.parentUid := colLogger.prior( r.parentUid);
      exit when loggerUid like r.parentUid || '%' or r.parentUid is null;
    end loop;
    colLogger( loggerUid).parentUid := r.parentUid;
    logger.trace( 'getLoggerUid: parentUid="' || r.parentUid || '"');

    -- Корректировка родителя у существующих прямых потомков
    childUid := loggerUid;
    loop
      childUid := colLogger.next( childUid);
      exit when childUid is null or childUid not like loggerUid || '%';
      if colLogger( childUid).parentUid = r.parentUid then
        colLogger( childUid).parentUid := loggerUid;
        logger.trace( 'getLoggerUid: set parent: childUid="' || childUid || '"');
      end if;
    end loop;
  end createLogger;



-- getLoggerUid
begin

  -- Внутреннее логирование, если доступно
  if logger is not null and logger.isTraceEnabled() then
    logger.trace(
      'getLoggerUid: loggerName="' || loggerName || '"'
      || ', moduleName="' || moduleName || '"'
      || ', objectName="' || objectName || '"'
      || ', findModuleString="' || findModuleString || '"'
    );
  end if;

  if loggerName is not null
        and ( moduleName is not null or objectName is not null)
      then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Одновременное указание имени логера'
        || ' и имени модуля/объекта недопустимо.'
    );
  end if;

  -- Определяем Uid
  loggerUid := getLoggerUidByName( coalesce(
    loggerName
    , moduleName
      || case when objectName is not null then
          '.' || objectName
        end
  ));

  -- Создаем логер, если его нет
  if not colLogger.exists( loggerUid) then
    createLogger();
  end if;

  -- Внутреннее логирование, если доступно
  if logger is not null and logger.isDebugEnabled() then
    logger.trace( 'getLoggerUid: return: "' || loggerUid || '"');
  end if;
  return loggerUid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
      -- Внутренний логер может отсутствовать, поэтому используем errorStack
    , errorStack(
        'Ошибка при получении идентификатора логера ('
        || ' loggerName="' || loggerName || '"'
        || ', moduleName="' || moduleName || '"'
        || ', objectName="' || objectName || '"'
        || ', findModuleString="' || findModuleString || '"'
        || ').'
      )
    , true
  );
end getLoggerUid;

/* func: getAdditivity
  Возвращает флаг аддитивности.
*/
function getAdditivity(
  loggerUid varchar2
)
return boolean
is

  -- Флаг аддитивности
  additive boolean;

begin
  additive := colLogger( loggerUid).additive;
  logger.debug( 'getAdditivity: loggerUid="' || loggerUid || '"' || ', result='
    || case additive when true then 'true' when false then 'false' end
  );
  return additive;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении флага аддитивности ('
        || ' loggerUid="' || loggerUid || '"'
        || ').'
      )
    , true
  );
end getAdditivity;

/* proc: setAdditivity
  Устанавливает флаг аддитивности.

  Параметры:
  loggerUid                   - идентификатор логера
  additive                    - флаг аддитивности
*/
procedure setAdditivity(
  loggerUid varchar2
  , additive boolean
)
is
begin
  logger.debug( 'setAdditivity: loggerUid="' || loggerUid || '"' || ', additive='
    || case additive when true then 'true' when false then 'false' end
  );
  if loggerUid = Root_LoggerUid then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Флаг аддитивности не применим для корневого логера.'
    );
  end if;
  colLogger( loggerUid).additive := additive;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при установке флага аддитивности ('
        || ' loggerUid="' || loggerUid || '"'
        || ').'
      )
    , true
  );
end setAdditivity;

/* func: getLevel
  Возвращает уровень логирования.

  Параметры:
  loggerUid                   - идентификатор логера
*/
function getLevel(
  loggerUid varchar2
)
return varchar2
is

  -- Код уровня логирования
  levelCode lg_level.level_code%type;

begin
  levelCode := colLogger( loggerUid).levelCode;
  logger.debug( 'getLevel: loggerUid="' || loggerUid || '"'
    || ', result="' || levelCode || '"'
  );
  return levelCode;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении уровня логирования ('
        || ' loggerUid="' || loggerUid || '"'
        || ').'
      )
    , true
  );
end getLevel;

/* proc: setLevel
  Устанавливает уровень логирования.

  Параметры:
  loggerUid                   - идентификатор логера
  levelCode                   - код уровня логируемых сообщений
*/
procedure setLevel(
  loggerUid varchar2
  , levelCode varchar2
)
is
begin
  logger.debug( 'setLevel: loggerUid="' || loggerUid || '"'
    || ', levelCode="' || levelCode || '"'
  );
  if levelCode is not null and not colLevelOrder.exists( levelCode) then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Неизвестный код уровня логирования.'
    );
  elsif levelCode is null and loggerUid = Root_LoggerUid then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Уровень логирования для корневого логера не может быть NULL.'
    );
  end if;
  colLogger( loggerUid).levelCode := levelCode;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при установке уровня логирования ('
        || ' loggerUid="' || loggerUid || '"'
        || ', levelCode="' || levelCode || '"'
        || ').'
      )
    , true
  );
end setLevel;

/* func: getEffectiveLevel
  Возвращает эффективный уровень логирования.

  Параметры:
  loggerUid                   - идентификатор логера

  Возврат:
  - код уровня логирования

  Замечания:
  - вызывает функцию <getLoggerEffectiveLevel>;
*/
function getEffectiveLevel(
  loggerUid varchar2
)
return varchar2
is

  -- Код уровня логирования
  levelCode lg_level.level_code%type;

begin
  levelCode := getLoggerEffectiveLevel( loggerUid);
  logger.debug( 'getEffectiveLevel: loggerUid="' || loggerUid || '"'
    || ', result="' || levelCode || '"'
  );
  return levelCode;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении эффективного уровня логирования ('
        || ' loggerUid="' || loggerUid || '"'
        || ').'
      )
    , true
  );
end getEffectiveLevel;

/* func: isEnabledFor
  Возвращает истину, если сообщение данного уровня будет логироваться.

  Параметры:
  loggerUid                   - идентификатор логера
  levelCode                   - код уровня логирования

  Замечания:
  - вызывает функцию <isMessageEnabled>;
*/
function isEnabledFor(
  loggerUid varchar2
  , levelCode varchar2
)
return boolean
is
begin
  return isMessageEnabled( loggerUid, levelCode);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при проверке логирования сообщений ('
        || ' loggerUid="' || loggerUid || '"'
        || ', levelCode="' || levelCode || '"'
        || ').'
      )
    , true
  );
end isEnabledFor;

/* func: mergeContextType
  Создает или обновляет тип контекста.

  Параметры:
  loggerUid                   - Идентификатор логера
  contextTypeShortName        - Краткое наименование типа контекста
  contextTypeName             - Наименование типа контекста
  nestedFlag                  - Флаг вложенного контекста (1 да, 0 нет)
  contextTypeDescription      - Описание типа контекста

  Возврат:
  - флаг внесения изменений (0 нет изменений, 1 если изменения внесены)
*/
function mergeContextType(
  loggerUid varchar2
  , contextTypeShortName varchar2
  , contextTypeName varchar2
  , nestedFlag integer
  , contextTypeDescription varchar2
)
return integer
is

  -- Id модуля, к которому относится тип контекста
  moduleId integer;

  -- Флаг внесения изменений
  isChanged integer := 0;

begin
  moduleId := getLoggerModuleId( loggerUid => loggerUid);
  merge into
    lg_context_type d
  using
    (
    select
      moduleId as module_id
      , contextTypeShortName as context_type_short_name
      , contextTypeName as context_type_name
      , nestedFlag as nested_flag
      , contextTypeDescription as context_type_description
      , 0 as deleted
    from
      dual
    minus
    select
      t.module_id
      , t.context_type_short_name
      , t.context_type_name
      , t.nested_flag
      , t.context_type_description
      , t.deleted
    from
      lg_context_type t
    ) s
  on (
    d.module_id = s.module_id
    and d.context_type_short_name = s.context_type_short_name
    )
  when not matched then
    insert
    (
      module_id
      , context_type_short_name
      , context_type_name
      , nested_flag
      , context_type_description
      , deleted
    )
    values
    (
      s.module_id
      , s.context_type_short_name
      , s.context_type_name
      , s.nested_flag
      , s.context_type_description
      , s.deleted
    )
  when matched then
    update set
      d.context_type_name           = s.context_type_name
      , d.nested_flag               = s.nested_flag
      , d.context_type_description  = s.context_type_description
      , d.deleted                   = s.deleted
  ;
  isChanged := sql%rowcount;
  return isChanged;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании или обновлении типа контекста ('
        || ' loggerUid="' || loggerUid || '"'
        || ', contextTypeShortName="' || contextTypeShortName || '"'
        || ', nestedFlag=' || nestedFlag
        || case when moduleId is not null then
            ', moduleId=' || moduleId
          end
        || ').'
      )
    , true
  );
end mergeContextType;

/* proc: deleteContextType
  Удаляет тип контекста.

  Параметры:
  loggerUid                   - Идентификатор логера
  contextTypeShortName        - Краткое наименование типа контекста

  Замечания:
  - при отсутствии использования в логе запись удаляется физически, иначе
    ставится флаг логического удаления;
*/
procedure deleteContextType(
  loggerUid varchar2
  , contextTypeShortName varchar2
)
is

  -- Id модуля, к которому относится тип контекста
  moduleId integer;

  -- Флаг использования
  usedFlag integer;



  /*
    Блокирует запись по типу контекста.
  */
  procedure lockContextType
  is
  begin
    select
      (
      select
        count(*)
      from
        lg_log t
      where
        t.context_type_id = d.context_type_id
        and rownum <= 1
      )
    into usedFlag
    from
      lg_context_type d
    where
      d.module_id = moduleId
      and d.context_type_short_name = contextTypeShortName
      and d.deleted = 0
    for update of d.deleted nowait
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при блокировке записи.'
        )
      , true
    );
  end lockContextType;



-- deleteContextType
begin
  moduleId := getLoggerModuleId( loggerUid => loggerUid);
  lockContextType();
  if usedFlag = 0 then
    delete
      lg_context_type d
    where
      d.module_id = moduleId
      and d.context_type_short_name = contextTypeShortName
    ;
  else
    update
      lg_context_type d
    set
      d.deleted = 1
    where
      d.module_id = moduleId
      and d.context_type_short_name = contextTypeShortName
    ;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении типа контекста ('
        || ' loggerUid="' || loggerUid || '"'
        || ', contextTypeShortName="' || contextTypeShortName || '"'
        || case when moduleId is not null then
            ', moduleId=' || moduleId
          end
        || ').'
      )
    , true
  );
end deleteContextType;



/* group: Совместимость с Scheduler */

/* proc: beforeInsertLogRow
  Вызывается при непосредственной вставке записей из других модулей из триггера
  на таблице <lg_log>.

  Параметры:
  logRec                      - Данные записи таблицы <lg_log>
                                (модификация)
*/
procedure beforeInsertLogRow(
  logRec in out nocopy lg_log%rowtype
)
is
begin
  logRec.level_code :=
    case logRec.message_type_code
      when Error_MessageTypeCode then
        pkg_Logging.Error_LevelCode
      when Warning_MessageTypeCode then
        pkg_Logging.Warn_LevelCode
      when Info_MessageTypeCode then
        pkg_Logging.Info_LevelCode
      when Debug_MessageTypeCode then
        pkg_Logging.Debug_LevelCode
      else
        pkg_Logging.Info_LevelCode
    end
  ;

  prepareLogRow( logRec);

  if logRec.date_ins is null then
    logRec.date_ins := sysdate;
  end if;

  -- Поддержка совместимости с Scheduler
  lastParentLogId :=
    case
      when logRec.message_type_code in (
            'BSTART'
            , 'JSTART'
          )
          then
        logRec.log_id
      else
        logRec.parent_log_id
    end
  ;
end beforeInsertLogRow;



-- pkg_LoggingInternal
begin
  initialize();
end pkg_LoggingInternal;
/
