create or replace package body pkg_MailInternal is
/* package body: pkg_MailInternal::body */



/* group: Константы */

/* iconst: CheckCommand_Timeout
  Таймаут между проверками наличия команд для обработки
  ( в секундах )
*/
CheckCommand_Timeout constant integer := 1;

/* iconst: WaitRequest_Timeout
  Таймаут между проверками обработки запроса
  ( в секундах )
*/
WaitRequest_Timeout constant integer := 1;

/* iconst: Max_Wait_TimeOut
  Максимальное время ожидания запроса в секундах
*/
Max_Wait_TimeOut constant integer := 3600*2.5;



/* group: Переменные */

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName => pkg_MailBase.Module_Name
  , objectName => 'pkg_MailInternal'
);

/* ivar: loggerJava
  Интерфейсный объект к модулю Logging
  для использования в Java
*/
loggerJava lg_logger_t := lg_logger_t.getLogger(
  moduleName => pkg_MailBase.Module_Name
  , objectName => 'Mail.pkg_Mail.java'
);

/* ivar: lastCommandCheck
  Время последней проверки команд
*/
lastCommandCheck number := null;

/* ivar: lastRequestCheck
  Время последней проверки запроса
*/
lastRequestCheck number := null;

/* ivar: batchInited
  Установлена ли переменная <batchShortName>
*/
batchInited boolean not null:= false;

/* ivar: batchShortName
  Наименование текущего выполняемого в данном сеансе батча
*/
batchShortName sch_batch.batch_short_name%type := null;



/* group: Функции */

/* proc: logJava
  Интерфейсная процедура логгирования
  для использования в Java

  Параметры:
  levelCode                   - код уровня сообщения
  messageText                 - текст сообщения
*/
procedure logJava(
  levelCode varchar2
  , messageText varchar2
)
is
begin
  loggerJava.log(
    levelCode => levelCode
    , messageText => messageText
  );
end logJava;

/* func: getBatchShortName
  Возвращает наименование батча сеанса

  Параметры:
  forcedBatchShortName        - переопределение наименования батча

  Возврат:
  имя выполняемого батча.
*/
function getBatchShortName(
  forcedBatchShortName varchar2 := null
)
return varchar2
is
begin
  if forcedBatchShortName is not null then
    batchShortName := forcedBatchShortName;
  elsif not batchInited then
    select
      (
      select
        batch_short_name
      from
        v_sch_batch v
      where
        sid = pkg_Common.getSessionSid()
        and v.serial# = pkg_Common.getSessionSerial()
      )
    into
      batchShortName
    from
      dual
    ;
  end if;
  batchInited := true;
  return batchShortName;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка инициализации batchShortName.'
      )
    , true
  );
end getBatchShortName;

/* proc: initCheckTime
  Инициализация проверки поступления запросов и команд
*/
procedure initCheckTime
is
begin
  lastRequestCheck := null;
  lastCommandCheck := null;
end initCheckTime;

/* proc: initRequestCheckTime
  Инициализация проверки поступления команд и запросов
*/
procedure initRequestCheckTime
is
begin
  lastRequestCheck := null;
end initRequestCheckTime;

/* proc: initHandler
  Инициализация обработчика.

  Параметры:
  processName                 - имя процесса
*/
procedure initHandler(
  processName varchar2
)
is
begin
  pkg_TaskHandler.initHandler(
    moduleName => pkg_MailBase.Module_Name
    , processName => processName
  );
  lastRequestCheck := null;
  lastCommandCheck := null;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка инициализации обработчика'
      )
    , true
  );
end initHandler;

/* func: waitForCommand
  Ожидает команду, получаемую через pipe
  в случае если наступило время проверять команду
  с учётом <lastCommandCheck>.

  Параметры:
  command                     - команда для ожидания
  checkRequestTimeOut         - интервал для проверки ожидания запроса
                                Если задан интервал ожидания команды
                                вычисляется на основе переменной
                                (<body::lastRequestCheck>).

  Возврат:
  получена ли команда.
*/
function waitForCommand(
  command varchar2
  , checkRequestTimeOut integer := null
)
return boolean
is

  -- Полученная команду
  recievedCommand varchar2( 50 );

  -- Возвращаемое значение функции
  isFinish boolean;

  -- Интервал для ожидания команды ( в секундах )
  waitTimeout number;

begin
  logger.trace( 'WaitForStopCommand: start');
  pkg_TaskHandler.setAction( 'idle' );
  logger.trace( 'WaitForStopCommand: checkRequestTimeOut='
    || to_char( checkRequestTimeOut)
  );

  -- Наступило время проверять команду либо передан параметр интервала
  -- проверки запросов
  if checkRequestTimeOut is not null
    or pkg_TaskHandler.nextTime(
      checkTime => lastCommandCheck
      , timeout => CheckCommand_Timeout
    )
  then
    waitTimeout :=
       checkRequestTimeout
       - pkg_TaskHandler.timeDiff( pkg_TaskHandler.getTime, lastRequestCheck);
    logger.trace( 'WaitForStopCommand: waitTimeout='
      || to_char( waitTimeout)
    );

    -- Проверяем поступление команды
    if pkg_TaskHandler.getCommand(
      command => recievedCommand
      , timeout => waitTimeout
    )
    then
      case recievedCommand
        when command then
          isFinish := true;
        else
          raise_application_error(
            pkg_Error.IllegalArgument
            , 'Получена неизвестная управляющая команда "' || command || '".'
          );
      end case;
      logger.info('Получена команда "' || recievedCommand || '"');
    else
      isFinish := false;
    end if;
    lastCommandCheck := null;
  end if;
  pkg_TaskHandler.setAction( '' );
  logger.trace( 'WaitForStopCommand: end');
  return isFinish;
exception when others then
  pkg_TaskHandler.setAction( '' );
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка обработки команды'
      )
    , true
  );
end waitForCommand;

/* func: nextRequestTime
  Определяет истечение таймаута для проверки наличия запросов.
  Учитывается переменная <body::lastRequestCheck>.

  Параметр:
  checkRequestTimeOut         - таймаут ожидания запроса( в секундах)

  Возврат:
  наступило ли время проверять запрос.
*/
function nextRequestTime(
  checkRequestTimeOut number
)
return boolean
is

  isOk boolean;

begin
  logger.trace( 'nextRequestTime: lastRequestCheck='
    || to_char( lastRequestCheck)
  );
  isOk :=
    pkg_TaskHandler.nextTime(
      checkTime => lastRequestCheck
      , timeout => checkRequestTimeOut
    );
  logger.trace( 'nextRequestTime: isOk='
    || case when isOk then 'true' else 'false' end
  );
  return isOk;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка проверки истечения таймаута'
      )
    , true
  );
end nextRequestTime;

/* iproc: waitForFetchRequestInternal
  Ожидание запроса извлечения сообщений без генерации exception в случае
  ошибки обработки.

  Параметры:
  fetchRequestId              - Id запроса
*/
procedure waitForFetchRequestInternal(
  fetchRequestId integer
)
is

  -- Временная переменная для количества запросов в ожидании
  nCount integer;

  -- Время начала ожидания
  startWait number := pkg_TaskHandler.getTime;
  waitingTimedOut boolean;

begin
  pkg_MailInternal.initCheckTime();
  pkg_TaskHandler.setAction('fetch mail wait');
  logger.debug( 'waitForFetchRequestInternal: start' );
  loop

    -- Наступило время проверять запрос
    if pkg_MailInternal.nextRequestTime(
      checkRequestTimeout => pkg_MailInternal.WaitRequest_Timeout
    )
    then
      logger.trace( 'waitForFetchRequestInternal: check start' );
      select
        count(1)
      into
        nCount
      from
        v_ml_fetch_request_wait
      where
        fetch_request_id = fetchRequestId
      ;
      waitingTimedOut := pkg_TaskHandler.nextTime(
        checkTime => startWait
        , timeout => Max_Wait_Timeout
      );
      logger.trace( 'waitForFetchRequestInternal: check end' );
      exit when nCount = 0 or waitingTimedOut;
    else
      dbms_lock.sleep( pkg_MailInternal.WaitRequest_Timeout);
    end if;
  end loop;
  if waitingTimedOut then
    raise_application_error(
      pkg_Error.ProcessError
      , logger.errorStack(
          'Время ожидания (' || to_char( Max_Wait_Timeout) || ' c.) истекло'
        )
    );
  end if;
  logger.debug( 'waitForFetchRequestInternal: end' );
  pkg_TaskHandler.setAction('');
exception when others then
  pkg_TaskHandler.setAction('');
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Внутренняя ошибка ожидания запроса.'
      )
    , true
  );
end waitForFetchRequestInternal;

/* proc: waitForFetchRequest
  Ожидание запроса извлечения сообщений

  Параметры:
  fetchRequestId              - Id запроса
*/
procedure waitForFetchRequest(
  fetchRequestId integer
)
is

  -- Переменные для считывания состояния обработки
  requestStateCode ml_fetch_request.request_state_code%type;
  errorMessage varchar2( 4000);

begin

  waitForFetchRequestInternal( fetchRequestId => fetchRequestId);

  -- Получаем состояние контракта
  select
    r.request_state_code
    , error_message
  into
    requestStateCode
    , errorMessage
  from
    ml_fetch_request r
  where
    fetch_request_id = fetchRequestId
  ;
  if requestStateCode = pkg_MailInternal.Error_RequestStateCode then
    raise_application_error(
      pkg_Error.processError
      , logger.errorStack(
          'Возникла ошибка обработки запроса. Сообщение: '
          || chr(10)
          ||  '"' || errorMessage || '"'
        )
    );
  else
    logger.debug('Запрос обработан( код состояния: "'
      || requestStateCode || '")'
    );
  end if;
end waitForFetchRequest;

end pkg_MailInternal;
/
