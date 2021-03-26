create or replace package body pkg_MailInternal is
/* package body: pkg_MailInternal::body */



/* group: ��������� */

/* iconst: CheckCommand_Timeout
  ������� ����� ���������� ������� ������ ��� ���������
  ( � �������� )
*/
CheckCommand_Timeout constant integer := 1;

/* iconst: WaitRequest_Timeout
  ������� ����� ���������� ��������� �������
  ( � �������� )
*/
WaitRequest_Timeout constant integer := 1;

/* iconst: Max_Wait_TimeOut
  ������������ ����� �������� ������� � ��������
*/
Max_Wait_TimeOut constant integer := 3600*2.5;



/* group: ���������� */

/* ivar: logger
  ������������ ������ � ������ Logging
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName => pkg_MailBase.Module_Name
  , objectName => 'pkg_MailInternal'
);

/* ivar: loggerJava
  ������������ ������ � ������ Logging
  ��� ������������� � Java
*/
loggerJava lg_logger_t := lg_logger_t.getLogger(
  moduleName => pkg_MailBase.Module_Name
  , objectName => 'Mail.pkg_Mail.java'
);

/* ivar: lastCommandCheck
  ����� ��������� �������� ������
*/
lastCommandCheck number := null;

/* ivar: lastRequestCheck
  ����� ��������� �������� �������
*/
lastRequestCheck number := null;

/* ivar: batchInited
  ����������� �� ���������� <batchShortName>
*/
batchInited boolean not null:= false;

/* ivar: batchShortName
  ������������ �������� ������������ � ������ ������ �����
*/
batchShortName sch_batch.batch_short_name%type := null;



/* group: ������� */

/* proc: logJava
  ������������ ��������� ������������
  ��� ������������� � Java

  ���������:
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������
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
  ���������� ������������ ����� ������

  ���������:
  forcedBatchShortName        - ��������������� ������������ �����

  �������:
  ��� ������������ �����.
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
        '������ ������������� batchShortName.'
      )
    , true
  );
end getBatchShortName;

/* proc: initCheckTime
  ������������� �������� ����������� �������� � ������
*/
procedure initCheckTime
is
begin
  lastRequestCheck := null;
  lastCommandCheck := null;
end initCheckTime;

/* proc: initRequestCheckTime
  ������������� �������� ����������� ������ � ��������
*/
procedure initRequestCheckTime
is
begin
  lastRequestCheck := null;
end initRequestCheckTime;

/* proc: initHandler
  ������������� �����������.

  ���������:
  processName                 - ��� ��������
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
        '������ ������������� �����������'
      )
    , true
  );
end initHandler;

/* func: waitForCommand
  ������� �������, ���������� ����� pipe
  � ������ ���� ��������� ����� ��������� �������
  � ������ <lastCommandCheck>.

  ���������:
  command                     - ������� ��� ��������
  checkRequestTimeOut         - �������� ��� �������� �������� �������
                                ���� ����� �������� �������� �������
                                ����������� �� ������ ����������
                                (<body::lastRequestCheck>).

  �������:
  �������� �� �������.
*/
function waitForCommand(
  command varchar2
  , checkRequestTimeOut integer := null
)
return boolean
is

  -- ���������� �������
  recievedCommand varchar2( 50 );

  -- ������������ �������� �������
  isFinish boolean;

  -- �������� ��� �������� ������� ( � �������� )
  waitTimeout number;

begin
  logger.trace( 'WaitForStopCommand: start');
  pkg_TaskHandler.setAction( 'idle' );
  logger.trace( 'WaitForStopCommand: checkRequestTimeOut='
    || to_char( checkRequestTimeOut)
  );

  -- ��������� ����� ��������� ������� ���� ������� �������� ���������
  -- �������� ��������
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

    -- ��������� ����������� �������
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
            , '�������� ����������� ����������� ������� "' || command || '".'
          );
      end case;
      logger.info('�������� ������� "' || recievedCommand || '"');
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
        '������ ��������� �������'
      )
    , true
  );
end waitForCommand;

/* func: nextRequestTime
  ���������� ��������� �������� ��� �������� ������� ��������.
  ����������� ���������� <body::lastRequestCheck>.

  ��������:
  checkRequestTimeOut         - ������� �������� �������( � ��������)

  �������:
  ��������� �� ����� ��������� ������.
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
        '������ �������� ��������� ��������'
      )
    , true
  );
end nextRequestTime;

/* iproc: waitForFetchRequestInternal
  �������� ������� ���������� ��������� ��� ��������� exception � ������
  ������ ���������.

  ���������:
  fetchRequestId              - Id �������
*/
procedure waitForFetchRequestInternal(
  fetchRequestId integer
)
is

  -- ��������� ���������� ��� ���������� �������� � ��������
  nCount integer;

  -- ����� ������ ��������
  startWait number := pkg_TaskHandler.getTime;
  waitingTimedOut boolean;

begin
  pkg_MailInternal.initCheckTime();
  pkg_TaskHandler.setAction('fetch mail wait');
  logger.debug( 'waitForFetchRequestInternal: start' );
  loop

    -- ��������� ����� ��������� ������
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
          '����� �������� (' || to_char( Max_Wait_Timeout) || ' c.) �������'
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
        '���������� ������ �������� �������.'
      )
    , true
  );
end waitForFetchRequestInternal;

/* proc: waitForFetchRequest
  �������� ������� ���������� ���������

  ���������:
  fetchRequestId              - Id �������
*/
procedure waitForFetchRequest(
  fetchRequestId integer
)
is

  -- ���������� ��� ���������� ��������� ���������
  requestStateCode ml_fetch_request.request_state_code%type;
  errorMessage varchar2( 4000);

begin

  waitForFetchRequestInternal( fetchRequestId => fetchRequestId);

  -- �������� ��������� ���������
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
          '�������� ������ ��������� �������. ���������: '
          || chr(10)
          ||  '"' || errorMessage || '"'
        )
    );
  else
    logger.debug('������ ���������( ��� ���������: "'
      || requestStateCode || '")'
    );
  end if;
end waitForFetchRequest;

end pkg_MailInternal;
/
