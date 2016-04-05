create or replace package body pkg_LoggingInternal is
/* package body: pkg_LoggingInternal::body */



/* group: Типы */

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
                                        --Код назначенного уровня логирования
  levelCode lg_level.level_code%type
                                        --Признак аддитивности логера
  , additive boolean
                                        --Uid родительского логера
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



/* group: Константы */

/* iconst: Root_LoggerUid
  Идентификатор корневого логера.
*/
Root_LoggerUid constant varchar2(1) := '.';



/* group: Переменные */

/* ivar: lg
  Логер пакета.
*/
lg lg_logger_t := null;

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
      , 'Некорректное имя логера ( точка в начале/конце имени либо две точки подряд).'
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

                                        --Uid логгера с установленным уровнем
  lu TLoggerUid := loggerUid;

--GetLoggerEffectiveLevel
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
--IsMessageEnabled
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



  procedure LoadLevelOrder is
  --Загружает порядковые значения уровней логирования.

    cursor curLevel is
      select
        lv.level_code
        , lv.level_order
      from
        lg_level lv
    ;

    type TColLevel is table of curLevel%rowtype;
    colLevel TColLevel;
                                        --Индекс в коллекции
    i pls_integer;

  --LoadLevelOrder
  begin
    open curLevel;
    fetch curLevel bulk collect into colLevel;
    close curLevel;
    i := colLevel.first;
    while i is not null loop
      colLevelOrder( colLevel( i).level_code) := colLevel( i).level_order;
      i := colLevel.next( i);
    end loop;
  end LoadLevelOrder;



  procedure CreateLogger
  is
  --Создает корневой и внутренний логеры.
  --После выполнения процедуры можно вызывать функции пакета, использующие
  --внутренее логирование.

                                        --Имя внутреннего логера пакета
    Package_LoggerName constant varchar2(100)
      := pkg_Logging.Module_Name || '.' || 'pkg_LoggingInternal'
    ;
                                        --Данные логера
    r TLogger;
  --CreateLogger
  begin
                                        --Добавляем корневой логер
    r.levelCode := pkg_Logging.Off_LevelCode;
    r.additive := null;
    r.parentUid := null;
    colLogger( Root_LoggerUid) := r;
                                        --Добавляем внутренний логер
    r.levelCode := null;
    r.additive := true;
    r.parentUid := Root_LoggerUid;
    colLogger( getLoggerUidByName( Package_LoggerName)) := r;
                                        --Инициализируем внутренний логер
                                        --( неявно вызывается getLoggerUid)
    lg := lg_logger_t.GetLogger( Package_LoggerName);
  end CreateLogger;



  procedure ConfigLogger is
  --Выполняет настройку логеров.

                                        --Настраиваемый логер
    logger lg_logger_t;

  --ConfigLogger
  begin
                                        --Устанавливаем специальный уровень
                                        --логирования для модуля по умолчанию
    logger := lg_logger_t.GetLogger( pkg_Logging.Module_Name);
    logger.setLevel( pkg_Logging.Info_LevelCode);
                                        --Настраиваем корневой логер
    logger := lg_logger_t.GetRootLogger();
    logger.setLevel(
      case when pkg_Common.IsProduction = 1 then
        pkg_Logging.Info_LevelCode
      else
        pkg_Logging.Debug_LevelCode
      end
    );
  end ConfigLogger;



--Initialize
begin
                                        --Загружаем порядок уровней
  LoadLevelOrder;
                                        --Создаем логеры
  CreateLogger;
                                        --Настройка логеров
  ConfigLogger;
end initialize;



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

--getCurrentOperatorId
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

/* proc: setLastParentLogId
  Сохраняет значение parent_log_id последней вставленной записи в переменной
  пакета.

  Параметры:
  parentLogId                 - Id родительской записи лога
*/
procedure setLastParentLogId(
  parentLogId integer
)
is
begin
  lastParentLogId := parentLogId;
end setLastParentLogId;

/* ifunc: logDBOut
  Выводит сообщение через dbms_output.
  Строки сообщения, длина которых больше 255 символов, при выводе автоматически
  разбиваются на строки допустимого размера ( в связи ограничением dbms_output).

  Параметры:
  messageText                 - текст сообщения

  Замечания:
  - разбивка при выводе слишком длинных строк сообщения по возможности
    производится по символу новой строки ( 0x0A) либо перед пробелом;
*/
procedure logDBOut(
  messageText varchar2
)
is
                                        --Максимальная длина вывода
  Max_OutputLength constant pls_integer:= 255;
                                        --Длина строки
  len pls_integer := coalesce( length( messageText), 0);
                                        --Стартовая позиция для текущего вывода
  i pls_integer := 1;
                                        --Стартовая позиция для следующего
                                        --вывода
  i2 pls_integer;
                                        --Конечная позиция для текущего вывода
                                        --( не включая)
  k pls_integer := null;

--LogDBOut
begin
  loop
    i2 := len + 1;
    if i2 - i > Max_OutputLength then
      i2 := i + Max_OutputLength;
                                        --Пытаемся разбить строку по символу
                                        --новой строки
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
end logDBOut;

/* ifunc: logDebugDBOut
  Выводит отладочное сообщение через dbms_output c указанием времени с
  точностью до милисекунд, а также вычисляет время в милисекундах с момента
  вывода предыдущего сообщения.

  Параметры:
  messageText                 - текст сообщения
*/
procedure logDebugDBOut(
  messageText varchar2
)
is
  --Текущее время ( до милисекунд)
  curTime timestamp:= systimestamp;

  -- Интервал между последними сообщениями
  timeInterval interval day to second :=
    curTime - previousDebugTimeStamp;

--logDebugDBOut
begin
  logDBOut(
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
end logDebugDBOut;

/* ifunc: logTable
  Добавляет сообщение в таблицу лога.

  Параметры:
  levelCode                   - код уровня сообщения
  messageText                 - текст сообщения
*/
procedure logTable(
  levelCode varchar2
  , messageText varchar2
)
is

  pragma autonomous_transaction;

  truncMessageText varchar2(4000);

begin
  -- обрезание текста до 4000 символов в отдельную переменную во избежании ошибки
  -- ORA-01461: can bind a LONG value only for insert into a LONG column
  truncMessageText := substr( messageText, 1, 4000);
  insert into
    lg_log
  (
    parent_log_id
    , message_type_code
    , message_text
  )
  values
  (
    -- временное решение для более-менее корректной поддержки использования
    -- иерархического лога в модуле Scheduler
    lastParentLogId
    , case levelCode
        when pkg_Logging.Fatal_LevelCode then
          Error_MessageTypeCode
        when pkg_Logging.Error_LevelCode then
          Error_MessageTypeCode
        when pkg_Logging.Warning_LevelCode then
          Warning_MessageTypeCode
        when pkg_Logging.Info_LevelCode then
          Info_MessageTypeCode
        when pkg_Logging.Debug_LevelCode then
          Debug_MessageTypeCode
        when pkg_Logging.Trace_LevelCode then
          Debug_MessageTypeCode
      end
    , truncMessageText
  );
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

  -- Ошибка logDebugDBOut
  dbOutError varchar2( 4000);

begin
  if isMessageEnabled( coalesce( loggerUid, Root_LoggerUid), levelCode) then

    -- Вывод через dbms_output
    if forcedDestinationCode = pkg_Logging.DbmsOutput_DestinationCode
       or nullif( pkg_Common.IsProduction, 0) is null
    then
      begin
        logDebugDBOut(
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

      -- Если неуспешный вызов logDebugDBOut
      if dbOutError is not null then
        logTable( levelCode
          , 'Ошибка вывода в буфер dbms_output: '
            || '"'  || dbOutError || '"' || ' Сообщение: '
            || '"' || messageText || '"'
        );
      end if;
      logTable(
        levelCode
        , messageText
      );
    end if;
  end if;
end logMessage;



/* group: Реализация функций логера */

/* func: getLoggerUid
  Возвращает уникальный идентификатор логера по имени.
  При отсутствии соответствующего логера создает новый.

  Параметры:
  loggerName                  - имя логера ( null соответсвует корневому логеру)

  Возврат:
  - идентификатор существующего логера
*/
function getLoggerUid(
  loggerName varchar2
)
return varchar2
is

                                        --Uid логера
  loggerUid TLoggerUid;



  procedure CreateLogger is
  --Создает прикладной логер.
                                        --Данные логера
    r TLogger;
                                        --Uid потомка
    childUid TLoggerUid;

  --CreateLogger
  begin
                                        --Инициализация данных
    r.levelCode := null;
    r.additive := true;
    colLogger( loggerUid) := r;
                                        --Поиск собственного родителя
    r.parentUid := loggerUid;
    loop
      r.parentUid := colLogger.prior( r.parentUid);
      exit when loggerUid like r.parentUid || '%' or r.parentUid is null;
    end loop;
    colLogger( loggerUid).parentUid := r.parentUid;
    lg.trace( 'getLoggerUid: parentUid="' || r.parentUid || '"');
                                        --Корректировка родителя у существующих
                                        --прямых потомков
    childUid := loggerUid;
    loop
      childUid := colLogger.next( childUid);
      exit when childUid is null or childUid not like loggerUid || '%';
      if colLogger( childUid).parentUid = r.parentUid then
        colLogger( childUid).parentUid := loggerUid;
        lg.trace( 'getLoggerUid: set parent: childUid="' || childUid || '"');
      end if;
    end loop;
  end CreateLogger;



--GetLoggerUid
begin
                                        --Внутреннее логирование, если доступно
  if lg is not null then
    lg.debug( 'getLoggerUid: loggerName="' || loggerName || '"');
  end if;
                                        --Определяем Uid
  loggerUid := getLoggerUidByName( loggerName);
                                        --Создаем логер, если его нет
  if not colLogger.exists( loggerUid) then
    CreateLogger;
  end if;
                                        --Внутреннее логирование, если доступно
  if lg is not null then
    lg.trace( 'getLoggerUid: return: "' || loggerUid || '"');
  end if;
  return loggerUid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , lg.errorStack(
      'Ошибка при получении идентификатора логера по имени ('
      || ' loggerName="' || loggerName || '"'
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
                                        --Флаг аддитивности
  additive boolean;

--GetAdditivity
begin
  additive := colLogger( loggerUid).additive;
  lg.debug( 'getAdditivity: loggerUid="' || loggerUid || '"' || ', result='
    || case additive when true then 'true' when false then 'false' end
  );
  return additive;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , lg.errorStack(
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
  lg.debug( 'setAdditivity: loggerUid="' || loggerUid || '"' || ', additive='
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
    , lg.errorStack(
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
                                        --Код уровня логирования
  levelCode lg_level.level_code%type;

--GetLevel
begin
  levelCode := colLogger( loggerUid).levelCode;
  lg.debug( 'getLevel: loggerUid="' || loggerUid || '"'
    || ', result="' || levelCode || '"'
  );
  return levelCode;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , lg.errorStack(
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
  lg.debug( 'setLevel: loggerUid="' || loggerUid || '"'
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
    , lg.errorStack(
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

                                        --Код уровня логирования
  levelCode lg_level.level_code%type;

--GetEffectiveLevel
begin
  levelCode := getLoggerEffectiveLevel( loggerUid);
  lg.debug( 'getEffectiveLevel: loggerUid="' || loggerUid || '"'
    || ', result="' || levelCode || '"'
  );
  return levelCode;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , lg.errorStack(
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
    , lg.errorStack(
      'Ошибка при проверке логирования сообщений ('
      || ' loggerUid="' || loggerUid || '"'
      || ', levelCode="' || levelCode || '"'
      || ').'
      )
    , true
  );
end isEnabledFor;

--pkg_LoggingInternal
begin
  initialize();
end pkg_LoggingInternal;
/
