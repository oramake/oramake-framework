create or replace package body pkg_MailHandler is
/* package body: pkg_MailHandler::body */

/* iconst: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := pkg_Mail.Module_Name;

/* iconst: CheckCommand_Timeout
  ������� ����� ���������� ������� ������
  ����������� �������� ���������
*/
CheckCommand_Timeout constant interval day to second := interval '1' second;

/* iconst: CheckNewRequest_Timeout
  ������� ����� ���������� �������
  ����� �������� ����������� �������� ���������
*/
CheckNewRequest_Timeout constant interval day to second := interval '6' second;

/* iconst: SendMessage_TimeLimit
  ����� ������� ��� �������� ���������
  ( ������������ ��� �������� ������)
*/
SendMessage_TimeLimit constant interval day to second := INTERVAL '3' MINUTE;

/* ivar: logger
  ������������ ������ � ������ Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_Mail.Module_Name
    , objectName => 'pkg_MailHanlder'
  );

/* itype: TColSmtpServer
  ��� ��������� ��� ������� smtp-��������
*/
  type TColSmtpServer is table of ml_message.smtp_server%type;

/* func: ParseSmtpServerList
  ��������� ������ �� ������� �������
  smtp-��������.

  smtpServerList              - ������ ��� ( ��� ip-�������) SMTP-��������
                                ����� ",". ������ ������ ��������������
                                � pkg_Common.GetSmtpServer.

  �������:
    - ��������� �������
*/
function ParseSmtpServerList(
  smtpServerList varchar2
)
return TColSmtpServer
is
                                       -- �������������� ���������
  colSmtpServer TColSmtpServer := TColSmtpServer();
                                       -- ��������� �� ������� � ������
  i integer := 1;
  j integer;
                                       -- ������� ��������� �������
  finished boolean := false;
                                       -- ����� ������ ������
                                       -- ��� smtp-��������
  lengthSmtpList integer := coalesce( length( smtpServerList),0);

begin
  i := 1;
  for safeLoop in 1..lengthSmtpList+2
  loop
    j := coalesce( instr( smtpServerList, ',', i, 1),0);
    if j = 0 then
      j := lengthSmtpList + 1;
      finished := true;
      logger.Trace( 'finished');
    end if;
    logger.Trace( 'i=' || to_char( i));
    logger.Trace( 'j=' || to_char( j));
                                     -- �������� ��������� �������
    colSmtpServer.extend;
    colSmtpServer( colSmtpServer.last)
      := coalesce(
           replace(
             substr( smtpServerList
                     , i
                     , j-i
                   )
             , ' '
           )
           , pkg_Common.GetSmtpServer
         );
    logger.Debug( 'add smtp: '
      || '"' || colSmtpServer( colSmtpServer.last) || '"'
    );
    exit when
      finished;
    i := j + 1;
  end loop;
  return
    colSmtpServer;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ������� ������ ������ ������� smtp('
        || 'smtpServerList="' || smtpServerList || '"'
        || ')'
      )
    , true
  );
end ParseSmtpServerList;

/* func: NotifyError
  ����������� �� ������� ( �� e-mail) � ���������� ����� ��������� ������.

  ���������:
  sendLimit                   - ����� �������, � ������� �������� ������ ����
                                ����������� ������� �������� ��������� ( ���
                                �������� null ����� ������������ �������� ��
                                ���������)
  smtpServerList              - ������ ��� ( ��� ip-�������) SMTP-��������
                                ����� ",". ������ ������ ��������������
                                � pkg_Common.GetSmtpServer.

  �������:
    - ���������� ������
*/
function NotifyError(
  sendLimit interval day to second := null
  , smtpServerList varchar2 := null
)
return integer
is

                                        --���� ��������
  checkTime timestamp with time zone := systimestamp;

                                        --����� ������
  nError integer := 0;
                                        --����� ���������
  msg varchar2( 30000);
                                        -- ��������� smtp-��������
  colSmtpServer TColSmtpServer;

  procedure ProcessSmtpServer(
    smtpServer varchar2
  )
  is
  -- ���������� ��������� �� �������
  -- �� ������� smtp
                                        --������������ smtp-������
    usedSmtpServer varchar2( 512 ) :=
      coalesce( smtpServer, pkg_Common.GetSmtpServer );
                                        -- ������ �� ���������
                                        -- ��� smtp-�������
    headerCreated boolean := false;

    cursor curError( minSendTime timestamp with time zone) is
      select
        1 as show_order
        , ms.error_code
        , coalesce(
            ms.error_message
            , '��������� �� ������������ ���������'
          )
          as error_message
        , count(*) as cnt
        , min( ms.date_ins) as min_date_ins
        , max( ms.date_ins) as max_date_ins
        , min( ms.process_date) as min_error_date
        , max( ms.process_date) as max_error_date
        , min( ms.send_date) as min_send_date
        , max( ms.send_date) as max_send_date
        , min( ms.message_id) as min_message_id
        , max( ms.message_id) as max_message_id
      from
        ml_message ms
      where
        ms.message_state_code = pkg_Mail.WaitSend_MessageStateCode
                                         -- ���� smtp_server ������ ��������� �
                                         -- smtpServer, ����, � ������ SMTP-�������
                                         -- ��-���������, ����� �������� null.
        and
        ( ms.smtp_server = usedSmtpServer
          or usedSmtpServer = pkg_Common.GetSmtpServer
          and ms.smtp_server is null
        )
        and (
          ms.error_code is not null
          or ms.send_date < minSendTime
          )
      group by
        ms.error_code
        , ms.error_message
      order by
        show_order
        , error_code nulls first
        , error_message
    ;
  -- ProcessSmtpServer
  begin
    pkg_TaskHandler.SetAction( 'ProcessSmtpServer('
      || smtpServer
      || ')'
    );
    for rec in curError(
      checkTime - coalesce( sendLimit, SendMessage_TimeLimit)
    )
    loop
                                        --��������� ����� ���������
      if not headerCreated then
        msg := substr( msg
          || chr(10)
          || chr(10)
          || '* SMTP Server: ' || to_char( usedSmtpServer )
          || chr(10)
          , 1
          , 30000
        );
        headerCreated := true;
      end if;
      nError := nError + rec.cnt;
      msg := substr( msg
        || chr( 10) || '* '
        || case when rec.error_code is null then
            rec.error_message
          else
            '������ ��������� � ����� ORA' || to_char( rec.error_code, '00000')
          end
          || ' - ' || to_char( rec.cnt) || ' ��.'
          || chr( 10)
        || case when rec.error_code is not null
              and rec.error_message is not null
              then
            chr( 10)
            || rec.error_message
            || chr( 10)
          end
        || chr( 10)
          || 'date_ins:   '
            || to_char( rec.min_date_ins, 'dd.mm.yy hh24:mi:ss')
            || case when rec.min_date_ins <> rec.max_date_ins then
                ' - '
                || to_char( rec.max_date_ins, 'dd.mm.yy hh24:mi:ss')
              end
            || chr( 10)
          || case when rec.min_error_date is not null then
             'error_date: '
            || to_char( rec.min_error_date, 'dd.mm.yy hh24:mi:ss')
            || case when rec.min_error_date <> rec.max_error_date then
                ' - '
                || to_char( rec.max_error_date, 'dd.mm.yy hh24:mi:ss')
              end
            || chr( 10)
            end
          || case when rec.min_send_date is not null then
             'send_date:  '
            || to_char( rec.min_send_date, 'dd.mm.yy hh24:mi:ss')
            || case when rec.min_send_date <> rec.max_send_date then
                ' - '
                || to_char( rec.max_send_date, 'dd.mm.yy hh24:mi:ss')
              end
            || chr( 10)
            end
          ||
             'message_id: '
            || to_char( rec.min_message_id)
            || case when rec.min_message_id <> rec.max_message_id then
                ' - '
                || to_char( rec.max_message_id)
              end
            || chr( 10)
        , 1, 30000)
      ;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '������ ���������� ��������� �� ������� ('
          || 'smtpServer="' || smtpServer || '"'
          || ')'
        )
      , true
    );
  end ProcessSmtpServer;
--NotifyError
begin
  colSmtpServer := ParseSmtpServerList(
    smtpServerList => smtpServerList
  );
                                        -- ��������� ���������
  for i in 1..colSmtpServer.count loop
    ProcessSmtpServer(
      smtpServer => colSmtpServer(i)
    );
  end loop;
                                        -- ���������� ������ �� �������
  if msg is not null then
    pkg_Common.SendMail(
      mailSender => pkg_Common.GetMailAddressSource( Module_Name)
      , mailRecipient => pkg_Common.GetMailAddressDestination
      , subject => Module_Name || ': error notification'
      , message =>
          rpad( '���� ��������: ', 35) || to_char( checkTime, 'dd.mm.yy hh24:mi:ss')
          || chr( 10)
          || rpad( '����������� �������� �� �����:', 35) ||
                to_char( checkTime - coalesce( sendLimit, SendMessage_TimeLimit)
                         , 'dd.mm.yy hh24:mi:ss' )
          || chr( 10)
          || msg
    );
  end if;
  return nError;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��� �������� ������ ��������� ���������.' )
    , true
  );
end NotifyError;
/* func: ClearExpiredMessage
  ������� ��������� � �������� ������ ����� � ���������� ����� ���������
  ���������.

  ���������:
  checkDate                   - ���� �������� ( �� ��������� ������� ����)

  ���������:
  ���� ��������� ������ � ������� ( �� source_message_id), �� ��� ����� �������
  ������ ������ �� ���� �������� ( �.�. ����� � ���� ��������� � �������
  ������� ���� �����).
  ��������� ��������� ��������� ��� ��������� ����� ����� ��������� ���������
  ���������.
*/
function ClearExpiredMessage(
  checkDate date := null
)
return integer
is
                                        --��������� ���������
  cursor curExpiredMessage( checkDate date) is
    select
      d.message_id
    from
      (
      select
        ms.message_id
        , (
          select
            level
          from
            ml_message t
          where
            ----�������� �������� ���������
            t.source_message_id is null
            ----�������� ��� ������� �� �����
            and not exists
              (
              select
                null
              from
                ml_message t2
              where
                t2.expire_date is null
                or t2.expire_date > checkDate
              start with
                t2.message_id = t.message_id
              connect by
                prior t2.message_id = t2.source_message_id
              )
          start with
            t.message_id = ms.message_id
          connect by
            prior t.source_message_id = t.message_id
          )
          as del_thread_level
      from
        ml_message ms
      where
        ms.expire_date <= checkDate
        and ms.parent_message_id is null
      ) d
    where
      d.del_thread_level is not null
    order by
      d.del_thread_level desc
      , d.message_id
  ;
                                        --����� ��������� ���������
  nDeleted integer := 0;


--ClearExpiredMessage
begin
  savepoint pkg_MailHandler_DeleteExpMsg;
  for rec in curExpiredMessage( coalesce( checkDate, sysdate)) loop
    begin
      delete from
        ml_attachment atc
      where
        atc.message_id in
          (
          select
            ms.message_id
          from
            ml_message ms
          start with
            ms.parent_message_id is null
            and ms.message_id = rec.message_id
          connect by
            prior ms.message_id = ms.parent_message_id
          )
      ;
      delete from
        ml_message t
      where
        t.message_id in
          (
          select
            ms.message_id
          from
            ml_message ms
          start with
            ms.parent_message_id is null
            and ms.message_id = rec.message_id
          connect by
            prior ms.message_id = ms.parent_message_id
          )
      ;
      nDeleted := nDeleted + 1;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '������ ��� �������� ��������� ('
          || ' message_id=' || to_char( rec.message_id)
          || ').'
        , true
      );
    end;
  end loop;
  return nDeleted;
exception when others then
  rollback to pkg_MailHandler_DeleteExpMsg;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
      '������ ��� �������� ��������� � �������� ������ ����� ('
      || ' checkDate=' || to_date( checkDate, 'dd.mm.yyyy hh24:mi:ss')
      || ').' )
    , true
  );
end ClearExpiredMessage;

/* func: ClearFetchRequest
  ������� ������� ���������� �� �����
  � ����� �������� �� �����������
  ����

  ���������:
  beforeDate                  - ����, �� ������� ������� �������
*/
procedure ClearFetchRequest(
  beforeDate date
)
is
--ClearFetchRequest
begin
  delete from
    ml_fetch_request
  where
    date_ins <= beforeDate;
  logger.Debug('������� �������: ' || to_char( SQL%RowCount));
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
      '������ ��� �������� �������� �� ���������� ('
      || ' beforeDate=' || to_date( beforeDate, 'dd.mm.yyyy hh24:mi:ss')
      || ').' )
    , true
  );
end ClearFetchRequest;

/* func: SendMessageJava
  �������� ��������� �������� ���������.
*/
function SendMessageJava(
  smtpServer varchar2
  , maxMessageCount number
)
return number
is
language java name '
Mail.sendMessage(
  java.lang.String
  , java.math.BigDecimal
)
return java.math.BigDecimal
';
/* func: SendMessage
  ���������� ��������� �������� ��������� � ���������� ����� ������������
  ���������.

  ���������:
  smtpServer                  - ��� ( ��� ip-�����) SMTP-�������
                                �������� null �������������� � pkg_Common.GetSmtpServer.
  maxMessageCount             - ����������� �� ���������� ������������ ���������
                                �� ���� ������ ���������. � ������ ��������
                                null, ����������� �� ������������.

  ���������:
  � ���������� ��������� <SendMessageJava> ���������� �������� ����������
  ����� ������� ������������� Email-���������.
*/
function SendMessage(
  smtpServer varchar2 := null
  , maxMessageCount integer := null
)
return integer
is

                                        --���������� ����������, �.�.
                                        --���������� � ������� ��������
  pragma autonomous_transaction;
                                        --����� ������������ ���������
  nSend integer := 0;

--SendMessage
begin
  nSend := SendMessageJava(
     coalesce( smtpServer, pkg_Common.GetSmtpServer )
    , maxMessageCount - nSend
  );
  return nSend;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��� �������� ��������� �������� ��������� ('
      || ' smtpServer="' || smtpServer || '"'
      || ').' )
    , true
  );
end SendMessage;
/* func: SendHandler
  ���������� �������� �����.

  ���������:
  smtpServerList              - ������ ��� ( ��� ip-�������) SMTP-��������
                                ����� ",".
                                �������� null �������������� � pkg_Common.GetSmtpServer.
  maxMessageCount             - ����������� �� ���������� ������������ ���������
                                �� ���� ������ ���������. � ������ ��������
                                null, ����������� �� ������������.

  ���������:
  � ���������� ��������� <body::SendMessage> ���������� �������� ����������.
*/
procedure SendHandler(
  smtpServerList varchar2 := null
  , maxMessageCount integer := null
)
is

                                        --���� ���������� ������
  isFinish boolean := false;
                                        --SID � serial# ������ �����������
  handlerSid number;
  handlerSerial number;
                                        --�������� ����������� �������
                                        --�������� � ��������
  checkCommandTimeout number;
                                        --����� ��������� �������� ������
  lastCommandCheck number;
                                        --����� ��������� ��������
  lastRequestCheck number;
                                        --�������� �������� � ��������
  checkRequestTimeout number;

                                        --��� ������� �������
  command varchar2(50) := null;
                                        --������� ������������� ���������
                                        --��������
  isProcessRequest boolean := false;
                                        --���������� ������������
                                        --���������
  sentMessageCount integer := 0;
                                        --��������� ��� smtp-��������
  colSmtpServer TColSmtpServer;

  procedure Initialize is
  --��������� ���������������� ��������

  --Initialize
  begin
                                        --�������������� ����������
    pkg_TaskHandler.InitHandler(
      moduleName                  => Module_Name
      , processName               => 'SendHandler'
         || '('
         || coalesce(
              case
                when length( smtpServerList ) > 25 then
                  substr( smtpServerList, 1, 15 ) || '...' ||
                  substr( smtpServerList, -7 )
                else
                  smtpServerList
              end
              , 'null' )
         || ')'
    );
                                        --���������� ��������
    checkCommandTimeout :=
      pkg_TaskHandler.ToSecond( CheckCommand_Timeout);
    checkRequestTimeout :=
      pkg_TaskHandler.ToSecond( CheckNewRequest_Timeout);
                                        --��������� �������������� ������
    handlerSid          := pkg_Common.GetSessionSid;
    handlerSerial       := pkg_Common.GetSessionSerial;
                                        -- ��������� ������ �������
    colSmtpServer := ParseSmtpServerList(
      smtpServerList => smtpServerList
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '������ ������������� �����������'
        )
      , true
    );
  end Initialize;

  procedure Clean is
  --��������� ������� ����� ����������� ������

  --Clean
  begin
                                        --������������� ���������� � ���������
    pkg_TaskHandler.SetAction( 'clean');
    pkg_TaskHandler.CleanHandler;
  end Clean;

  function CheckNewRequest
  return boolean
  is
  --�������� ����������� ����� ��������.

    isFound integer;

  --CheckNewRequest
  begin
    logger.Trace( 'check new request');
                                        -- ��������� ��������� �� ���������
                                        -- smtp-��������
    for i in 1..colSmtpServer.count loop
      select
        count(*)
      into
        isFound
      from
        ml_message ms
      where
        ms.message_state_code = pkg_Mail.WaitSend_MessageStateCode
                                         -- ���� smtp_server ������ ��������� �
                                         -- smtpServer, ����, � ������ SMTP-�������
                                         -- ��-���������, ����� �������� null.
        and
        ( ms.smtp_server = colSmtpServer(i)
          or colSmtpServer(i) = pkg_Common.GetSmtpServer
          and ms.smtp_server is null
        )
        and ms.send_date <= systimestamp
        and rownum <= 1
      ;
      if isFound > 0 then
        return true;
      end if;
    end loop;
    return false;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
           '������ ��� �������� ����������� ����� �������� ��� ���������.'
        )
      , true
    );
  end CheckNewRequest;

  procedure WaitEvent
  is
  --������� ����������� ������-���� �������.

                                        --������� �����
    currentTime number;
                                        --����� �������� (� 100-x �������)
    waitTimeout number;

  --WaitEvent
  begin
                                        --������������� ���������� � ���������
    logger.Trace( 'start wait event');
    pkg_TaskHandler.SetAction( 'idle');
    loop
                                        --���������� ������� ��������
      currentTime := pkg_TaskHandler.GetTime();
      waitTimeout :=
        checkRequestTimeout
          - pkg_TaskHandler.TimeDiff( currentTime, lastRequestCheck);
                                        --�������� ����������� �������
      if waitTimeout > 0
          or pkg_TaskHandler.NextTime( lastCommandCheck, checkCommandTimeout)
          then
        logger.Trace( 'get command: waitTimeout=' || waitTimeout);
        if pkg_TaskHandler.GetCommand( command, waitTimeout) then
          lastCommandCheck := null;
          exit;
        else
          lastCommandCheck := pkg_TaskHandler.GetTime();
        end if;
      end if;
                                        --�������� ��������� � ������� ��������
      if pkg_TaskHandler.NextTime( lastRequestCheck, checkRequestTimeout) then
        if CheckNewRequest then
          isProcessRequest := true;
          lastRequestCheck := null;
          exit;
        end if;
      end if;
    end loop;
  end WaitEvent;

  procedure ProcessRequest
  is
  --��������� �������.
                                        --����� ������������ ���������
    nSend integer;

  --ProcessRequest
  begin
    logger.Trace( 'process request');
                                       -- ������������� ���������� � ���������
    pkg_TaskHandler.SetAction( 'send mail');
                                       -- ��������� �������� ���������
                                       -- c ������������ �� ���������� �������
                                       -- ��� ������� smtp-�������
    for i in 1..colSmtpServer.count loop
      nSend := SendMessage(
        smtpServer => colSmtpServer(i)
        , maxMessageCount => maxMessageCount - sentMessageCount
      );
      logger.Trace( 'sent count: ' || nSend);
      sentMessageCount := sentMessageCount + nSend;
                                       -- ���� ��������� ����������� ����������
                                       -- ���������� ���������, �� �������
                                       -- �� ����� SendHandler
      if sentMessageCount >= maxMessageCount then
        isFinish := true;
        exit;
      end if;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(  '������ ��� �������� ���������.' )
      , true
    );
  end ProcessRequest;

  procedure ProcessCommand
  is
  --��������� �������, ���������� ����� ����������� ����.

  --ProcessCommand
  begin
    logger.Trace( 'process command: ' || command);
    pkg_TaskHandler.SetAction( 'process command', command);
                                    --������������ �������
    case command
      when pkg_TaskHandler.Stop_Command then
        isFinish := true;
      else
        raise_application_error(
          pkg_Error.IllegalArgument
          , '�������� ����������� ����������� ������� "' || command || '".'
        );
    end case;
  end ProcessCommand;

  procedure ProcessEvent
  is
  --������������ �������.

  --ProcessEvent
  begin
    case
                                        --������������ �������
      when command is not null then
        ProcessCommand;
        command := null;
                                        --��������� �������
      when isProcessRequest then
        ProcessRequest;
        isProcessRequest := false;
      else
        raise_application_error(
          pkg_Error.ProcessError
          , '�������� ����������� ������� ������ ����� ���������.'
        );
    end case;
  end ProcessEvent;

--SendHandler
begin
  Initialize;                           --��������� ���������������� ��������
  loop
    WaitEvent;                          --���� �������
    ProcessEvent;                       --������������ �������
    exit when isFinish;                 --�������, ���� ���������� ����
  end loop;
  Clean;                                --��������� ������� ����� �������
exception when others then
  Clean;                                --��������� ������� ����� �������
  raise;
end SendHandler;

/* func: ProcessFetchRequest
  ��������� ������� �������� �� ���������� �� ������

  ���������:
    batchShortName                     - ��������� �������� ������ ��
                                         ������������ ����������� �����
    fetchRequestId                     - �������� ��� ���������
                                         ������������ �������

  �������:
    - ���������� ������������ ��������
*/
function ProcessFetchRequest(
  batchShortName varchar2 := null
  , fetchRequestId integer := null
)
return integer
is

  cursor curLockFetchRequest(
    fetchRequestId integer
    , batchShortName varchar2
    , maxRequestCount integer
  )
  is
                                       -- ��� �������������
                                       -- ������� �� ���������� �����
    select /*+ordered*/
      r.fetch_request_id as fetch_request_id
      , r.url as url
      , r.password as password
      , r.recipient_address as recipient_address
      , r.is_got_message_deleted as is_got_message_deleted
    from
      ml_fetch_request r
    where
      fetch_request_id in
      (
      select
        fetch_request_id
      from
      (
      select
        fetch_request_id
      from
        v_ml_fetch_request_wait w
      where
                                       -- ���� �����. �������� �� �����
                                       -- �� ������� �� �����������
        ( fetchRequestId is null
          or w.fetch_request_id = fetchRequestId
        )
        and
        ( batchShortName is null
          or batchShortName = batch_short_name
        )
                                       -- ������ ��� �� ��������� ������
                                       -- �������
        and
        (
          handler_sid is null
          or not exists
          (
          select
            null
          from
            v$session ss
          where
            ss.sid = w.handler_sid
            and ss.serial# = w.handler_serial#
          )
        )
                                     -- ������������� ������
                                     -- ��� ������� � ������
      order by
        w.priority_order desc nulls last
        , w.fetch_request_id
      )
    where
      rownum <= maxRequestCount
    )
    for update of
      r.request_state_code
      , r.handler_sid
      , r.handler_serial#
      , r.handler_reserved_time
      , r.processed_time
      , r.result_message_count
    nowait;
                                       -- �������� ������ ���������
  handlerSid number := pkg_Common.GetSessionSid;
  handlerSerial# number := pkg_Common.GetSessionSerial;
                                       -- ����������� ������
  recRequest curLockFetchRequest%rowtype;
                                       -- ������� �� ������� ������
  gotRequest boolean;
                                       -- ���������� ��������� �������
  fetchedCount integer;
  errorMessage varchar2( 4000);
  errorCode integer;
  requestStateCode ml_fetch_request.request_state_code%type;
                                       -- ���������� ������������ �������
  nProcessed integer := 0;
                                       -- ���������� ������
  nError integer := 0;

  procedure ReserveRequest
  is

    procedure GetRequest
    is
    -- �������� ������� � ��������� �������
    begin
      gotRequest := false;
      open
        curLockFetchRequest(
          fetchRequestId => fetchRequestId
          , batchShortName => batchShortName
          , maxRequestCount => 1
        );
                                       -- ��������� ������ �� �������
      fetch
        curLockFetchRequest
      into
        recRequest;
      gotRequest := curLockFetchRequest%FOUND;

      close curLockFetchRequest;
    exception when others then
      if curLockFetchRequest%ISOPEN then
        close curLockFetchRequest;
      end if;
                                       -- ���� �� ������ ���������������
      if SQLCODE = pkg_Error.ResourceBusyNowait then
        logger.Debug( 'Could not lock request: resource busy');
      else
        logger.Error( 'Could not lock request: ' || SQLERRM);
      end if;
    end GetRequest;

  begin
    pkg_TaskHandler.SetAction( 'reserve' );
                                       -- �������� id �������
    GetRequest;
                                       -- ������ �������
    if gotRequest then
                                       -- ����������� ������� ��������� ������
      update
        ml_fetch_request r
      set
        r.handler_sid = handlerSid
        , r.handler_serial# = handlerSerial#
        , r.handler_reserved_time = systimestamp
        , r.handler_batch_short_name = pkg_MailInternal.GetBatchShortName
      where
        r.fetch_request_id = recRequest.fetch_request_id;
      logger.Debug('��������������� ������'
        || '( fetch_request_id='
        || to_char( recRequest.fetch_request_id) || ')'
      );
    end if;
    pkg_TaskHandler.SetAction( '' );
  exception when others then
    pkg_TaskHandler.SetAction( '' );
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( '������ �������������� �������' )
      , true
    );
  end ReserveRequest;

  procedure ProcessRequest
  -- ��������� ��������� �����������
  -- ������
  is
  -- ProcessRequest
  begin
    pkg_TaskHandler.SetAction( 'process fetch' );
    logger.Debug('fetch start: (fetch_request_id='
      || to_char( recRequest.fetch_request_id) || ')'
    );
    fetchedCount := pkg_Mail.FetchMessageImmediate(
      url => recRequest.url
      , password => recRequest.password
      , recipientAddress => recRequest.recipient_address
      , isGotMessageDeleted => recRequest.is_got_message_deleted
      , fetchRequestId => recRequest.fetch_request_id
      , errorMessage => errorMessage
      , errorCode => errorCode
    );
    logger.Debug('fetch finish: (fetch_request_id='
      || to_char( recRequest.fetch_request_id) || ')'
    );
                                       -- ����������� ��������
    if errorMessage is not null then
      nError := nError + 1;
      requestStateCode := pkg_MailInternal.Error_RequestStateCode;
    else
      nProcessed := nProcessed + 1;
      requestStateCode := pkg_MailInternal.Processed_RequestStateCode;
    end if;
    pkg_TaskHandler.SetAction( '' );
  exception when others then
    pkg_TaskHandler.SetAction( '' );
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          '������ ��������� ������ request_id:'
          || '( fetch_request_id='
          || to_char( recRequest.fetch_request_id) || ')'
        )
      , true
    );
  end ProcessRequest;

  procedure UpdateRequest
  is
  -- ���������� ���������� � ��������
  begin
    pkg_TaskHandler.SetAction( 'update request' );
    update
      ml_fetch_request r
    set
      request_state_code = requestStateCode
      , error_code = errorCode
      , error_message = errorMessage
      , processed_time  = systimestamp
      , result_message_count = fetchedCount
    where
      fetch_request_id = recRequest.fetch_request_id
    ;
    logger.Debug('���������� ������ ���������: "'
      || requestStateCode || '"');
    pkg_TaskHandler.SetAction( '' );
  exception when others then
    pkg_TaskHandler.SetAction( '' );
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( '������ ���������� ��������� ��������' )
      , true
    );
  end UpdateRequest;

begin
  loop
                                       -- ����������� ������ ��� ���������,
                                       -- ������� ���������� � ������
    ReserveRequest;
    commit;
    exit when not gotRequest;
                                       -- ������������ ������
    ProcessRequest;
                                       -- ��������� ������
    UpdateRequest;
    commit;
  end loop;
  if nProcessed > 0 or nError > 0 then
    logger.Debug(
      '����������: '
      || to_char( nProcessed)
      || '; ������: ' || to_char( nError)
    );
  end if;
  commit;
  return nProcessed + nError;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ��������� �������� ���������� �� ������.'
      )
    , true
  );
end ProcessFetchRequest;

/* proc: FetchHandler
  ���������� �������� �� ���������� �� ������

  ���������:
    checkRequestInterval               - �������� ��� �������� ������� ��������
                                         ��� ���������
    maxRequestCount                    - ������������ ����������
                                         �������������� �������� �� ������
    batchShortName                     - �������� ��� ��������� �������� ������ ��
                                         ������������ ����������� �����
*/
procedure FetchHandler(
  checkRequestInterval interval day to second
  , maxRequestCount integer := null
  , batchShortName varchar2 := null
)
is
                                       -- ���������� ��������
                                       -- ��� ������� ��������� ������� ���������
  nCount integer := 0;
                                       -- ��������� ������ ProcessFetchRequest
  nLastCount integer;
                                       -- �������� ����� ����������
                                       -- ������� ��������
  checkRequestTimeout number
    := pkg_TaskHandler.ToSecond( checkRequestInterval );
begin
  pkg_MailInternal.InitHandler(
    processName  => 'FetchHandler'
  );
  logger.Debug( 'HandleRequest: checkRequestTimeout='
    || to_char( checkRequestTimeout)
  );
  loop
                                       -- ��������� ����� ��������� ������
    if pkg_MailInternal.NextRequestTime(
      checkRequestTimeout => checkRequestTimeout
    )
    then
                                       -- ��������� �������,
                                       -- ���� ��������� �����
      if pkg_MailInternal.WaitForCommand(
           command => pkg_TaskHandler.Stop_Command
        )
      then
        exit;
      end if;
                                       -- ��������� ��� �������������
                                       -- �������� � ��������� ��������
      nLastCount :=
         ProcessFetchRequest(
            batchShortName => batchShortName
         );
                                       -- ���� ������� ���� ����������
      if nLastCount > 0 then
        nCount := nCount + nLastCount;
                                       -- ���� ��������� �����, �������
                                       -- �� ��������� �����������
        if nCount >= maxRequestCount then
          exit;
        end if;
        pkg_MailInternal.InitRequestCheckTime;
      end if;
    else
                                       -- ����� �������� ������� �� ���������
                                       -- ����� ��������� �������
                                       -- � ������ ��������� �������� �������
      if pkg_MailInternal.WaitForCommand(
        command => pkg_TaskHandler.Stop_Command
        , checkRequestTimeOut => checkRequestTimeout
      )
      then
        exit;
      end if;
    end if;
  end loop;
  pkg_TaskHandler.CleanHandler;
exception when others then
  pkg_TaskHandler.CleanHandler;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ����������� �������� ���������� �� ������.'
      )
    , true
  );
end FetchHandler;


end pkg_MailHandler;
/
