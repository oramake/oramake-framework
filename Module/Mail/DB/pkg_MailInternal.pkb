create or replace package body pkg_MailInternal is
/* package body: pkg_MailInternal::body */

/* iconst: Module_Name
  �������� ������, � �������� ��������� �����.
*/
  Module_Name constant varchar2(30) := pkg_Mail.Module_Name;

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
  batchShortName sch_batch.batch_short_name%type
    := null;

/* ivar: isGotMessageDeleted
  ���� �������� �������� ��������� �� �����
  ��-��������� (null) �������.
*/
  isGotMessageDeleted integer := null;

/* ivar: logger
  ������������ ������ � ������ Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => Module_Name
    , objectName => 'pkg_MailInternal'
  );

/* ivar: loggerJava
  ������������ ������ � ������ Logging
  ��� ������������� � Java
*/
  loggerJava lg_logger_t := lg_logger_t.GetLogger(
    moduleName => Module_Name
    , objectName => 'Mail.pkg_Mail.java'
  );

/* func: GetIsGotMessageDeleted
  ������� ����� <isGotMessageDeleted>.
*/
function GetIsGotMessageDeleted
return integer
is
begin
  return pkg_MailInternal.isGotMessageDeleted;
end GetIsGotMessageDeleted;

/* proc: SetIsGotMessageDeleted
  ��������� ����� <isGotMessageDeleted>.
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
  ������������ ��������� ������������
  ��� ������������� � Java

  ���������:
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������
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
  ���������� ������������ ����� ������

  ���������:
   forcedBatchShortName      - ��������������� ������������
                               �����

  �������:
    - ��� ������������ �����
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
    , logger.ErrorStack( '������ ������������� batchShortName' )
    , true
  );
end GetBatchShortName;

/* proc: InitCheckTime
  ������������� �������� ����������� �������� � ������
*/
procedure InitCheckTime
is
begin
  lastRequestCheck := null;
  lastCommandCheck := null;
end InitCheckTime;

/* proc: InitRequestCheckTime
  ������������� �������� ����������� ������ � ��������
*/
procedure InitRequestCheckTime
is
begin
  lastRequestCheck := null;
end InitRequestCheckTime;


/* proc: InitHandler
  ������������� �����������

  ���������:
    processName              - ��� ��������
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
    , logger.ErrorStack( '������ ������������� �����������' )
    , true
  );
end InitHandler;


/* func: WaitForCommand
  ������� �������, ���������� ����� pipe
  � ������ ���� ��������� ����� ��������� �������
  � ������ <lastCommandCheck>.

  ���������:
    command                  - ������� ��� ��������
    checkRequestTimeOut      - �������� ��� �������� �������� �������
                               ���� ����� �������� �������� �������
                               ����������� �� ������ ����������
                               (<lastRequestCheck>).
  �������:
    - �������� �� �������
*/
function WaitForCommand(
  command varchar2
  , checkRequestTimeOut integer := null
)
return boolean
is
                                       -- ���������� �������
  recievedCommand varchar2( 50 );
                                       -- ������������ ��������
                                       -- �������
  isFinish boolean;
                                       -- �������� ��� �������� �������
                                       -- ( � �������� )
  waitTimeout number;
begin
  logger.Trace( 'WaitForStopCommand: start');
  pkg_TaskHandler.SetAction( 'idle' );
  logger.Trace( 'WaitForStopCommand: checkRequestTimeOut='
    || to_char( checkRequestTimeOut)
  );
                                       -- ��������� ����� ��������� �������
                                       -- ���� ������� �������� ���������
                                       -- �������� ��������
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
                                       -- ��������� ����������� �������
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
            , '�������� ����������� ����������� ������� "' || command || '".'
          );
      end case;
      logger.Info('�������� ������� "' || recievedCommand || '"');
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
    , logger.ErrorStack( '������ ��������� �������' )
    , true
  );
end WaitForCommand;

/* func: NextRequestTime
  ���������� ��������� �������� ��� ��������
  ������� ��������.
  ����������� ���������� <lastRequestCheck>.

  ��������:
  checkRequestTimeOut                  - ������� ��������
                                         �������( � ��������)
  �������:
    - ��������� �� ����� ��������� ������
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
    , logger.ErrorStack( '������ �������� ��������� ��������' )
    , true
  );
end NextRequestTime;

/* proc: WaitForFetchRequestInternal
  �������� ������� ���������� ��������� ��� ���������
  exception � ������ ������ ���������

  ���������:
    fetchRequestId          - id �������
*/
procedure WaitForFetchRequestInternal(
  fetchRequestId integer
)
is
                                       -- ��������� ����������
                                       -- ��� ���������� �������� � ��������
  nCount integer;
                                       -- ����� ������ ��������
  startWait number := pkg_TaskHandler.GetTime;
  waitingTimedOut boolean;
begin
  pkg_MailInternal.InitCheckTime;
  pkg_TaskHandler.SetAction('fetch mail wait');
  logger.Debug( 'WaitForFetchRequestInternal: start' );
  loop
                                       -- ��������� ����� ��������� ������
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
          '����� �������� (' || to_char( Max_Wait_Timeout) || ' c.) �������'
        )
    );
  end if;
  logger.Debug( 'WaitForFetchRequestInternal: end' );
  pkg_TaskHandler.SetAction('');
exception when others then
  pkg_TaskHandler.SetAction('');
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '���������� ������ �������� �������' )
    , true
  );
end WaitForFetchRequestInternal;

/* proc: WaitForFetchRequest
  �������� ������� ���������� ���������

  ���������:
    fetchRequestId          - id �������
*/
procedure WaitForFetchRequest(
  fetchRequestId integer
)
is
                                       -- ���������� ��� ���������� ���������
                                       -- ���������
  requestStateCode ml_fetch_request.request_state_code%type;
  errorMessage varchar2( 4000);
begin
  WaitForFetchRequestInternal( fetchRequestId => fetchRequestId);
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
    fetch_request_id = fetchRequestId;
  if requestStateCode = pkg_MailInternal.Error_RequestStateCode then
    raise_application_error(
      pkg_Error.ProcessError
      , logger.ErrorStack(
          '�������� ������ ��������� �������. ���������: '
          || chr(10)
          ||  '"' || errorMessage || '"'
        )
    );
  else
    logger.Debug('������ ���������( ��� ���������: "'
      || requestStateCode || '")'
    );
  end if;
end WaitForFetchRequest;

/* func: GetOptionStringValue
  �������� ��������� �������� �����

  ���������:
  moduleOptionName            - ��� �����, ���������� � �������� ������
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
        '������ ��������� ���������� �������� �����( '
        || ' moduleOptionName="' || moduleOptionName || '"'
        || ')'
      )
    , true
  );
end GetOptionStringValue;

end pkg_MailInternal;
/
