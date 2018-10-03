create or replace package body pkg_LoggingInternal is
/* package body: pkg_LoggingInternal::body */



/* group: Типы */

/* itype: FindModuleStringT
  Строка для определения Id модуля (тип).
  Максимальная длина должна быть не меньше, чем у поля module_name таблицы
  <lg_log>.
*/
subtype FindModuleStringT is varchar2(128);

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



/* group: Функции */



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
*/
procedure setLoggerModuleId(
  loggerUid varchar2
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
        , raiseExceptionFlag  => 0
      );
      setLoggerModuleIdCache( findModuleString) := moduleId;
      logger.trace( 'setLoggerModuleId: found moduleId=' || moduleId);
    end if;

    colLogger( loggerUid).moduleId := moduleId;
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
  end if;
  if logRec.operator_id is null then
    logRec.operator_id := getCurrentOperatorId();
  end if;
  if logRec.date_ins is null then
    logRec.date_ins := sysdate;
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
  levelCode                   - Код уровня сообщения
  messageText                 - Текст сообщения
  loggerUid                   - Идентификатор используемого логера
*/
procedure logTable(
  levelCode varchar2
  , messageText varchar2
  , loggerUid varchar2
)
is

  pragma autonomous_transaction;

  lgr lg_log%rowtype;

  truncMessageText varchar2(4000);

begin
  lgr.level_code := levelCode;
  lgr.message_text := substr( messageText, 1, 4000);
  if loggerUid is not null then
    lgr.module_name := colLogger( loggerUid).moduleName;
    lgr.object_name := colLogger( loggerUid).objectName;
    if colLogger( loggerUid).isNeedFindModuleId then
      begin
        setLoggerModuleId( loggerUid => loggerUid);
      exception when others then
        logTable(
          levelCode     => pkg_Logging.Error_LevelCode
          , messageText => logger.getErrorStack()
          , loggerUid   => internalLoggerUid
        );
      end;
    end if;
    lgr.module_id := colLogger( loggerUid).moduleId;
  end if;

  prepareLogRow( lgr);

  -- Поддержка совместимости с Scheduler
  lgr.parent_log_id := lastParentLogId;
  lgr.message_type_code :=
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

  insert into
    lg_log
  values
    lgr
  ;
  commit;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при записи в сообщения в таблицу лога:'
        || chr( 10)
        || ' parent_log_id=' || lastParentLogId
        || ' , levelCode=' || levelCode
        || ' , length(messageText)=' || length( messageText)
        || ' , messageText ( first 200 char):'
          || chr( 10) || substr( messageText, 1, 200)
    , true
  );
end logTable;

/* proc: logMessage
  Логирует сообщение.

  Параметры:
  levelCode                   - код уровня сообщения
  messageText                 - текст сообщения
  loggerUid                   - идентификатор логера, через которое пришло
                                сообщение ( по умолчанию корневой логер)

  Замечания:
  - текущая реализация по умолчанию выводит сообщения на промышленной БД
    в таблицу <lg_log>, а на тестовой БД также через dbms_output
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , loggerUid varchar2 := null
)
is

  -- Ошибка logDebugDbOut
  dbOutError varchar2( 4000);

begin
  if isMessageEnabled( coalesce( loggerUid, Root_LoggerUid), levelCode) then

    -- Вывод через dbms_output
    -- (если явно задано либо явно не задано в тестовой БД)
    if forcedDestinationCode = pkg_Logging.DbmsOutput_DestinationCode
      or forcedDestinationCode is null and pkg_Common.isProduction() = 0
    then
      begin
        logDebugDbOut(
          rpad( levelCode, 5) || ': ' || messageText
        );
      exception when others then
        dbOutError := sqlerrm;
      end;
    end if;

    -- Вывод в таблицу лога
    if nullif( forcedDestinationCode, pkg_Logging.Table_DestinationCode)
      is null
    then

      -- Логируем ошибку выполнения dbms_output
      if dbOutError is not null then
        logTable(
          levelCode     => pkg_Logging.Error_LevelCode
          , messageText =>
              'Ошибка вывода в буфер dbms_output: "'  || dbOutError || '".'
              || ' Сообщение: levelCode="' || levelCode || '"'
                || ', messageText="' || messageText || '".'
          , loggerUid   => internalLoggerUid
        );
      end if;
      logTable(
        levelCode       => levelCode
        , messageText   => messageText
        , loggerUid     => loggerUid
      );
    end if;
  end if;
end logMessage;



/* group: Реализация функций логера */

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
  if logger is not null and logger.isDebugEnabled() then
    logger.debug(
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
