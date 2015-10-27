create or replace package body pkg_ProcessMonitorUtility is
/* package body: pkg_ProcessMonitorUtility::body */



/* group: ���������� */



/* ivar: logger
  ������������ ������ � ������ Logging
*/
  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName => pkg_ProcessMonitorBase.Module_Name
    , objectName => 'pkg_ProcessMonitorUtility'
  );



/* group: ������� */



/* func: getOperatorId
  ��������� id �������� ���������
*/
function getOperatorId
return integer
is
begin
  return
    pkg_Operator.getCurrentUserId;
exception when others then
  return
    1;
end getOperatorId;

/* proc: oraKill
  ���������� orakill ��� ������
*/
procedure oraKill(
  sid integer
  , serial# integer
)
is
  vSpid varchar2(20);
  -- ��� �������� ����������
  instanceName varchar2(16);
  -- ��������� ���������� ������ ����
  intValue binary_integer;
begin
  select
    p.spid
  into
    vSpid
  from
    v$session vs
    , v$process p
  where
    p.addr=vs.paddr
    and vs.sid = OraKill.sid
    and vs.serial# = OraKill.serial#
  ;
  if dbms_utility.get_parameter_value( 'instance_name', intValue, instanceName)
      != 1 then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Cann''t get instance name.'
    );
  end if;
  logger.debug(
    'sid = ' || to_char( sid)
    || ', serial# = ' || to_char( serial#) || ' - orakill ...'
  );
  pkg_FileOrigin.execCommand(
    'orakill.exe ' || instanceName || ' ' || vSpid
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ���������� oraKill ( '
        || 'sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ')'
      )
    , true
  );
end oraKill;

/* proc: abortBatch
  ��������� ���������� ������ �������

  ���������:
    batchId                  - id ������
    sid                      - sid ������ Oracle
    serial#                  - serial# ������ Oracle
*/
procedure abortBatch(
  batchId integer
  , sid integer
  , serial# integer
)
is
  pragma autonomous_transaction;
begin
  logger.info( '������� ���������� ������ ( '
    || 'batchId=' || to_char( batchId)
    || ', sid=' || to_char( sid)
    || ', serial#=' || to_char( serial#)
    || ')'
  );
  pkg_Scheduler.deactivateBatch(
    batchId => batchId
    , operatorId => pkg_Operator.getCurrentUserId
  );
  pkg_Scheduler.activateBatch(
    batchId => batchId
    , operatorId => pkg_Operator.getCurrentUserId
  );
  commit;
  execute immediate
    'alter system kill session '''
      || sid || ',' || serial# || ''' immediate'
   ;
  commit;
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ���������� ������ ������� ( '
        || 'sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ')'
      )
    , true
  );
end abortBatch;

/* func: getRegisteredSession
  ��������� id ������������������ ������.
  � ������, ���� ������ �� ���� ����������������,
  �� ������������ ������
*/
function getRegisteredSession(
  sid integer
  , serial# integer
) return integer
is
  pragma autonomous_transaction;
  -- id ������������������ ������
  registeredSessionId integer;
begin
  -- ������� ����� ������
  select
    max( registered_session_id)
  into
    registeredSessionId
  from
    v_prm_registered_session v
  where
    v.sid = getRegisteredSession.sid
    and v.serial# = getRegisteredSession.serial#
  ;
  -- ���� �� �����
  if registeredSessionId is null then
    insert into prm_registered_session(
      registered_session_id
      , sid
      , serial#
      , operator_id
    )
    values(
      prm_registered_session_seq.nextval
      , getRegisteredSession.sid
      , getRegisteredSession.serial#
      , getOperatorId
    )
    returning
      registered_session_id
    into
      registeredSessionId;
  end if;
  commit;
  return
    registeredSessionId;
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� id ������������������ ������ ( '
        || 'sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ')'
      )
    , true
  );
end getRegisteredSession;

/* proc: addAction
  ���������� ���������������� �������� ��� ������

  ���������:
    registeredSessionId      - id ������������������ ������
    dateTime                 - �������������� ���� ����������
                               null, ���� �������� ������ �����������
                               �� ���������� ������
    actionCode               - ��� ��������
    emailRecipient           - ���������� ���������, �������������
                               ��� ��������
    emailSubject             - ���� ������
*/
procedure addAction(
  registeredSessionId integer
  , dateTime date
  , actionCode varchar2
  , emailRecipient varchar2 := null
  , emailSubject varchar2 := null
)
is
begin
  -- �������� ������������ ������
  update
    prm_session_action s
  set
    s.email_recipient = emailRecipient
    , s.email_subject = emailSubject
    , s.execution_time = null
  where
    s.registered_session_id = registeredSessionId
    and s.session_action_code = actionCode
    and (
      s.planned_time = dateTime
      or coalesce( s.planned_time, dateTime) is null
    );
  -- ���� ������ ���, �� ���������
  if sql%rowcount = 0 then
    insert into prm_session_action(
      session_action_id
      , registered_session_id
      , session_action_code
      , planned_time
      , email_recipient
      , email_subject
      , operator_id
    )
    values(
      prm_session_action_seq.nextval
      , registeredSessionId
      , actionCode
      , dateTime
      , emailRecipient
      , emailSubject
      , GetOperatorId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ���������� ��������( '
        || 'registeredSessionId=' || to_char( registeredSessionId)
        || ', dateTime=' || to_char( dateTime)
        || ', actionCode="' || actionCode || '"'
        || ', emailRecipient= "' || emailRecipient || '"'
        || ', emailSubject="' || emailSubject || '"'
        || ')'
      )
    , true
  );
end addAction;

/* proc: deleteAction
  �������� ���������������� ��������
  ��� ������
*/
procedure deleteAction(
  registeredSessionId integer
  , dateTime date
  , actionCode varchar2
)
is
begin
  delete from
    prm_session_action s
  where
    s.registered_session_id = registeredSessionId
    and s.session_action_code = actionCode
    and (
      s.planned_time = dateTime
      or coalesce( s.planned_time, dateTime) is null
    );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ��������('
        || 'registeredSessionId=' || to_char( registeredSessionId)
        || ', dateTime=' || to_char( dateTime)
        || ', actionCode="' || actionCode || '"'
        || ')'
      )
    , true
  );
end deleteAction;

/* proc: clearRegisteredSession
  ������ ����������� ������������������ ������
*/
procedure clearRegisteredSession
is
begin
  for recCompleteSession in (
    select
      e.registered_session_id
      , e.sid
      , e.serial#
    from
      v_prm_session_existence e
    where
      e.exists_session = 0
      and
      -- ��� ��������������� �������� �� ����������
      not exists
      (
      select
        1
      from
        prm_session_action a
      where
        a.registered_session_id = e.registered_session_id
        and a.execution_time is null
        and a.planned_time is null
      )
   )
   loop
     update
       prm_registered_session r
     set
       r.is_finished = 1
     where
       r.registered_session_id = recCompleteSession.registered_session_id
     ;
     logger.Debug( '��������� ������ ('
       || ' registered_session_id='
       || to_char( recCompleteSession.registered_session_id)
       || ', sid=' || to_char( recCompleteSession.sid)
       || ', serial#=' || to_char( recCompleteSession.serial#)
       || ')'
     );
   end loop;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������� ����������� ������'
      )
    , true
  );
end clearRegisteredSession;

/* proc: completeAction
  �������� �������� ��� �����������
*/
procedure completeAction(
  registeredSessionId integer
  , dateTime date
  , actionCode varchar2
)
is
begin
  update
    prm_session_action s
  set
    s.execution_time = sysdate
  where
    s.registered_session_id = registeredSessionId
    and s.session_action_code = actionCode
    and (
      s.planned_time = dateTime
      or coalesce( s.planned_time, dateTime) is null
    );
  if sql%rowcount = 0 then
    raise_application_error(
      pkg_Error.ProcessError
      , logger.errorStack( '�������� �� �������')
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ���������� ��������('
        || 'registeredSessionId=' || to_char( registeredSessionId)
        || ', dateTime=' || to_char( dateTime)
        || ', actionCode="' || actionCode || '"'
        || ')'
      )
    , true
  );
end completeAction;

/* func: getOptionStringValue
  �������� ��������� �������� �����

  ���������:
    optionShortName          - �������� ������������
                               �����
*/
function getOptionStringValue(
  optionShortName varchar2
)
return varchar2
is
  -- �������� �����
  stringValue v_opt_option.string_value%type;
begin
  select
    string_value
  into
    stringValue
  from
    v_opt_option
  where
    option_short_name = optionShortName
  ;
  return
    stringValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ���������� �������� �����( '
        || 'optionShortName="' || optionShortName || '"'
        || ')'
      )
    , true
  );
end getOptionStringValue;

/* func: getDefaultTraceCopyPath
  ��������� ���������� ��� ����������� ������ �����������
  ��-���������.

  ������������ �������� ����� � �������������
  <pkg_ProcessMonitorBase.TraceCopyPath_OptionName>.
*/
function getDefaultTraceCopyPath
return varchar2
is
begin
  return
    opt_option_list_t( pkg_ProcessMonitorBase.Module_Name).getString(
      pkg_ProcessMonitorBase.TraceCopyPath_OptionName
      , raiseNotFoundFlag => 0
    );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ����� ���������� ��� ����������� ������'
        || ' �����������'
      )
    , true
  );
end getDefaultTraceCopyPath;

end pkg_ProcessMonitorUtility;
/
