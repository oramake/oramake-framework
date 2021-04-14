create or replace package body pkg_TaskHandler is
/* package body: pkg_TaskHandler::body */



/* group: Константы */

/* iconst: Task_ModulePrefix
  Префикс имени модуля ( v$session.module) для задачи ( обработчика).
*/
Task_ModulePrefix constant varchar2(50) := 'TASK';

/* iconst: CommandPipe_NamePrefix
  Префикс имени управляющего канала для обработчика.
*/
CommandPipe_NamePrefix constant varchar2(50) := 'pkg_TaskHandler.CommandPipe_';

/* iconst: Initialize_Action
  Название действия, устанавливаливаемое при инициализации процедуры.
*/
Initialize_Action constant varchar2(32) := 'initialize';



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_TaskHandler'
);

/* ivar: currentCommandPipeName
  Имя командного канала для текущей сессий.
*/
currentCommandPipeName varchar2(128);



/* group: Функции */



/* group: Таймауты и интервалы времени */

/* func: toSecond
  Возвращает длительность интервала в секундах.

  Параметры:
  timeInterval                - исходный временной интервал
*/
function toSecond(
  timeInterval interval day to second
)
return number
is
begin
  return
    extract( SECOND   from timeInterval)
    + extract( MINUTE from timeInterval) * 60
    + extract( HOUR   from timeInterval) * 60 * 60
    + extract( DAY    from timeInterval) * 60 * 60 * 24
  ;
end toSecond;

/* func: getTimeout
  Возвращает значение таймаута ( в секундах) на основе базового таймаута
  и граничного времени ( в случае, если граничное время наступает до
  до истечения базового таймаута, то возвращается таймаут до граничного
  времени).

  Параметры:
  baseTimeout               - базовый таймаут ( в секундах)
  limitTime                 - граничное время

  Замечание:
  если граничное время просрочено или null, возвращается null.
*/
function getTimeout(
  baseTimeout number
  , limitTime timestamp with time zone
)
return number
is

  -- Возвращаемый таймаут
  timeout number := null;

  -- Текущее время
  sysTime timestamp with time zone := systimestamp;

begin
  if limitTime > ( sysTime + numtodsinterval( baseTimeout, 'SECOND')) then
    timeout := baseTimeout;
  elsif limitTime >= sysTime then
    timeout := pkg_TaskHandler.toSecond( limitTime - sysTime);
  end if;
  return timeout;
end getTimeout;

/* func: getTime
  Возвращет текущее время в секундах ( с определенного момента с точностью до
  сотых долей секунды).

  Замечание: счетчик может сбрасываться через существенный интервал времени
  ( несколько дней - месяцев).
*/
function getTime
return number
is
begin
  return dbms_utility.get_time() / 100;
end getTime;

/* func: timeDiff
  Возвращает длительность прошедшего времени в секундах.

  Параметры:
  newTime                     - последний момент времени
                                ( в секундах по getTime())
  oldTime                     - предыдущий момент времени
                                ( в секундах по getTime())

  Замечание:
  в случае, если сбрасывался счетчик getTime() ( т.е. newTime < oldTime)
  возвращается null.
*/
function timeDiff(
  newTime number
  , oldTime number
)
return number
is
begin
  return
    case when newTime >= oldTime then
      newTime - oldTime
    end
  ;
end timeDiff;

/* func: nextTime
  В случае истечения таймаута с указанного момента времени обновляет значение
  момента времени на текущее и возвращает истину иначе возвращает ложь.

  Параметры:
  checkTime                   - базовый момент времени
                                ( в секундах по функции getTime())
  timeout                     - таймаут ожидания ( в секундах)

  Замечание:
    - в случае сброса счетчика в getTime() возвращается истина, но реально
      истекший таймаут может быть меньше заданного;
    - в случае, если checkTime is null возвращается истина;
    - в случае, если timeout is null возвращается истина;
*/
function nextTime(
  checkTime in out nocopy number
  , timeout number
)
return boolean
is

  -- Возвращаемое значение
  isOk boolean;

  -- Текущее время
  currentTime number := getTime();

begin
  isOk :=
    checkTime is null
    or timeout is null
    or currentTime < checkTime
    or currentTime - checkTime >= timeout
  ;
  if isOk then
    checkTime := currentTime;
  end if;
  return isOk;
end nextTime;



/* group: Информирование о состоянии */

/* iproc: setAction( INTERNAL)
  Устанавливает информацию о выполняемом действии.

  Параметры:
  action                      - название действия
  actionInfo                  - информация о выполняемом действии
  limitTime                   - планируемая дата завершения действия
  limitSecond                 - максимальное время выполнения ( в секундах)
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2
  , limitTime timestamp with time zone
  , limitSecond integer
)
is

  -- Текущее время
  tm timestamp with time zone := systimestamp;

  -- Текст, описывающий время действия
  actionTime varchar2( 100);

  -- Длина информационной части
  infoLength integer;

begin
  actionTime :=
    substr( to_char( tm, 'yy-mm-dd hh24:mi:ss.ff'), 1, 20)
    || to_char( tm, ' TZH:TZM')
  ;
  if limitSecond is not null or limitTime is not null then
    actionTime := actionTime || ';'
      || to_char( ceil(
          coalesce( limitSecond, toSecond( limitTime - tm)) * 100
        ));
  end if;
  infoLength := 64 - length( actionTime) - 1;

  -- Устанавливает название действия
  dbms_application_info.set_action( action);

  -- Устанавливаем параметры действия
  dbms_application_info.set_client_info(
    case when infoLength > 0 and length( actionInfo) > 0 then
      substr( actionInfo, 1, infoLength) || ','
    end
    || actionTime
  );
end setAction;

/* proc: setAction
  Устанавливает информацию о выполняемом действии.

  Параметры:
  action                      - название действия
  actionInfo                  - информация о выполняемом действии
  limitTime                   - планируемая дата завершения действия
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2 := null
  , limitTime timestamp with time zone := null
)
is
begin
  setAction(
    action            => action
    , actionInfo      => actionInfo
    , limitTime       => limitTime
    , limitSecond     => null
  );
end setAction;

/* proc: setAction( LIMIT_SECOND)
  Устанавливает информацию о выполняемом действии.

  Параметры:
  action                      - название действия
  actionInfo                  - информация о выполняемом действии
  limitSecond                 - максимальное время выполнения ( в секундах)
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2 := null
  , limitSecond integer
)
is
begin
  setAction(
    action            => action
    , actionInfo      => actionInfo
    , limitTime       => null
    , limitSecond     => limitSecond
  );
end setAction;

/* proc: initTask
  Инициализирует задачу.

  Параметры:
  moduleName                  - имя модуля
  processName                 - имя процесса
*/
procedure initTask(
  moduleName varchar2
  , processName varchar2
)
is
begin

  -- Устанавливаем имя модуля и процесса
  dbms_application_info.set_module(
    Task_ModulePrefix || ':' || moduleName || ':' || processName
    , Initialize_Action
  );
  setAction( Initialize_Action);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при инициализации задачи.'
      )
    , true
  );
end initTask;

/* proc: cleanTask
  Выполняет очистку при завершении задачи.

  Параметры:
  riseException               - возможность выброса наружу исключения в случае
                                ошибки, по-умолчанию все ошибки маскируются
                                и никакие исключения не выбрасываются
*/
procedure cleanTask(
  riseException boolean := null
)
is
begin

  -- Очищаем информацию о состоянии
  setAction( null);
  dbms_application_info.set_module( null, null);
exception when others then
  if riseException then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при очистке по завершении работы задачи.'
        )
      , true
    );
  else
    null;
  end if;
end cleanTask;



/* group: Работа с каналами */

/* proc: createPipe
  Создает канал.

  Параметры:
  pipeName                    - имя канала
*/
procedure createPipe(
  pipeName varchar2
)
is

  -- Результат операции с каналом
  pipeStatus number;

begin
  pipeStatus := dbms_pipe.create_pipe( pipeName);
  logger.trace(
    'create_pipe: ' || pipeName || ', result: ' || pipeStatus
  );
  if pipeStatus <> 0 then
    raise_application_error(
      pkg_Error.PipeError
      , 'Создание канала завершилось неуспешно ('
        || ' код ошибки: ' || to_char( pipeStatus)
        || ').'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании канала ('
        || ' pipeName="' || pipeName || '"'
        || ').'
      )
    , true
  );
end createPipe;

/* proc: removePipe
  Удаляет канал.

  Параметры:
  pipeName                    - имя канала
*/
procedure removePipe(
  pipeName varchar2
)
is

  -- Результат операции с каналом
  pipeStatus number;

begin
  pipeStatus := dbms_pipe.remove_pipe( pipeName);
  logger.trace(
    'remove_pipe: ' || pipeName || ', result: ' || pipeStatus
  );
  if pipeStatus <> 0 then
    raise_application_error(
      pkg_Error.PipeError
      , 'Удаление канала завершилось неуспешно ('
        || ' код ошибки: ' || to_char( pipeStatus)
        || ').'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении канала ('
        || ' pipeName="' || pipeName || '"'
        || ').'
      )
    , true
  );
end removePipe;

/* ifunc: sendMessage( INTERNAL)
  Посылает сообщение в канал.

  Параметры:
  pipeName                    - имя канала
  timeout                     - таймаут ожидания ( в секундах, по умолчанию
                                максимально возможный, dbms_pipe.maxwait)
  maxPipeSize                 - максимальный размер канала ( по умолчанию
                                8192)
  isCheckResult               - проверять результат отправки и выбрасывать
                                исключение в случае недоспустимого результата
                                ( 1 да, 0 нет ( по умолчанию))
  isIgnoreTimeoutError        - при выполнении проверки ( если isCheckResult
                                равен 1) считать ошибку по таймауту ( код
                                1, см. ниже) допустимым результатом ( 1 да,
                                0 нет, по умолчанию 0)

  Возврат:
  код результа отправки сообщения.

  Коды результата:
  0   - успешное выполнение
  1   - истечение таймаута либо возможно канал не существовал ( если было
        указано недопустимо малое значение maxPipeSize, например 1)
  ... - другие ошибки согласно документации к dbms_pipe.send_message

  Замечания:
  - в случае, если функция заверщается с исключением ( в т.ч.
    возникшим вследствие проверки результата отправки) выполняется
    очистка буфера сообщений с помощью вызова dbms_pipe.reset_buffer;
*/
function sendMessage(
  pipeName varchar2
  , timeout integer
  , maxPipeSize integer
  , isCheckResult pls_integer
  , isIgnoreTimeoutError pls_integer := null
)
return integer
is

  -- Результат операции с каналом
  pipeStatus integer := null;

--sendMessage
begin
  pipeStatus := dbms_pipe.send_message(
    pipename      => pipeName
    , timeout     => coalesce( timeout, dbms_pipe.maxwait)
    , maxpipesize => coalesce( maxPipeSize, 8192)
  );
  logger.trace(
    'send_message: ' || pipeName || ', result: ' || pipeStatus
  );
  if coalesce( pipeStatus <> 0, true) then
    if isCheckResult = 1 then
      if isIgnoreTimeoutError = 1 and pipeStatus = 1 then
        null;
      else
        raise_application_error(
          pkg_Error.PipeError
          , 'Неуспешный результат отправки сообщения ('
            || ' код ошибки: ' || to_char( pipeStatus)
            || ').'
        );
      end if;
    end if;
  end if;
  return pipeStatus;
exception when others then
  -- Очищаем буфер с данными сообщения перед выбросом исключения
  dbms_pipe.reset_buffer;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при отправке сообщения в канал ('
        || ' pipeName="' || pipeName || '"'
        || ', timeout=' || to_char( timeout)
        || ', maxPipeSize=' || to_char( maxPipeSize)
        || ', isCheckResult=' || to_char( isCheckResult)
        || ', isIgnoreTimeoutError=' || to_char( isIgnoreTimeoutError)
        || ').'
      )
    , true
  );
end sendMessage;

/* proc: sendMessage
  Посылает сообщение в канал.

  Параметры:
  pipeName                    - имя канала
  timeout                     - таймаут ожидания ( в секундах, по умолчанию
                                максимально возможный, dbms_pipe.maxwait)
  maxPipeSize                 - максимальный размер канала ( по умолчанию 8192)

  Замечания:
  представляет собой обертку для функции <sendMessage( INTERNAL)> для варианта
  с выбросом исключения при неуспешном результате ( isCheckResult = 1).
*/
procedure sendMessage(
  pipeName varchar2
  , timeout integer := null
  , maxPipeSize integer := null
)
is

  -- Результат операции с каналом
  pipeStatus integer;

--sendMessage
begin
  pipeStatus := sendMessage(
    pipename        => pipeName
    , timeout       => timeout
    , maxPipeSize   => maxPipeSize
    , isCheckResult => 1
  );
end sendMessage;

/* func: sendMessage( STATUS)
  Посылает сообщение в канал и возвращает результат.

  Параметры:
  pipeName                    - имя канала
  timeout                     - таймаут ожидания ( в секундах, по умолчанию
                                максимально возможный, dbms_pipe.maxwait)
  maxPipeSize                 - максимальный размер канала ( по умолчанию 8192)

  Возврат:
  код результа отправки сообщения ( см. <sendMessage( INTERNAL)>).

  Замечания:
  представляет собой обертку для функции <sendMessage( INTERNAL)> для варианта
  без проверки результата ( isCheckResult = 0).
*/
function sendMessage(
  pipeName varchar2
  , timeout integer := null
  , maxPipeSize integer := null
)
return integer
is
begin
  return
    sendMessage(
      pipename        => pipeName
      , timeout       => timeout
      , maxPipeSize   => maxPipeSize
      , isCheckResult => 0
    )
  ;
end sendMessage;

/* func: receiveMessage
  Проверяет наличие сообщения в канале и возвращает истину, если оно получено.

  Параметры:
  pipeName                    - имя канала
  timeout                     - время ожидания в секундах ( по умолчанию без
                                ожидания)
*/
function receiveMessage(
  pipeName varchar2
  , timeout number := null
)
return boolean
is

  -- Признак получения команды
  retVal boolean := false;

  -- Время засыпания (доли секунды)
  sleepSecond number := 0;

  -- Время ожидания на канале (секунды)
  receiveSecond integer := 0;



  /*
    Проверяет сообщения в канале.
  */
  procedure checkPipe( waitSecond number) is

    -- Результат получения сообщения
    pipeStatus integer;

  begin
    -- Ждем получения сообщения
    pipeStatus := dbms_pipe.receive_message( pipeName, waitSecond);
    logger.trace(
      'receive_message: ' || pipeName || ', result: ' || pipeStatus
    );
    case pipeStatus
      when 0 then
        -- Получено сообщение
        retVal := true;
      when 1 then
        -- Истек таймаут
        null;
      else
        -- Прерывание или ошибка
        raise_application_error(
          pkg_Error.PipeError
          , 'Получение сообщения из канала завершилось неуспешно ('
            || ' код ошибки: ' || to_char( pipeStatus)
            || ').'
        );
    end case;
  end checkPipe;



--receiveMessage
begin
  if timeout > 0 then

    -- Ожидание на канале в полных секундах
    receiveSecond := floor( timeout);

    -- Спячка в долях секунды
    sleepSecond := timeout - receiveSecond;
  end if;

  -- Сразу проверяем канал
  checkPipe( 0);
  if not RetVal and ( sleepSecond > 0  or receiveSecond > 0 ) then

    -- Спим доли секунды
    if sleepSecond > 0 then
      dbms_lock.sleep( sleepSecond);
    end if;

    -- Ждем на канале остаток времени
    checkPipe( receiveSecond);
  end if;
  return retVal;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при проверке наличия сообщения в канале ('
        || ' pipeName="' || pipeName || '"'
        || ').'
      )
    , true
  );
end receiveMessage;



/* group: Отправка/получение команд */

/* ifunc: getCommandPipeName
  Возвращает имя командного канала для сессии.

  Параметры:
  sessionSid                  - v$session.sid сессии назначения
  sessionSerial               - v$session.serial# сессии назначения
*/
function getCommandPipeName(
  sessionSid number
  , sessionSerial number
)
return varchar2
is
begin
  return
    CommandPipe_NamePrefix
    || to_char( sessionSid)
    || '_'
    || to_char( sessionSerial)
  ;
end getCommandPipeName;

/* func: sendCommand
  Отсылает команду указанной сессии.

  Параметры:
  sessionSid                  - v$session.sid сессии назначения
  sessionSerial               - v$session.serial# сессии назначения

  Возвращаемое значение: истина, если команда успешно отправлена и ложь, если
  команды не могут быть отправлены этой сессии т.к. она не существует.
*/
function sendCommand(
  sessionSid number
  , sessionSerial number
)
return boolean
is

  -- Признак успешной отправки команды
  isSend boolean := false;

  -- Имя канала для отправки команды
  pipeName currentCommandPipeName%type :=
    getCommandPipeName( sessionSid, sessionSerial)
  ;

  -- Флаг существования сессии
  isExist integer;

begin
  if sendMessage(
        pipeName                => pipeName
        , timeout               => 0
          -- Обеспечивает ошибку при отсутствии канала
        , maxPipeSize           => 1
        , isCheckResult         => 1
        , isIgnoreTimeoutError  => 1
      ) = 0
      then
    isSend := true;
  else
    -- Проверяем наличие сессии
    select
      count(1)
    into isExist
    from
      v$session ss
    where
      ss.sid = sessionSid
      and ss.serial# = sessionSerial
    ;
    if isExist = 1 then
      -- Повторяем без указания maxPipeSize ( может сработать)
      sendMessage(
        pipeName    => pipeName
        , timeout   => 0
      );
      isSend := true;
    else
      -- Удаляем неиспользуемый командный канал
      removePipe( pipeName);
    end if;
  end if;
  return isSend;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при отправке команды для сессии ('
        || ' sid=' || to_char( sessionSid)
        || ', serial#=' || to_char( sessionSerial)
        || ').'
      )
    , true
  );
end sendCommand;

/* proc: sendStopCommand
  Посылает команду остановки указанному обработчику.

  Параметры:
  sessionSid                  - v$session.sid сессии назначения
  sessionSerial               - v$session.serial# сессии назначения
  moduleName                  - имя модуля

  Замечания:
  если параметры не указаны (null), то команда остановки посылается всем
  работающим обработчикам.
*/
procedure sendStopCommand(
  sessionSid number := null
  , sessionSerial number := null
  , moduleName varchar2 := null
)
is

  cursor curSession is
    select
      ss.sid
      , ss.serial#
      , cp.name as pipe_name
    from
      v_th_session ss
      inner join v_th_command_pipe cp
        on cp.sid = ss.sid
        and cp.serial# = ss.serial#
    where
      nullif( sessionSid, ss.sid) is null
      and nullif( sessionSerial, ss.serial#) is null
      and nullif( moduleName, ss.module_name) is null
  ;

  -- Число отправленных команд остановки
  nSend integer := 0;

--sendStopCommand
begin
  for rec in curSession loop

    -- Посылаем команду остановки
    dbms_pipe.pack_message( Stop_Command);
    sendMessage(
      pipeName => rec.pipe_name
      , timeout => 0
    );
    nSend := nSend + 1;
  end loop;

  -- Ошибка при отсутствии сессии
  if nSend = 0 and coalesce( sessionSid, sessionSerial) is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не найдена сессия для остановки ('
        || substr(
            case when sessionSid is not null then
                ', sid=' || to_char( sessionSid)
            end
            || case when sessionSerial is not null then
                ', serial#=' || to_char( sessionSerial)
              end
            , 3)
        || ').'
    );
  end if;
end sendStopCommand;

/* func: getCommand
  Пытается получить очередную команду в течение указанного таймаута.
  Возвращает истину, если команда была получена.

  Параметры:
  command                     - полученная команда
  timeout                     - время ожидания в секундах ( по умолчанию без
                                ожидания)
*/
function getCommand(
  command out varchar2
  , timeout number := null
)
return boolean
is

  -- Признак получения сообщения
  isReceive boolean;

begin
  isReceive := receiveMessage(
    pipeName => currentCommandPipeName
    , timeout =>
        case when timeout > 0 and timeout < 0.01 then
          0.01
        else
          timeout
        end
  );
  if isReceive then

    -- Получаем имя команды
    dbms_pipe.unpack_message( command);
  end if;
  return isReceive;
end getCommand;

/* func: isStopCommandReceived
  Проверяет получение команды остановки.

  Параметры:
  timeout                     - Время ожидания в секундах
                                (по умолчанию без ожидания)

  Возврат:
  истина, если команда остановки была получена.
*/
function isStopCommandReceived(
  timeout number := null
)
return boolean
is

  -- Признак получения команды
  isReceived boolean;

  -- Имя полученной команды
  command varchar2(50);

begin
  isReceived := getCommand(
    command   => command
    , timeout => timeout
  );
  if command != Stop_Command then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Получена неизвестная управляющая команда "' || command || '".'
    );
  end if;
  return coalesce( command = Stop_Command, false);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при проверке получения команды остановки ('
        || 'timeout=' || timeout
        || ').'
      )
    , true
  );
end isStopCommandReceived;

/* proc: initHandler
  Инициализирует обработчик.

  Параметры:
  moduleName                  - имя модуля
  processName                 - имя процесса
*/
procedure initHandler(
  moduleName varchar2
  , processName varchar2
)
is
begin

  -- Устанавливаем имя модуля и процесса
  initTask( moduleName, processName);
  currentCommandPipeName := getCommandPipeName(
    sessionSid => pkg_Common.GetSessionSid
    , sessionSerial => pkg_Common.GetSessionSerial
  );
  createPipe( currentCommandPipeName);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при инициализации обработчика.'
      )
    , true
  );
end initHandler;

/* proc: cleanHandler
  Выполняет очистку при завершении работы обработчика.

  Параметры:
  riseException               - возможность выброса наружу исключения в случае
                                ошибки, по-умолчанию все ошибки маскируются
                                и никакие исключения не выбрасываются

*/
procedure cleanHandler(
  riseException boolean := null
)
is
begin

  -- Удаляем управляющий пайп
  if currentCommandPipeName is not null then
    removePipe( currentCommandPipeName);
    currentCommandPipeName := null;
  end if;
  cleanTask();
exception when others then
  if riseException then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при очистке по завершении работы обработчика.'
        )
      , true
    );
  else
    null;
  end if;
end cleanHandler;



/* group: Блокировки */

/* proc: setLock
  Устанавливает эксклюзивную блокировку для сериализации выполнения.

  Параметры:
  lockName                    - имя блокировки
  waitSecond                  - таймаут ожидания в секудах ( null -
                                макcимально возможное время)
*/
procedure setLock(
  lockName varchar2
  , waitSecond integer := null
)
is

  lockHandle varchar2( 128);
  lockError integer;

  /*
    Получение дескриптора блокировки.
  */
  procedure getHandle
  is
    pragma autonomous_transaction;
  begin
    -- Вызываем в автономной транзакции, так как выполняет commit
    dbms_lock.allocate_unique(
      lockName  =>
        sys_context ( 'USERENV', 'CURRENT_USER')
        || '.' || lockName
      , lockhandle => lockHandle
    );
    commit;
  end getHandle;

-- setLock
begin
  getHandle();
  lockError := dbms_lock.request(
    lockhandle => lockHandle
    , lockmode => dbms_lock.x_mode
    , timeout => coalesce( waitSecond, dbms_lock.maxwait)
    , release_on_commit => true
  );
  -- Не успешное получение и не собственная блокировка
  if lockError not in ( 0, 4) then
    raise_application_error(
      pkg_Error.ProcessError
      , logger.errorStack(
          'Не удалось установить блокировку ('
          || ' lockError=' || to_char( lockError)
          || ')'
        )
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении блокировки ('
        || ' lockName="' || lockName || '"'
        || ', код ошибки: ' || to_char( lockError)
        || ').'
      )
    , true
  );
end setLock;

end pkg_TaskHandler;
/
