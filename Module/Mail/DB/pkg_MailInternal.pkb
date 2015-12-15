create or replace package body pkg_MailInternal is
/* package body: pkg_MailInternal::body */

/* iconst: Module_Name
  Название модуля, к которому относится пакет.
*/
  Module_Name constant varchar2(30) := pkg_Mail.Module_Name;

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
  batchShortName sch_batch.batch_short_name%type
    := null;

/* ivar: isGotMessageDeleted
  Флаг удаления почтовых сообщений из ящика
  По-умолчанию (null) удалять.
*/
  isGotMessageDeleted integer := null;

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => Module_Name
    , objectName => 'pkg_MailInternal'
  );

/* ivar: loggerJava
  Интерфейсный объект к модулю Logging
  для использования в Java
*/
  loggerJava lg_logger_t := lg_logger_t.GetLogger(
    moduleName => Module_Name
    , objectName => 'Mail.pkg_Mail.java'
  );

/* func: GetIsGotMessageDeleted
  Возврат флага <isGotMessageDeleted>.
*/
function GetIsGotMessageDeleted
return integer
is
begin
  return pkg_MailInternal.isGotMessageDeleted;
end GetIsGotMessageDeleted;

/* proc: SetIsGotMessageDeleted
  Установка флага <isGotMessageDeleted>.
*/
procedure SetIsGotMessageDeleted(
  isGotMessageDeleted integer
)
is
begin
  pkg_MailInternal.isGotMessageDeleted :=
    SetIsGotMessageDeleted.isGotMessageDeleted;
end SetIsGotMessageDeleted;

/* proc: LogJava
  Интерфейсная процедура логгирования
  для использования в Java

  Параметры:
  levelCode                   - код уровня сообщения
  messageText                 - текст сообщения
*/
procedure LogJava(
  levelCode varchar2
  , messageText varchar2
)
is
begin
  loggerJava.Log(
    levelCode => levelCode
    , messageText => messageText
  );
end LogJava;

/* func: GetBatchShortName
  Возвращает наименование батча сеанса

  Параметры:
   forcedBatchShortName      - переопределение наименования
                               батча

  Возврат:
    - имя выполняемого батча
*/
function GetBatchShortName(
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
        sid = pkg_Common.GetSessionSid
        and v.serial# = pkg_Common.GetSessionSerial
      )
    into
      batchShortName
    from
      dual;
  end if;
  batchInited := true;
  return batchShortName;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка инициализации batchShortName' )
    , true
  );
end GetBatchShortName;

/* proc: InitCheckTime
  Инициализация проверки поступления запросов и команд
*/
procedure InitCheckTime
is
begin
  lastRequestCheck := null;
  lastCommandCheck := null;
end InitCheckTime;

/* proc: InitRequestCheckTime
  Инициализация проверки поступления команд и запросов
*/
procedure InitRequestCheckTime
is
begin
  lastRequestCheck := null;
end InitRequestCheckTime;


/* proc: InitHandler
  Инициализация обработчика

  Параметры:
    processName              - имя процесса
*/
procedure InitHandler(
  processName varchar2
)
is
begin
  pkg_TaskHandler.InitHandler(
    moduleName => Module_Name
    , processName => processName
  );
  lastRequestCheck := null;
  lastCommandCheck := null;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка инициализации обработчика' )
    , true
  );
end InitHandler;


/* func: WaitForCommand
  Ожидает команду, получаемую через pipe
  в случае если наступило время проверять команду
  с учётом <lastCommandCheck>.

  Параметры:
    command                  - команда для ожидания
    checkRequestTimeOut      - интервал для проверки ожидания запроса
                               Если задан интервал ожидания команды
                               вычисляется на основе переменной
                               (<lastRequestCheck>).
  Возврат:
    - получена ли команда
*/
function WaitForCommand(
  command varchar2
  , checkRequestTimeOut integer := null
)
return boolean
is
                                       -- Полученная команду
  recievedCommand varchar2( 50 );
                                       -- Возвращаемое значение
                                       -- функции
  isFinish boolean;
                                       -- Интервал для ожидания команды
                                       -- ( в секундах )
  waitTimeout number;
begin
  logger.Trace( 'WaitForStopCommand: start');
  pkg_TaskHandler.SetAction( 'idle' );
  logger.Trace( 'WaitForStopCommand: checkRequestTimeOut='
    || to_char( checkRequestTimeOut)
  );
                                       -- Наступило время проверять команду
                                       -- либо передан параметр интервала
                                       -- проверки запросов
  if checkRequestTimeOut is not null
    or pkg_TaskHandler.NextTime(
      checkTime => lastCommandCheck
      , timeout => CheckCommand_Timeout
    )
  then
    waitTimeout :=
       checkRequestTimeout
       - pkg_TaskHandler.TimeDiff( pkg_TaskHandler.GetTime, lastRequestCheck);
    logger.Trace( 'WaitForStopCommand: waitTimeout='
      || to_char( waitTimeout)
    );
                                       -- Проверяем поступление команды
    if pkg_TaskHandler.GetCommand(
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
      logger.Info('Получена команда "' || recievedCommand || '"');
    else
      isFinish := false;
    end if;
    lastCommandCheck := null;
  end if;
  pkg_TaskHandler.SetAction( '' );
  logger.Trace( 'WaitForStopCommand: end');
  return isFinish;
exception when others then
  pkg_TaskHandler.SetAction( '' );
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка обработки команды' )
    , true
  );
end WaitForCommand;

/* func: NextRequestTime
  Определяет истечение таймаута для проверки
  наличия запросов.
  Учитывается переменная <lastRequestCheck>.

  Параметр:
  checkRequestTimeOut                  - таймаут ожидания
                                         запроса( в секундах)
  Возврат:
    - наступило ли время проверять запрос
*/
function NextRequestTime(
  checkRequestTimeOut number
)
return boolean
is
  isOk boolean;
begin
  logger.Trace( 'NextRequestTime: lastRequestCheck='
    || to_char( lastRequestCheck)
  );
  isOk :=
    pkg_TaskHandler.NextTime(
      checkTime => lastRequestCheck
      , timeout => checkRequestTimeOut
    );
  logger.Trace( 'NextRequestTime: isOk='
    || case when isOk then 'true' else 'false' end
  );
  return isOk;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка проверки истечения таймаута' )
    , true
  );
end NextRequestTime;

/* proc: WaitForFetchRequestInternal
  Ожидание запроса извлечения сообщений без генерации
  exception в случае ошибки обработки

  Параметры:
    fetchRequestId          - id запроса
*/
procedure WaitForFetchRequestInternal(
  fetchRequestId integer
)
is
                                       -- Временная переменная
                                       -- для количества запросов в ожидании
  nCount integer;
                                       -- Время начала ожидания
  startWait number := pkg_TaskHandler.GetTime;
  waitingTimedOut boolean;
begin
  pkg_MailInternal.InitCheckTime;
  pkg_TaskHandler.SetAction('fetch mail wait');
  logger.Debug( 'WaitForFetchRequestInternal: start' );
  loop
                                       -- Наступило время проверять запрос
    if pkg_MailInternal.NextRequestTime(
      checkRequestTimeout => pkg_MailInternal.WaitRequest_Timeout
    )
    then
      logger.Trace( 'WaitForFetchRequestInternal: check start' );
      select
        count(1)
      into
        nCount
      from
        v_ml_fetch_request_wait
      where
        fetch_request_id = fetchRequestId;
      waitingTimedOut := pkg_TaskHandler.NextTime(
          checkTime => startWait
          , timeout => Max_Wait_Timeout
        );
      logger.Trace( 'WaitForFetchRequestInternal: check end' );
      exit when nCount = 0 or waitingTimedOut;
    else
      dbms_lock.sleep( pkg_MailInternal.WaitRequest_Timeout);
    end if;
  end loop;
  if waitingTimedOut then
    raise_application_error(
      pkg_Error.ProcessError
      , logger.ErrorStack(
          'Время ожидания (' || to_char( Max_Wait_Timeout) || ' c.) истекло'
        )
    );
  end if;
  logger.Debug( 'WaitForFetchRequestInternal: end' );
  pkg_TaskHandler.SetAction('');
exception when others then
  pkg_TaskHandler.SetAction('');
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Внутренняя ошибка ожидания запроса' )
    , true
  );
end WaitForFetchRequestInternal;

/* proc: WaitForFetchRequest
  Ожидание запроса извлечения сообщений

  Параметры:
    fetchRequestId          - id запроса
*/
procedure WaitForFetchRequest(
  fetchRequestId integer
)
is
                                       -- Переменные для считывания состояния
                                       -- обработки
  requestStateCode ml_fetch_request.request_state_code%type;
  errorMessage varchar2( 4000);
begin
  WaitForFetchRequestInternal( fetchRequestId => fetchRequestId);
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
    fetch_request_id = fetchRequestId;
  if requestStateCode = pkg_MailInternal.Error_RequestStateCode then
    raise_application_error(
      pkg_Error.ProcessError
      , logger.ErrorStack(
          'Возникла ошибка обработки запроса. Сообщение: '
          || chr(10)
          ||  '"' || errorMessage || '"'
        )
    );
  else
    logger.Debug('Запрос обработан( код состояния: "'
      || requestStateCode || '")'
    );
  end if;
end WaitForFetchRequest;

/* func: GetOptionStringValue
  Получает строковое значение опции

  Параметры:
  moduleOptionName            - имя опции, уникальное в пределах модуля
*/
function GetOptionStringValue(
  moduleOptionName varchar2
)
return varchar2
is
  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_Mail.Module_Name
  );
begin
  return
    optionList.getOptionString(
      moduleOptionName
    );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка получения строкового значения опции( '
        || ' moduleOptionName="' || moduleOptionName || '"'
        || ')'
      )
    , true
  );
end GetOptionStringValue;

end pkg_MailInternal;
/
