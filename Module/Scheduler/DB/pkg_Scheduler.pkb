create or replace package body pkg_Scheduler is
/* package body: pkg_Scheduler::body */



/* group: ��������� */

/* const: Default_RunDate
  ���� ������� ������, ������������ �� ��������� ��� ���������� ����������.
*/
Default_RunDate constant date := date '4000-01-01';

/* iconst: Default_NlsLanguage
  �������� NLS_LANGUAGE ��-���������.
*/
Default_NlsLanguage constant varchar2(40) := 'AMERICAN';



/* group: ���� */



/* group: ���������� ��������� ������� */

/* itype: VariableNameT
  ��� ��� ����� ����������.
*/
subtype VariableNameT is varchar2(100);

/* itype: ValueColT
  �������� ���������� ( ��� ���������� ����� ���� ����� ������ ��������).
*/
type ValueColT is table of anydata;

/* itype: VariableT
  ����������.
*/
type VariableT is record
(
  valueCol ValueColT
  , isConstant boolean
);

/* itype: VariableColT
  ������ ����������.
*/
type VariableColT is table of VariableT index by VariableNameT;



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_Scheduler'
);

/* ivar: gBatchLevel
  ������� ����������� �������� ������������ ������ (������� � 1).
*/
gBatchLevel pls_integer;

/* ivar: gVariableCol
  ������ ����������.
*/
gVariableCol VariableColT;

/* ivar: gSendNotifyFlag
  ���� �������������� �������� ����������� �� �������/��������������� ���
  ���������� �������.
*/
gSendNotifyFlag integer := 1;



/* group: ������� */



/* group: ������������ ������� */

/* iproc: checkPrivilege
  ��������� ������� ���� � ���������.

  ���������:
  operatorId                  - Id ���������
                                ( null ��� �������� �������� ���������)
  batchId                     - Id ������
  privilegeCode               - ��� ����������
  moduleId                    - Id ������

  ���������:
  - ���� ������ moduleId, �� ����������� ����� �� ��� ������ ������
    ( batchId ������������);
*/
procedure checkPrivilege(
  operatorId integer
  , batchId integer
  , privilegeCode varchar2
  , moduleId integer := null
)
is

  -- Id ���������, ��� �������� ����������� �����
  checkOperatorId integer;

  -- ��������� ��������
  isOk integer;

-- checkPrivilege
begin
  checkOperatorId := coalesce( operatorId, pkg_Operator.getCurrentUserId());
  if moduleId is not null then
    select
      1 as is_ok
    into isOk
    from
      dual
    where
      exists
        (
        select
          null
        from
          v_sch_role_privilege rp
          inner join v_op_operator_role opr
            on opr.role_id = rp.role_id
        where
          rp.module_id = moduleId
          and rp.privilege_code = privilegeCode
          and opr.operator_id = checkOperatorId
        )
    ;
  else
    select
      1 as is_ok
    into isOk
    from
      dual
    where
      exists
        (
        select
          null
        from
          v_sch_role_privilege rp
          inner join v_op_operator_role opr
            on opr.role_id = rp.role_id
        where
          rp.batch_id = batchId
          and rp.privilege_code = privilegeCode
          and opr.operator_id = checkOperatorId
        )
    ;
  end if;
exception when NO_DATA_FOUND then
  raise_application_error(
    pkg_Error.RigthIsMissed
    , '� ��������� ����������� ����������� ���������� �� ������ � '
      || case when moduleId is not null then
          '�������� ������'
         else
          '�������'
        end
      || ' ('
      || ' operator_id=' || operatorId
      || case when nullif( checkOperatorId, operatorId) is not null then
          ', checkOperatorId=' || checkOperatorId
        end
      || case when moduleId is not null then
          ', module_id=' || moduleId
        else
          ', batch_id=' || batchId
        end
      || ', privilege_code="' || privilegeCode || '"'
      || ').'
  );
end checkPrivilege;



/* group: �������� ������� */

/* func: getOracleJobName
  ��������� ����� ������� dbms_scheduler.

  ���������:
  batchId                     - id �����
*/
function getOracleJobName(
  batchId integer
)
return varchar2
is
-- getOracleJobName
begin
  return 'SCHEDULER_' || to_char(batchId);
end getOracleJobName;

/* proc: updateBatch
  �������� �����.

  ���������:
  batchId                     - Id ������
  batchName                   - �������� ������
  retrialCount                - ����� ������������
  retrialTimeout              - �������� ����� �������������
  operatorId                  - Id ���������
*/
procedure updateBatch(
  batchId integer
  , batchName varchar2
  , retrialCount integer
  , retrialTimeout interval day to second
  , operatorId integer
)
is

  cursor curBatch( batchId integer) is
    select
      b.*
    from
      sch_batch b
    where
      b.batch_id = batchId
    for update nowait
  ;

  -- ���� ������� ������
  isFound boolean := false;

-- updateBatch
begin
  for rec in curBatch( batchId) loop
    isFound := true;

    checkPrivilege( operatorId, batchId, Write_PrivilegeCode);

    if coalesce( rec.batch_name_rus <> batchName
            , coalesce( rec.batch_name_rus, batchName) is not null)
        or coalesce( rec.retrial_count <> retrialCount
            , coalesce( rec.retrial_count, retrialCount) is not null)
        or coalesce( rec.retrial_timeout <> retrialTimeout
            , coalesce( rec.retrial_timeout, retrialTimeout) is not null)
        then

      update
        sch_batch b
      set
        b.batch_name_rus = batchName
        , b.retrial_count = retrialCount
        , b.retrial_timeout = retrialTimeout
      where current of curBatch;
    end if;
  end loop;

  -- �������� �� ���������� ������
  if not isFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '����� �� ������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� ��������� ������ �������� ������ ('
      || ' batch_id=' || to_char( batchId)
      || ').'
    , true
  );
end updateBatch;

/* proc: activateBatch
  ������ ����� ������� �� ���������� � ������������ � ����������� (����
  ������������� ���� ������� � �������� ������������ ����������������� ���
  �������������� �� ���������� ������).  ������� ����� ��������� ������� (����
  �� ��� ����������).

  ���������:
  batchId                     - Id �������
  operatorId                  - Id ���������
*/
procedure activateBatch(
  batchId integer
  , operatorId integer
)
is
  -- ���������� �����
  cursor curBatch( batchId integer) is
    select
      b.batch_id
      , b.batch_short_name
      , b.batch_name_rus
      , b.oracle_job_id
      , b.retrial_number
      , (
        select
          b.batch_id
        from
          user_scheduler_jobs j
        where
          -- getOracleJobName
          j.job_name = 'SCHEDULER_' || to_char(b.batch_id)
        )
        as current_job_id
      , (
        select
          j.next_run_date
        from
          user_scheduler_jobs j
        where
          -- getOracleJobName
          j.job_name = 'SCHEDULER_' || to_char(b.batch_id)
        )
        as next_date
      , b.nls_territory
      , b.nls_language
    from
      sch_batch b
    where
      b.batch_id = batchId
    for update of b.oracle_job_id nowait
  ;

  rec curBatch%rowtype;

  -- ��� ������, ��������� � ���
  batchLogName varchar2(500);
  info varchar2(4000);
  -- �������������� ��������� ����� ���� ������� ������
  newDate date;

  -- ���������� NLS-��������� ������
  sessionNlsLanguage varchar2(40);
  sessionNlsTerritory varchar2(40);

  -- ��� job ��� dbms_scheduler
  oracleJobName varchar(1000);

  /*
    ���������� ���������� NLS ������.
  */
  procedure saveNlsParameter
  is
  begin
    select
      value
    into
      sessionNlsLanguage
    from
      nls_session_parameters
    where
      parameter = 'NLS_LANGUAGE'
    ;
    select
      value
    into
      sessionNlsTerritory
    from
      nls_session_parameters
    where
      parameter = 'NLS_TERRITORY'
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ ���������� NLS-���������� ������'
      , true
    );
  end saveNlsParameter;

  /*
    ��������� NLS-���������� ��� �����.
  */
  procedure setBatchNlsParameter
  is
    usedNlsLanguage varchar2(40) := coalesce( rec.nls_language, Default_NlsLanguage);
  begin
    if sessionNlsLanguage <> usedNlsLanguage then
      execute immediate
        'alter session set nls_language=''' || usedNlsLanguage || '''';
    end if;
    -- ���� ������ ���� ������, ����� ������ �������� ������
    if sessionNlsTerritory <> rec.nls_territory then
      execute immediate
        'alter session set nls_territory=''' || rec.nls_territory || '''';
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ ��������� NLS-����������'
      , true
    );
  end setBatchNlsParameter;

  /*
    �������������� NLS ���������� ������.
  */
  procedure restoreNlsParameters
  is
  begin
    if sessionNlsLanguage <> coalesce( rec.nls_language, Default_NlsLanguage) then
      execute immediate
        'alter session set nls_language=''' || sessionNlsLanguage || ''''
      ;
    end if;
    if sessionNlsTerritory <> rec.nls_territory then
      execute immediate
        'alter session set nls_territory=''' || sessionNlsTerritory || ''''
      ;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ �������������� NLS-����������'
      , true
    );
  end restoreNlsParameters;

--ActivateBatch
begin
  saveNlsParameter();
  savepoint pkg_Scheduler_ActivateBatch;
  -- ��������� ����� �������
  checkPrivilege(operatorId, batchId, Exec_PrivilegeCode);
  pkg_Operator.setCurrentUserId( operatorId => operatorId);
  open curBatch( batchId);
  fetch curBatch into rec;
  -- ������ ��������� ��� ���������� ������
  if curBatch%NOTFOUND then
    raise_application_error(
      pkg_Error.BatchNotFound
      , '����� �� ������.'
    );
  end if;
  setBatchNlsParameter();
  batchLogName :=
    '"' || rec.batch_name_rus || '" [' || rec.batch_short_name || ']';
  -- ����������� ���� �������
  newDate := calcNextDate(batchId);
  -- ������, ���� ���������� �� ������
  if newDate is null then
    raise_application_error(
      pkg_Error.ScheduleNotSet
      , '�� ������ ���������� ������� ������.'
    );
  end if;
  oracleJobName := getOracleJobName(batchId => rec.batch_id);
  -- ��������� ����� ������� Oracle
  if rec.current_job_id is null then
    logger.trace('create_job: ' || oracleJobName);
    dbms_scheduler.create_job(
      job_name => oracleJobName
    , job_type => 'PLSQL_BLOCK'
    , auto_drop => false
    , job_action =>
'pkg_Scheduler.execBatch(' || to_char(batchId)
|| ' /* batch: ' || rec.batch_short_name || ' */, next_date);'
--    , start_date => newDate
    , enabled => true
    , comments => 'Scheduler: ' || rec.batch_short_name
    , repeat_interval => 'sysdate + 1000000'
    );
    dbms_scheduler.set_attribute(
      name => oracleJobName
    , attribute => 'RESTARTABLE'
    , value => true
    );
    dbms_scheduler.set_attribute(
      name => oracleJobName
    , attribute => 'STOP_ON_WINDOW_CLOSE'
    , value => false
    );
    dbms_scheduler.set_attribute_null(
      name => oracleJobName
    , attribute => 'MAX_FAILURES'
    );
    dbms_scheduler.set_attribute_null(
      name => oracleJobName
    , attribute => 'MAX_RUNS'
    );
    logger.trace('job created: ' || oracleJobName);
    rec.current_job_id := rec.batch_id;
    -- ��������� ����� � �������� Oracle
    update
      sch_batch
    set
      oracle_job_id = rec.current_job_id
    where current of curBatch
    ;
    rec.oracle_job_id := rec.current_job_id;
    info := '����������� ����� ' || batchLogName
      || ' ( batch_id=' || rec.batch_id
      || ', ���� ������� '
      || to_char( newDate, 'dd.mm.yyyy hh24:mi:ss') || ').'
      ;
  -- ������������� ����� ���� �������
  elsif newDate != rec.next_date then
    dbms_scheduler.disable(name => oracleJobName);
    dbms_scheduler.set_attribute(
      name => oracleJobName
    , attribute => 'START_DATE'
    , value => newDate
    );
    dbms_scheduler.enable(name => oracleJobName);
    info := '���� ������� ������ ' || batchLogName
      || ' �������� �� '
        || to_char( newDate, 'dd.mm.yyyy hh24:mi:ss') || '.'
      ;
  end if;
  -- ������� ����� �������, ���� �� ���
  if rec.retrial_number is not null then
    update
      sch_batch
    set
      retrial_number = null
    where current of curBatch
    ;
    info :=
      case when info is null
        then
          '������� ����� ��������� ������� ��� ������ ' || batchLogName || '.'
        else
          info || ' � ������� ����� ��������� �������.'
      end
    ;
  end if;
  -- ����� �������������� ���������
  if info is not null then
    logger.info(
      messageText             => info
      , messageLabel          => pkg_SchedulerMain.Activate_BatchMsgLabel
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => batchId
    );
  end if;
  close curBatch;
  restoreNlsParameters();
exception when others then
  if curBatch%ISOPEN then
    close curBatch;
  end if;
  -- ������������ ����������� ��������
  rollback to pkg_Scheduler_ActivateBatch;
  restoreNlsParameters();
  raise_application_error(              --��������� ���������� �� ������
    pkg_Error.ErrorInfo
    , '������ ��� ��������� ������ '
      || coalesce( batchLogName, '( batch_id=' || batchId || ')')
      || '.'
    , true
  );
end activateBatch;

/* proc: deactivateBatch
  ���������� ������������� ���������� ������ �������

  ���������:
  batchId                     - Id �������
  operatorId                  - Id ���������
*/
procedure deactivateBatch(
  batchId integer
  , operatorId integer
)
is
  -- ���������� �����
  cursor curBatch( batchId integer) is
    select
      b.batch_id
      , b.batch_short_name
      , b.batch_name_rus
      , b.oracle_job_id
      , (
        select
          b.batch_id
        from
          user_scheduler_jobs j
        where
          -- getOracleJobName
          j.job_name = 'SCHEDULER_' || to_char(b.batch_id)
        )
        as current_job_id
    from
      sch_batch b
    where
      b.batch_id = batchId
    for update of b.oracle_job_id nowait
  ;

  rec curBatch%rowtype;

  cursor curHandler(batchId integer) is
select
  ss.sid
  , ss.serial#
  , ss.audsid as sessionid
from
  user_scheduler_running_jobs jr
  inner join v$session ss
    on jr.session_id = ss.sid
where
  -- getOracleJobName
  jr.job_name = 'SCHEDULER_' || to_char(batchId)
  and exists
    (
    select
      null
    from
      v$db_pipes p
    where
      (
      p.name like
        '%.COMMANDPIPE\_' || to_char( ss.sid) || '\_' || to_char( ss.serial#)
        escape '\'
      or
      p.name like
        '%.COMMANDPIPE\_' || to_char( ss.sid) || to_char( ss.serial#)
        escape '\'
      )
    )
  ;

  hdr curHandler%rowtype;
  -- ��� ������, ��������� � ���
  batchLogName varchar2(500);
  info varchar2(4000);

  -- ��� job ��� dbms_scheduler
  oracleJobName varchar(1000);

  /*
    ��������� �����������, ���� ���� �������� ������������.
  */
  procedure checkStopHandler
  is
  begin
    open curHandler(batchId);
    fetch curHandler into hdr;
    close curHandler;
    if hdr.sid is not null then
      pkg_Scheduler.stopHandler(
        batchId     => batchId
      , sid         => hdr.sid
      , serial#     => hdr.serial#
      , operatorId  => operatorId
      , sessionid   => hdr.sessionid
      );
    end if;
  end checkStopHandler;

--DeactivateBatch
begin
  savepoint pkg_Scheduler_DeactivateBatch;
  -- ��������� ����� �������
  checkPrivilege( operatorId, batchId, Exec_PrivilegeCode);
  pkg_Operator.setCurrentUserId( operatorId => operatorId);
  open curBatch( batchId);
  fetch curBatch into rec;
  -- ������ ��������� ��� ���������� ������
  if curBatch%NOTFOUND then
    raise_application_error(
      pkg_Error.BatchNotFound
      , '����� �� ������.'
    );
  end if;
  batchLogName :=
    '"' || rec.batch_name_rus || '" [' || rec.batch_short_name || ']';
  oracleJobName := getOracleJobName(batchId => rec.batch_id);
  checkStopHandler();
  -- ������� ������� Oracle
  if rec.current_job_id is not null then
    logger.trace('drop job: ' || oracleJobName);
    dbms_scheduler.drop_job(
      job_name => oracleJobName
    , defer    => true
    );
  end if;
  -- ���������� ����� �� ������� Oracle
  if rec.oracle_job_id is not null then
    update
      sch_batch
    set
      oracle_job_id = null
      , retrial_number = null
    where current of curBatch
    ;
  end if;
  -- ����� �������������� ���������
  if rec.oracle_job_id is not null then
    logger.info(
      messageText             =>
          '������������� ����� ' || batchLogName
          || ' ('
            || ' oracle_job_id=' || rec.oracle_job_id
            || case when rec.current_job_id is null then
              ', �� ������ ����������� ������������� ����������� ������ �������'
              end
            || case when hdr.sid is not null then
                ', ��������� ��������� �����������'
                || ' sid=' || to_char(hdr.sid)
                || ' serial#=' || to_char(hdr.serial#)
                || ' sessionid=' || to_char(hdr.sessionid)
              end
          || ').'
      , messageLabel          => pkg_SchedulerMain.Deactivate_BatchMsgLabel
      , messageValue          => hdr.sessionid
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => batchId
    );
  end if;
  close curBatch;
exception when others then
  if curBatch%ISOPEN then
    close curBatch;
  end if;
  -- ������������ ����������� ��������
  rollback to pkg_Scheduler_DeactivateBatch;
  raise_application_error(              --��������� ���������� �� ������
    pkg_Error.ErrorInfo
    , '������ ��� ����������� ������ '
      || coalesce( batchLogName, '( batch_id=' || batchId || ')')
      || '.'
    , true
  );
end deactivateBatch;

/* proc: setNextDate
  ������������� ���� ���������� ������� ��������������� ������.

  batchId                     - Id ������
  operatorId                  - Id ���������
  nextDate                    - ���� ���������� �������
                                ( �� ��������� ����������)
*/
procedure setNextDate(
  batchId integer
  , operatorId integer
  , nextDate date := sysdate
)
is

  -- ������ ��������� �������
  bth sch_batch%rowtype;

  -- ��� ������, ��������� � ���
  batchLogName varchar2(500);

  -- ��� job ��� dbms_scheduler
  oracleJobName varchar(1000);

begin
  savepoint pkg_Scheduler_SetNextDate;

  -- ��������� ����� �������
  checkPrivilege( operatorId, batchId, Exec_PrivilegeCode);
  pkg_Operator.setCurrentUserId( operatorId => operatorId);
  pkg_SchedulerMain.getBatch( bth, batchId);
  batchLogName :=
    '"' || bth.batch_name_rus || '" [' || bth.batch_short_name || ']'
  ;
  oracleJobName := getOracleJobName(batchId => batchId);
  if bth.oracle_job_id is not null then
    -- ������������� ���� �������
    dbms_scheduler.disable(name => oracleJobName);
    dbms_scheduler.set_attribute(
      name      => oracleJobName
    , attribute => 'START_DATE'
    , value     => nextDate
    );
    dbms_scheduler.enable(name => oracleJobName);
    -- ����� �������������� ���������
    logger.info(
      messageText             =>
          '���� ������� ������ '
          || batchLogName
          || ' �������� �� '
          || to_char( nextDate, 'dd.mm.yyyy hh24:mi:ss')
          || '.'
      , messageLabel          => pkg_SchedulerMain.SetNextDate_BatchMsgLabel
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => batchId
    );
  else
    raise_application_error(
      pkg_Error.ProcessError
      , '����� �� ��� �����������.'
    );
  end if;
exception when others then
  rollback to pkg_Scheduler_SetNextDate;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ���� ���������� ������� ������'
        || case when batchLogName is not null then
            ' ' || batchLogName
          end
        || ' ('
        || ' batch_id=' || batchId
        || ', nextDate=' || to_char( nextDate, 'dd.mm.yyyy hh24:mi:ss')
        || ').'
      )
    , true
  );
end setNextDate;

/* proc: abortBatch
  ��������� ���������� ������ �������.

  ���������:
  batchId                     - Id �������
  operatorId                  - Id ���������

  ���������:
  - � ������ ��������� ���������� ������ ��������� ����������� commit.
*/
procedure abortBatch(
  batchId integer
  , operatorId integer
)
is
  -- ���������� �����
  cursor curBatch( batchId integer) is
   select
      b.batch_short_name
      , b.batch_name_rus
      , ss.sessionid
      , ss.sid
      , ss.serial#
    from
      sch_batch b
    left join
      (
      select /*+ordered*/
        jr.job_name
        , ss.audsid as sessionid
        , ss.sid
        , ss.serial#
      from
        user_scheduler_running_jobs jr
        inner join v$session ss
          on jr.session_id = ss.sid
      ) ss
    on
      -- getOracleJobName
      ss.job_name = 'SCHEDULER_' || to_char(b.batch_id)
    where
      b.batch_id = batchId
    for update of b.batch_short_name nowait
  ;

  rec curBatch%rowtype;

  -- ��� ������, ��������� � ���
  batchLogName varchar2(500);
  info varchar2(4000);

  -- ������� ������ ���������� ��������
  isStarted boolean := false;

--AbortBatch
begin
  -- ��������� ����� �������
  checkPrivilege( operatorId, batchId, Exec_PrivilegeCode);
  pkg_Operator.setCurrentUserId( operatorId => operatorId);
  open curBatch( batchId);
  fetch curBatch into rec;
  if curBatch%NOTFOUND then
    raise_application_error(
      pkg_Error.BatchNotFound
      , '����� �� ������.'
    );
  end if;
  batchLogName :=
    '"' || rec.batch_name_rus || '" [' || rec.batch_short_name || ']';
  if rec.sid is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '����� � ������ ������ �� ����������� ( ������ �� �������).'
    );
  end if;
  logger.info(
    messageText             =>
        '������ ���������� ���������� ������ ' || batchLogName
        || ', ������ sid=' || rec.sid || ', serial#=' || rec.serial# || '.'
    , messageLabel          => pkg_SchedulerMain.Abort_BatchMsgLabel
    , messageValue          => rec.sid
    , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
    , contextValueId        => batchId
    , openContextFlag       => 1
  );
  isStarted := true;
  execute immediate
    'alter system kill session '''
      || rec.sid || ',' || rec.serial#
      || ''' immediate'
  ;
  deactivateBatch(batchId, operatorId);
  activateBatch(batchId, operatorId);
  commit;
  close curBatch;
  logger.info(
    messageText             => '���������� ������ ��������.'
    , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
    , contextValueId        => batchId
    , openContextFlag       => 0
  );
exception when others then
  if curBatch%ISOPEN then
    close curBatch;
  end if;
  info := '������ ��� ���������� ���������� ������ '
    || coalesce( batchLogName, 'batch_id=' || batchId )
    || case when rec.sid is not null then
      ', ������ sid=' || rec.sid || ', serial#=' || rec.serial#
      end
    || '.'
  ;
  if isStarted then
    logger.error(
      messageText             =>
          info || chr(10) || logger.getErrorStack( isStackPreserved => 1)
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => batchId
      , openContextFlag       => 0
    );
  end if;
  raise_application_error(              --��������� ���������� �� ������
    pkg_Error.ErrorInfo
    , info
    , true
  );
end abortBatch;

/* func: findBatch
  ����� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  batchShortName              - �������� ��������
  batchName                   - ��������
  moduleId                    - Id ������, � �������� ��������� ������� �������
  retrialCount                - ����� ��������
  lastDateFrom                - ���� ���������� ������� �
  lastDateTo                  - ���� ���������� ������� ��
  rowCount                    - ������������ ����� ������������ �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  ������� ( ������):
  batch_id                    - Id ��������� �������
  batch_short_name            - �������� ��������
  batch_name                  - ��������
  module_id                   - Id ������
  module_name                 - �������� ������
  retrial_count               - ����� ��������
  retrial_timeout             - �������� ����� ���������
  oracle_job_id               - Id ������������ ������� (���������� ��������)
  retrial_number              - ����� ���������� ����������
  date_ins                    - ���� ���������� ��������� �������
  operator_id                 - Id ���������, ����������� �������� �������
  operator_name               - ��� ���������, ����������� �������� �������
                                ( ���.)
  job                         - Id ������� ������������� ������� (�����������
                                ��������, ����� batch_id, ���� �������
                                ��������)
  last_date                   - ���� ���������� �������
  this_date                   - ���� �������� �������
  next_date                   - ���� ���������� �������
  total_time                  - ��������� ����� ���������� (���������� ����)
  failures                    - ����� ��������� ���������������� ������ ���
                                ������� ����� dbms_scheduler
  is_job_broken               - ������� ������������ ������� (���������� ����)
  root_log_id                 - Id ��������� ���� ���������� ����������
  last_start_date             - ���� ���������� ������� �� ����
  last_log_date               - ���� ��������� ������ � ����
  batch_result_id             - Id ���������� ���������� ��������� �������
  result_name                 - �������� ����������
  error_job_count             - ����� ��������, ������������� ������� ���
                                ��������� ���������
  error_count                 - ����� ������ ��� ��������� ���������
  warning_count               - ����� �������������� ��� ��������� ���������
  duration_second             - ������������ ���������� ���������� ( � ��������)
  sid                         - sid ������, � ������� ����������� ��������
                                �������
  serial                      - serial# ������, � ������� ����������� ��������
                                �������

  ���������:
  - ������������ ������ �������� �������, ��������� ���������� ��������� ��
    ������;
  - �������� ���������� batchShortName, batchName ������������ ��� ������ ��
    ������� ( like) ��� ����� �������� �� ��������������� �����;
  - ���� ��������� ������ ������������� ������ �������, ��� ���������
    ������������ ����� ������������ �������, �� ������ ��� �������� ����������
    ��������� ������� ( ��� ������������� �������);
  - ��������� ��������� �� ��������� null �� ������ �� ��������� ������;
*/
function findBatch(
  batchId integer := null
  , batchShortName varchar2 := null
  , batchName varchar2 := null
  , moduleId integer := null
  , retrialCount integer := null
  , lastDateFrom date := null
  , lastDateTo date := null
  , rowCount integer := null
  , operatorId integer := null
)
return sys_refcursor
is
  -- ������������ ������
  rc sys_refcursor;
  -- SQL-������
  dSql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
  select
    batch_id
    , batch_short_name
    , batch_name_rus as batch_name
    , vb.module_id
    , md.module_name
    , vb.retrial_count
    , to_char( vb.retrial_timeout) as retrial_timeout
    , vb.oracle_job_id
    , vb.retrial_number
    , vb.date_ins
    , vb.operator_id
    , op.operator_name
    , vb.job
    , vb.last_date
    , vb.this_date
    , vb.next_date
    , cast(null as integer) as vb.total_time
    , vb.failures
    , cast(null as integer) as is_job_broken
    , vb.root_log_id
    , vb.last_start_date
    , vb.last_log_date
    , vb.batch_result_id
    , sr.result_name_rus as result_name
    , vb.error_job_count
    , vb.error_count
    , vb.warning_count
    , vb.duration_second
    , vb.sid
    , vb.serial# as serial
  from
    v_sch_operator_batch vb
    inner join v_mod_module md
      on md.module_id = vb.module_id
    left outer join op_operator op
      on vb.operator_id = op.operator_id
    left outer join sch_result sr
      on vb.batch_result_id = sr.result_id
  where
    vb.read_operator_id = :readOperatorId
  ) a
where
  $(condition)
')
  ;


--FindBatch
begin
  -- ������������ ���������� �������
  dSql.addCondition( 'a.batch_id =', batchId is null);
  dSql.addCondition(
    'upper( a.batch_short_name) like', batchShortName is null
    , 'batchShortName'
  );
  dSql.addCondition(
    'upper( a.batch_name) like', batchName is null
    , 'batchName'
  );
  dSql.addCondition( 'a.module_id =', moduleId is null);
  dSql.addCondition( 'a.retrial_count =', retrialCount is null);
  dSql.addCondition( 'a.last_date >=', lastDateFrom is null, 'lastDateFrom');
  dSql.addCondition( 'a.last_date <=', lastDateTo is null, 'lastDateTo');
  dSql.addCondition( 'rownum <=', rowCount is null, 'rowCount');
  dSql.useCondition( 'condition');
  -- �������� �������
  open rc for
    dSql.getSqlText()
  using
    coalesce( operatorId, pkg_Operator.GetCurrentUserId)
    , batchId
    , upper( batchShortName)
    , upper( batchName)
    , moduleId
    , retrialCount
    , lastDateFrom
    , lastDateTo
    , rowCount
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ������ ��������� �������.'
    , true
  );
end findBatch;



/* group: ���������� ������� */

/* func: createSchedule
  ������� ����������.

  ���������:
  batchId                     - Id ������
  scheduleName                - �������� ����������
  operatorId                  - Id ���������
*/
function createSchedule(
  batchId integer
  , scheduleName varchar2
  , operatorId integer
)
return integer
is
  scheduleId sch_schedule.schedule_id%type;

-- createSchedule
begin
  checkPrivilege( operatorId, batchId, Write_PrivilegeCode);
  insert into
    sch_schedule
  (
    batch_id
    , schedule_name_rus
    , schedule_name_eng
    , operator_id
  )
  values
  (
     batchId
     , scheduleName
     , 'NA'
     , operatorId
  )
  returning schedule_id into scheduleId;
  return scheduleId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� �������� ���������� ��� ������ �������� ������ ('
      || ' batch_id=' || to_char( batchId)
      || ', scheduleName="' || scheduleName || '"'
      || ').'
    , true
  );
end createSchedule;

/* proc: updateSchedule
  �������� ����������.

  ���������:
  scheduleId                  - Id ����������
  scheduleName                - �������� ����������
  operatorId                  - Id ���������
*/
procedure updateSchedule(
  scheduleId integer
  , scheduleName varchar2
  , operatorId integer
)
is

  cursor curSchedule( scheduleId integer) is
    select
      t.schedule_id
      , t.batch_id
    from
      sch_schedule t
    where
      t.schedule_id = scheduleId
    for update nowait
  ;

  -- ���� ������� ������
  isFound boolean := false;

--UpdateSchedule
begin
  for rec in curSchedule( scheduleId) loop
    isFound := true;
    checkPrivilege( operatorId, rec.batch_id, Write_PrivilegeCode);
    update
      sch_schedule t
    set
      t.schedule_name_rus = scheduleName
    where current of curSchedule;
  end loop;
  -- �������� �� ���������� ������
  if not isFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '���������� �� �������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� ��������� ���������� �������� ������ ('
      || ' schedule_id=' || to_char( scheduleId)
      || ').'
    , true
  );
end updateSchedule;

/* proc: deleteSchedule
  ������� ����������.

  ���������:
  scheduleId                  - Id ����������
  operatorId                  - Id ���������
*/
procedure deleteSchedule(
  scheduleId integer
  , operatorId integer
)
is

  cursor curSchedule( scheduleId integer) is
    select
      t.schedule_id
      , t.batch_id
    from
      sch_schedule t
    where
      t.schedule_id = scheduleId
    for update nowait
  ;

  -- ���� ������� ������
  isFound boolean := false;

--DeleteSchedule
begin
  for rec in curSchedule( scheduleId) loop
    isFound := true;
    checkPrivilege( operatorId, rec.batch_id, Write_PrivilegeCode);
    delete from
      sch_schedule t
    where current of curSchedule;
  end loop;
  -- �������� �� ���������� ������
  if not isFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '���������� �� �������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� �������� ���������� �������� ������ ('
      || ' schedule_id=' || to_char( scheduleId)
      || ').'
    , true
  );
end deleteSchedule;

/* func: findSchedule

  ���������:
    scheduleId                - ���������� �������������
    batchId                    - ������������� �����
    maxRowCount                - ���������� �������
    operatorId                - ������������� �������� ������������

  ������� (������):
    schedule_id                - ���������� �������������
    batch_id                  - ������������� �����
    schedule_name              - ������������
    date_ins                  - ���� ��������
    operator_id                - ������������� ���������
    operator_name              - ��������
*/
function findSchedule
(
    scheduleId  integer := null
  , batchId     integer := null
  , maxRowCount integer := null
  , operatorId  integer := null
) return sys_refcursor
is
  -- ������������ ������
  resultSet sys_refcursor;
  -- ������ � ��������
  dSql dyn_dynamic_sql_t := dyn_dynamic_sql_t ( '
    select
        s.schedule_id
      , s.batch_id
      , s.schedule_name_rus as schedule_name
      , s.date_ins
      , s.operator_id
      , op.operator_name
    from sch_schedule s
    inner join op_operator op
      on op.operator_id = s.operator_id
    where $(condition)
  ');
begin

  -- ������������ ���������� �������
  dSql.addCondition( 's.schedule_id =', scheduleId is null);
  dSql.addCondition( 's.batch_id =', batchId is null);
  dSql.addCondition( 'rownum <=', maxRowCount is null, 'maxRowCount');
  dSql.useCondition( 'condition');

  open resultSet for dSql.getSqlText()
  using
      scheduleId
    , batchId
    , maxRowCount;

  return resultSet;

end findSchedule;



/* group: ��������� ���������� ������� */

/* func: createInterval
  ������� ��������.

  ���������:
  scheduleId                  - Id ����������
  intervalTypeCode            - ��� ���� ���������
  minValue                    - ����������� ��������
  maxValue                    - ������������ ��������
  step                        - ��� ( �� ��������� 1)
  operatorId                  - Id ��������� ( �� ��������� �������)
*/
function createInterval(
  scheduleId integer
  , intervalTypeCode varchar2
  , minValue integer
  , maxValue integer
  , step integer := null
  , operatorId integer := null
)
return integer
is

  intervalId sch_interval.interval_id%type;

  batchId sch_batch.batch_id%type;

--CreateInterval
begin
  -- �������� Id ������ ��� �������� ����
  select
    sc.batch_id
  into batchId
  from
    sch_schedule sc
  where
    sc.schedule_id = scheduleId
  ;
  checkPrivilege( operatorId, batchId, Write_PrivilegeCode);
  insert into
    sch_interval
  (
    schedule_id
    , interval_type_code
    , min_value
    , max_value
    , step
    , operator_id
  )
  values
  (
     scheduleId
     , intervalTypeCode
     , minValue
     , maxValue
     , step
     , operatorId
  )
  returning interval_id into intervalId;
  return intervalId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� �������� ��������� ��� ���������� �������� ������ ('
      || ' schedule_id=' || to_char( scheduleId)
      || ', intervalTypeCode="' || intervalTypeCode || '"'
      || ', ' || to_char( minValue)
        || '-' || to_char( maxValue)
        || '/' || to_char( step)
      || ').'
    , true
  );
end createInterval;

/* proc: updateInterval
  �������� ��������.

  ���������:
  intervalId                  - Id ���������
  intervalTypeCode            - ��� ���� ���������
  minValue                    - ����������� ��������
  maxValue                    - ������������ ��������
  step                        - ���
  operatorId                  - Id ���������
*/
procedure updateInterval(
  intervalId integer
  , intervalTypeCode varchar2
  , minValue integer
  , maxValue integer
  , step integer
  , operatorId integer
)
is

  cursor curInterval( intervalId integer) is
    select
      t.interval_id
      , sc.batch_id
    from
      sch_interval t
      inner join sch_schedule sc
        on sc.schedule_id = t.schedule_id
    where
      t.interval_id = intervalId
    for update of t.interval_id nowait
  ;

  -- ���� ������� ������
  isFound boolean := false;

--UpdateInterval
begin
  for rec in curInterval( intervalId) loop
    isFound := true;
    checkPrivilege( operatorId, rec.batch_id, Write_PrivilegeCode);
    update
      sch_interval t
    set
      t.interval_type_code = intervalTypeCode
      , t.min_value = minValue
      , t.max_value = maxValue
      , t.step = updateInterval.step
    where current of curInterval;
  end loop;
  -- �������� �� ���������� ������
  if not isFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�������� �� ������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� ��������� ��������� �������� ������ ('
      || ' interval_id=' || to_char( intervalId)
      || ').'
    , true
  );
end updateInterval;

/* proc: deleteInterval
  ������� ��������.

  ���������:
  intervalId                  - Id ���������
  operatorId                  - Id ���������
*/
procedure deleteInterval(
  intervalId integer
  , operatorId integer
)
is

  cursor curInterval( intervalId integer) is
    select
      t.interval_id
      , sc.batch_id
    from
      sch_interval t
      inner join sch_schedule sc
        on sc.schedule_id = t.schedule_id
    where
      t.interval_id = intervalId
    for update of t.interval_id nowait
  ;

  -- ���� ������� ������
  isFound boolean := false;

--DeleteInterval
begin
  for rec in curInterval( intervalId) loop
    isFound := true;
    checkPrivilege( operatorId, rec.batch_id, Write_PrivilegeCode);
    delete from
      sch_interval t
    where current of curInterval;
  end loop;
  -- �������� �� ���������� ������
  if not isFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�������� �� ������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� �������� ��������� �������� ������ ('
      || ' interval_id=' || to_char( intervalId)
      || ').'
    , true
  );
end DeleteInterval;

/* func: findInterval

  ���������:
    scheduleId                - ���������� �������������
    batchId                    - ������������� �����
    maxRowCount                - ���������� �������
    operatorId                - ������������� �������� ������������

  ������� (������):
    interval_id               - ���������� �������������
    schedule_id               - ������������� ����������
    interval_type_code        - ��� ���� ���������
    interval_type_name        - ������������ ���� ���������
    min_value                 - ������ �������
    max_value                 - ������� �������
    step                      - ��� ���������
    date_ins                  - ���� ��������
    operator_id               - ������������� ���������
    operator_name             - ��������
*/
function findInterval
(
    intervalId  integer := null
  , scheduleId  integer := null
  , maxRowCount integer := null
  , operatorId  integer := null
) return sys_refcursor
is
  -- ������������ ������
  resultSet sys_refcursor;
  -- ������ ������������� �������
  dSql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
    select
        i.interval_id
      , i.schedule_id
      , i.interval_type_code
      , it.interval_type_name_rus as interval_type_name
      , i.min_value
      , i.max_value
      , i.step
      , i.date_ins
      , i.operator_id
      , op.operator_name
    from sch_interval i
    inner join sch_interval_type it
      on it.interval_type_code = i.interval_type_code
    inner join op_operator op
      on op.operator_id = i.operator_id
    where $(condition)
  ');
begin

  -- ������������ ���������� �������
  dSql.addCondition( 'i.interval_id =', intervalId is null);
  dSql.addCondition( 'i.schedule_id =', scheduleId is null);
  dSql.addCondition( 'rownum <=', maxRowCount is null, 'maxRowCount');
  dSql.useCondition( 'condition');

  open resultSet for dSql.getSqlText()
  using
      intervalId
    , scheduleId
    , maxRowCount;

  return resultSet;

end findInterval;



/* group: ���� */

/* func: findRootLog

  ���������:
    logId                  - ���������� �������������
    batchId                - ������������� �����
    maxRowCount            - ���������� �������
    operatorId             - ������������� �������� ������������

  ������� (������):
    log_id                  - ���������� �������������
    batch_id                - ������������� �����
    message_type_code       - ��� ���� ���������
    message_type_name       - ������������ ���� ���������
    message_text            - ����� ���������
    date_ins                - ���� ��������
    operator_id             - ������������� ���������
    operator_name           - ��������
*/
function findRootLog
(
    logId        integer := null
  , batchId      integer := null
  , maxRowCount  integer := null
  , operatorId  integer := null
) return sys_refcursor
is
  -- ������������ ������
  resultSet sys_refcursor;
  -- ������ ������������� �������
  dSql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
  select
      l.log_id
    , l.batch_id
    , l.message_type_code
    , m.message_type_name_rus as message_type_name
    , l.message_text
    , l.date_ins
    , l.operator_id
    , op.operator_name
  from v_sch_batch_root_log l
  inner join sch_message_type m
    on m.message_type_code = l.message_type_code
  left join op_operator op
    on op.operator_id = l.operator_id
  where $(condition)
  order by
    1 desc
  ) a
where
  $(rownumCondition)
  ');
begin

  -- ������������ ���������� �������
  dSql.addCondition( 'l.log_id =', logId is null);
  dSql.addCondition( 'l.batch_id =', batchId is null);
  dSql.useCondition( 'condition');
  dSql.addCondition(
    'rownum <= :maxRowCount', maxRowCount is null
  );
  dSql.useCondition( 'rownumCondition');

  open resultSet for dSql.getSqlText()
  using
      logId
    , batchId
    , maxRowCount;

  return resultSet;

end findRootLog;

/* func: getDetailedLog

  ���������:
    parentLogId            - ������������� ������������� ����
    operatorId             - ������������� �������� ������������

  ������� (������):
    log_id                  - ���������� �������������
    parent_log_id           - ������������� ������������� ����
    message_type_code       - ��� ���� ���������
    message_type_name       - ������������ ���� ���������
    message_text            - ����� ���������
    message_value           - �������� ���������
    log_level               - ������� ��������
    date_ins                - ���� ��������
    operator_id             - ������������� ���������
    operator_name           - ��������
*/
function getDetailedLog
(
    parentLogId integer
  , operatorId  integer
) return sys_refcursor
is

  -- ������������ ������
  resultSet sys_refcursor;

  -- ���� ���� � �������������� ��������� ������ Logging
  isContextLog integer;

begin
  select
    count(*)
  into isContextLog
  from
    lg_log lg
  where
    lg.log_id = parentLogId
    and lg.context_type_id is not null
  ;
  if isContextLog = 1 then

  open resultSet for
    select
        lg.log_id
      , nullif( parentLogId, lg.log_id) as parent_log_id
      , m.message_type_code
      , m.message_type_name_rus as message_type_name
      , coalesce( lg.message_value, lg.context_value_id) as message_value
      , lg.message_text
      , 1 + ( lg.context_level - ccl.open_context_level)
        + case when lg.open_context_flag in ( 1, -1) then 0 else 1 end
        as log_level
      , lg.date_ins
      , lg.operator_id
      , op.operator_name
    from
      v_lg_context_change_log ccl
      inner join lg_log lg
        on lg.sessionid = ccl.sessionid
          and lg.log_id >= ccl.open_log_id
          and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
      left join op_operator op
        on op.operator_id = lg.operator_id
      left join lg_context_type ct
        on ct.context_type_id = lg.context_type_id
      left join sch_message_type m
        on m.message_type_code =
          case ct.context_type_short_name
            when pkg_SchedulerMain.Batch_CtxTpSName then
              case when lg.open_context_flag != 0 then
                Bstart_MessageTypeCode
              else
                Bfinish_MessageTypeCode
              end
            when pkg_SchedulerMain.Job_CtxTpSName then
              case when lg.open_context_flag != 0 then
                Jstart_MessageTypeCode
              else
                Jfinish_MessageTypeCode
              end
            else
              case lg.level_code
                when pkg_Logging.Fatal_LevelCode then
                  Error_MessageTypeCode
                when pkg_Logging.Error_LevelCode then
                  Error_MessageTypeCode
                when pkg_Logging.Warn_LevelCode then
                  Warning_MessageTypeCode
                when pkg_Logging.Info_LevelCode then
                  Info_MessageTypeCode
                else
                  Debug_MessageTypeCode
              end
          end
    where
      ccl.log_id = parentLogId
    order by
      1
  ;

  else

  open resultSet for
  select
      l.log_id
    , l.parent_log_id
    , l.message_type_code
    , m.message_type_name_rus as message_type_name
    , l.message_value
    , l.message_text
    , l.log_level
    , l.date_ins
    , l.operator_id
    , op.operator_name
  from
  (
    select
        l.log_id
      , l.parent_log_id
      , l.message_type_code
      , l.message_value
      , l.message_text
      , level as log_level
      , l.date_ins
      , l.operator_id
    from sch_log l
    start with l.log_id = parentLogId
    connect by prior l.log_id = l.parent_log_id
    order siblings by l.date_ins, l.log_id
  ) l
  inner join sch_message_type m
    on m.message_type_code = l.message_type_code
  left join op_operator op
    on op.operator_id = l.operator_id;

  end if;

  return resultSet;

end getDetailedLog;



/* group: ��������� �������� ������� */

/* func: createOption
  ������� �������� ��������� ������� � ������ ��� ���� ������������ � �������
  �� ��������.

  ���������:
  batchId                     - Id ��������� �������
  optionShortName             - �������� �������� ���������
  valueTypeCode               - ��� ���� �������� ���������
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ��� ( �� ���������))
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ����
                                ( 1 ��, 0 ��� ( �� ���������))
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 �� ( �� ���������), 0 ���)
  optionName                  - �������� ���������
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  stringListSeparator         - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������� ��������
                                ( �� ��������� ������������ ";")
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id ���������.

  ���������:
  - � ������, ���� ������������ ������ ��������, ��������� � ����������
    ������� �������� ����������� ��� ������ �������� ������;
*/
function createOption(
  batchId integer
  , optionShortName varchar2
  , valueTypeCode varchar2
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , optionName varchar2
  , optionDescription varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , operatorId integer := null
)
return integer
is

  -- ������ ��������� �������
  bth sch_batch%rowtype;

begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  pkg_SchedulerMain.getBatch( bth, batchId);
  return
    pkg_Option.createOption(
      moduleId                  => bth.module_id
      , objectShortName         => bth.batch_short_name
      , objectTypeId            =>
          opt_option_list_t(
              moduleSvnRoot => pkg_SchedulerMain.Module_SvnRoot
            )
            .getObjectTypeId(
              objectTypeShortName => pkg_SchedulerMain.Batch_OptionObjTypeSName
            )
      , optionShortName         => optionShortName
      , valueTypeCode           => valueTypeCode
      , valueListFlag           => valueListFlag
      , encryptionFlag          => encryptionFlag
      , testProdSensitiveFlag   => coalesce( testProdSensitiveFlag, 1)
      , optionName              => optionName
      , optionDescription       => optionDescription
      , dateValue               => dateValue
      , numberValue             => numberValue
      , stringValue             => stringValue
      , stringListSeparator     => stringListSeparator
      , checkRoleFlag           => 0
      , operatorId              => operatorId
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ��������� ����� ('
        || ' batchId=' || batchId
        || ', optionShortName="' || optionShortName || '"'
        || ').'
      )
    , true
  );
end createOption;

/* proc: updateOption
  �������� �������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  optionId                    - Id ���������
  valueTypeCode               - ��� ���� �������� ���������
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ���)
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ���� ( 1 ��, 0 ���)
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ���)
  optionName                  - �������� ���������
  optionDescription           - �������� ���������
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ��������, ������� �� ������������� ����� ������ ������������ ���������,
    ���������;
  - � ������������ �� ��� ��������� �������� testProdSensitiveFlag �������
    �������� ��������� ����������� ( ��� ���� ������ ������ �������� ���������
    �������� ��� ������������ �� ��� ��������);
*/
procedure updateOption(
  batchId integer
  , optionId integer
  , valueTypeCode varchar2
  , valueListFlag integer
  , encryptionFlag integer
  , testProdSensitiveFlag integer
  , optionName varchar2
  , optionDescription varchar2
  , operatorId integer := null
)
is
begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  pkg_Option.updateOption(
    optionId                    => optionId
    , valueTypeCode             => valueTypeCode
    , valueListFlag             => valueListFlag
    , encryptionFlag            => encryptionFlag
    , testProdSensitiveFlag     => testProdSensitiveFlag
    , optionName                => optionName
    , optionDescription         => optionDescription
    , checkRoleFlag             => 0
    , operatorId                => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ��������� ����� ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end updateOption;

/* proc: setOptionValue
  ������ ������������ � ������� �� �������� ��������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  optionId                    - Id ���������
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  operatorId                  - Id ��������� ( �� ��������� �������)
*/
procedure setOptionValue(
  batchId integer
  , optionId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is
begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  pkg_Option.setOptionValue(
    optionId                    => optionId
    , dateValue                 => dateValue
    , numberValue               => numberValue
    , stringValue               => stringValue
    , valueIndex                => valueIndex
    , checkRoleFlag             => 0
    , operatorId                => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������� ������������� �������� ��������� ����� ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end setOptionValue;

/* proc: deleteOption
  ������� ����������� ��������.

  ���������:
  batchId                     - Id ��������� �������
  optionId                    - Id ���������
  operatorId                  - Id ��������� ( �� ��������� �������)
*/
procedure deleteOption(
  batchId integer
  , optionId integer
  , operatorId integer := null
)
is
begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  pkg_Option.deleteOption(
    optionId            => optionId
    , checkRoleFlag     => 0
    , operatorId        => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ��������� ����� ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end deleteOption;

/* func: findOption
  ����� ����������� ���������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  optionId                    - Id ���������
                                ( �� ��������� ��� �����������)
  maxRowCount                 - ������������ ����� ������������ ������� �������
                                ( �� ��������� ��� �����������)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� ( ������):
  option_id                   - Id ���������
  value_id                    - Id ������������� ��������
  option_short_name           - �������� �������� ���������
  value_type_code             - ��� ���� �������� ���������
  value_type_name             - �������� ���� �������� ���������
  date_value                  - �������� ��������� ���� ����
  number_value                - �������� �������� ���������
  string_value                - ��������� �������� ��������� ���� ������
                                �������� � ������������, ��������� � ����
                                list_separator ( ���� ��� ������)
  list_separator              - ������, ������������ � �������� ����������� �
                                ������ ��������
  value_list_flag             - ���� ������� ��� ��������� ������ ��������
  encryption_flag             - ���� �������� �������� ��������� �
                                ������������� ����
  test_prod_sensitive_flag    - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
  access_level_code           - ��� ������ ������� ����� ���������
  access_level_name           - �������� ������ ������� ����� ���������
  option_name                 - �������� ���������
  option_description          - �������� ���������

  ���������:
  - � ������������ ������� ����� ������������ ������ ������������������� ����
    ����, ������� �� ������ �������������� � ����������;
*/
function findOption(
  batchId integer
  , optionId integer := null
  , maxRowCount integer := null
  , operatorId integer := null
)
return sys_refcursor
is

  -- ������ ��������� �������
  bth sch_batch%rowtype;

begin
  pkg_SchedulerMain.getBatch( bth, batchId);
  return
    pkg_Option.findOption(
      optionId                  => optionId
      , moduleId                => bth.module_id
      , objectShortName         => bth.batch_short_name
      , objectTypeId            =>
          opt_option_list_t(
              moduleSvnRoot => pkg_SchedulerMain.Module_SvnRoot
            )
            .getObjectTypeId(
              objectTypeShortName => pkg_SchedulerMain.Batch_OptionObjTypeSName
            )
      , maxRowCount             => maxRowCount
      , checkRoleFlag           => 0
      , operatorId              => operatorId
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ ����������� ���������� ����� ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end findOption;



/* group: �������� ��������� ��������� ������� */

/* func: createValue
  ������� �������� ���������.

  ���������:
  batchId                     - Id ��������� �������
  optionId                    - Id ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                  �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  stringListSeparator         - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������� ��������
                                ( �� ��������� ������������ ";")
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id �������� ���������.

  ���������:
  - � ������, ���� ������������ ������ ��������, ��������� � ����������
    ������� �������� ����������� ��� ������ �������� ������;
*/
function createValue(
  batchId integer
  , optionId integer
  , prodValueFlag integer
  , instanceName varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , operatorId integer := null
)
return integer
is
begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  return
    pkg_Option.createValue(
      optionId                  => optionId
      , prodValueFlag           => prodValueFlag
      , instanceName            => instanceName
      , dateValue               => dateValue
      , numberValue             => numberValue
      , stringValue             => stringValue
      , stringListSeparator     => stringListSeparator
      , checkRoleFlag           => 0
      , operatorId              => operatorId
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� �������� ��������� ����� ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end createValue;

/* proc: updateValue
  �������� �������� ��������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  valueId                     - Id ��������
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  operatorId                  - Id ��������� ( �� ��������� �������)
*/
procedure updateValue(
  batchId integer
  , valueId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is
begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  pkg_Option.updateValue(
    valueId                     => valueId
    , dateValue                 => dateValue
    , numberValue               => numberValue
    , stringValue               => stringValue
    , valueIndex                => valueIndex
    , checkRoleFlag             => 0
    , operatorId                => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� �������� ��������� ����� ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end updateValue;

/* proc: deleteValue
  ������� �������� ��������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  valueId                     - Id �������� ���������
  operatorId                  - Id ��������� ( �� ��������� �������)
*/
procedure deleteValue(
  batchId integer
  , valueId integer
  , operatorId integer := null
)
is
begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  pkg_Option.deleteValue(
    valueId                     => valueId
    , checkRoleFlag             => 0
    , operatorId                => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� �������� ('
        || ' valueId=' || valueId
        || ').'
      )
    , true
  );
end deleteValue;

/* func: findValue
  ����� �������� ��������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  valueId                     - Id ��������
  optionId                    - Id ���������
  maxRowCount                 - ������������ ����� ������������ ������� �������
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� ( ������):
  value_id                    - Id ��������
  option_id                   - Id ���������
  used_value_flag             - ���� �������� ������������� � �� ��������
                                ( 1 ��, ����� null)
  prod_value_flag             - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) �� ( 1 ������ �
                                ������������ ��, 0 ������ � �������� ��, null
                                ��� �����������)
  instance_name               - ��� ���������� ��, � ������� �����
                                �������������� �������� ( � ������� ��������,
                                null ��� �����������)
  value_type_code             - ��� ���� �������� ���������
  value_type_name             - �������� ���� �������� ���������
  list_separator              - ������, ������������ � �������� ����������� �
                                ������ ��������
  encryption_flag             - ���� �������� �������� ��������� �
                                ������������� ����
  date_value                  - �������� ��������� ���� ����
  number_value                - �������� �������� ���������
  string_value                - ��������� �������� ��������� ���� ������
                                �������� � ������������, ��������� � ����
                                list_separator ( ���� ��� ������)

  ���������:
  - ����������� ������ ���� ������� �������� valueId ��� optionId;
*/
function findValue(
  batchId integer
  , valueId integer := null
  , optionId integer := null
  , maxRowCount integer := null
  , operatorId integer := null
)
return sys_refcursor
is
begin
  return
    pkg_Option.findValue(
      valueId                   => valueId
      , optionId                => optionId
      , maxRowCount             => maxRowCount
      , checkRoleFlag           => 0
      , operatorId              => operatorId
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ �������� ���������� ����� ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end findValue;



/* group: ����� ����� �� �������� ������� */

/* func: createBatchRole
  ������ ���� ���������� �� �����.

  ���������:
  batchId                     - Id ������
  privilegeCode               - ��� ����������
  roleId                      - Id ����
  operatorId                  - Id ���������
*/
function createBatchRole(
  batchId integer
  , privilegeCode varchar2
  , roleId integer
  , operatorId integer
)
return integer
is

  batchRoleId sch_batch_role.batch_role_id%type;

--CreateBatchRole
begin
  checkPrivilege( operatorId, batchId, Admin_PrivilegeCode);
  insert into
    sch_batch_role
  (
    batch_id
    , privilege_code
    , role_id
    , operator_id
  )
  values
  (
     batchId
     , privilegeCode
     , roleId
     , operatorId
  )
  returning batch_role_id into batchRoleId;
  return batchRoleId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� ������ ���������� ��� ���� �� ����� �������� ������ ('
      || ' batch_id=' || to_char( batchId)
      || ', privilege_code="' || privilegeCode || '"'
      || ', role_id=' || to_char( roleId)
      || ').'
    , true
  );
end createBatchRole;

/* proc: deleteBatchRole
  �������� � ���� ���������� �� �����.

  ���������:
  batchRoleId                 - Id ��������� ������
  operatorId                  - Id ���������
*/
procedure deleteBatchRole(
  batchRoleId integer
  , operatorId integer
)
is
  cursor curBatchRole( batchRoleId integer) is
    select
      t.batch_role_id
      , t.batch_id
    from
      sch_batch_role t
    where
      t.batch_role_id = batchRoleId
    for update of t.batch_role_id nowait
  ;

  -- ���� ������� ������
  isFound boolean := false;

--DeleteBatchRole
begin
  for rec in curBatchRole( batchRoleId) loop
    isFound := true;
    checkPrivilege( operatorId, rec.batch_id, Admin_PrivilegeCode);
    delete from
      sch_batch_role t
    where current of curBatchRole;
  end loop;
  -- �������� �� ���������� ������
  if not isFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ �� �������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '��� �������� � ���� ���������� �� ����� �������� ������ ('
      || ' batch_role_id=' || to_char( batchRoleId)
      || ').'
    , true
  );
end deleteBatchRole;

/* func: findBatchRole

  ���������:
    batchRoleId                 - ���������� �������������
    batchId                     - ������������� �����
    maxRowCount                 - ���������� �������
    operatorId                  - ������������� �������� ������������

  ������� (������):
    batch_role_id               - ���������� �������������
    batch_id                    - ������������� �����
    privilege_code              - ��� ����������
    role_id                     - ������������� ����
    role_short_name             - ������� ������������ ����
    privilege_name              - ������������ ����������
    role_name                   - ������������ ����
    date_ins                    - ���� ��������
    operator_id                 - ������������� ���������
    operator_name               - ��������
*/
function findBatchRole
(
    batchRoleId integer := null
  , batchId     integer := null
  , maxRowCount  integer := null
  , operatorId  integer := null
) return sys_refcursor
is
  -- ������������ ������
  resultSet sys_refcursor;
  -- ������ ������������� �������
  dSql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
    select
        b.batch_role_id
      , b.batch_id
      , b.privilege_code
      , b.role_id
      , r.short_name as role_short_name
      , p.privilege_name
      , r.role_name
      , b.date_ins
      , b.operator_id
      , op.operator_name
    from sch_batch_role b
    inner join sch_privilege p
      on p.privilege_code = b.privilege_code
    inner join v_op_role r
      on r.role_id = b.role_id
    inner join op_operator op
      on op.operator_id = b.operator_id
    where $(condition)
  ');
begin

  -- ������������ ���������� �������
  dSql.addCondition( 'b.batch_role_id =', batchRoleId is null);
  dSql.addCondition( 'b.batch_id =', batchId is null);
  dSql.addCondition( 'rownum <=', maxRowCount is null, 'maxRowCount');
  dSql.useCondition( 'condition');

  open resultSet for dSql.getSqlText()
  using
      batchRoleId
    , batchId
    , maxRowCount;

  return resultSet;

end findBatchRole;



/* group: ����� ����� �� �������� ������� ������� */

/* func: createModuleRolePrivilege
  ������ ���� ���������� �� ����� �������� ������� ������.

  ���������:
  moduleId                    - Id ������
  roleId                      - Id ����
  privilegeCode               - ��� ����������
  operatorId                  - Id ���������

  �������:
  Id ��������� ������.
*/
function createModuleRolePrivilege(
  moduleId integer
  , roleId integer
  , privilegeCode varchar2
  , operatorId integer
)
return integer
is

  moduleRolePrivilegeId sch_module_role_privilege.module_role_privilege_id%type;

begin
  checkPrivilege( operatorId, null, Admin_PrivilegeCode, moduleId);
  insert into
    sch_module_role_privilege
  (
    module_id
    , role_id
    , privilege_code
    , operator_id
  )
  values
  (
     moduleId
     , roleId
     , privilegeCode
     , operatorId
  )
  returning module_role_privilege_id into moduleRolePrivilegeId;
  return moduleRolePrivilegeId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ ���������� �� �������� ������� ������ ('
        || ' moduleId=' || moduleId
        || ', roleId=' || roleId
        || ', privilegeCode="' || privilegeCode || '"'
        || ').'
      )
    , true
  );
end createModuleRolePrivilege;

/* proc: deleteModuleRolePrivilege
  �������� � ���� ���������� �� ��� �������.

  ���������:
  moduleRolePrivilegeId       - Id ������ c ������� ����������
  operatorId                  - Id ���������
*/
procedure deleteModuleRolePrivilege(
  moduleRolePrivilegeId integer
  , operatorId integer
)
is

  -- ������ ������������ ������
  rec sch_module_role_privilege%rowtype;

begin
  select
    t.*
  into rec
  from
    sch_module_role_privilege t
  where
    t.module_role_privilege_id = moduleRolePrivilegeId
  for update nowait;
  checkPrivilege( operatorId, null, Admin_PrivilegeCode, rec.module_id);
  delete from
    sch_module_role_privilege t
  where
    t.module_role_privilege_id = rec.module_role_privilege_id
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ���������� �� �������� ������� ������ ('
        || ' moduleRolePrivilegeId=' || moduleRolePrivilegeId
        || ').'
      )
    , true
  );
end deleteModuleRolePrivilege;

/* func: findModuleRolePrivilege
  ����� �������� ����� ���������� �� ����� �������� ������� ������.

  ���������:
  moduleRolePrivilegeId       - Id ������ c ������� ����������
                                ( �� ��������� ��� �����������)
  moduleId                    - Id ������
                                ( �� ��������� ��� �����������)
  roleId                      - Id ����
                                ( �� ��������� ��� �����������)
  privilegeCode               - ��� ����������
                                ( �� ��������� ��� �����������)
  maxRowCount                 - ������������ ����� ������������ �������
                                ( �� ��������� ��� �����������)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� (������):
  module_role_privilege_id    - Id ������ c ������� ����������
  module_id                   - Id ������
  module_name                 - �������� ������
  role_id                     - Id ����
  role_short_name             - ������� �������� ����
  role_name                   - �������� ����
  privilege_code              - ��� ����������
  privilege_name              - �������� ����������
  date_ins                    - ���� ���������� ������
  operator_id                 - Id ���������, ����������� ������
  operator_name               - ��������, ���������� ������

  ���������:
  - ������������ ������ ������������� �� module_name, role_short_name,
    privilege_code;
*/
function findModuleRolePrivilege(
  moduleRolePrivilegeId integer := null
  , moduleId integer := null
  , privilegeCode varchar2 := null
  , roleId integer := null
  , maxRowCount  integer := null
  , operatorId integer := null
)
return sys_refcursor
is

  -- ������������ ������
  rc sys_refcursor;

  -- ����������� ����������� ����� �������
  dsql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
  select
    t.module_role_privilege_id
    , t.module_id
    , md.module_name
    , t.privilege_code
    , t.role_id
    , r.role_short_name
    , p.privilege_name
    , r.role_name
    , t.date_ins
    , t.operator_id
    , op.operator_name
  from
    sch_module_role_privilege t
    inner join
      (
      select
        rp.module_id
      from
        v_sch_role_privilege rp
        inner join v_op_operator_role opr
          on opr.role_id = rp.role_id
      where
        rp.privilege_code = ''' || Read_PrivilegeCode || '''
        and rp.module_id is not null
        and opr.operator_id = :operatorId
      group by
        rp.module_id
      ) mp
      on mp.module_id = t.module_id
    inner join v_mod_module md
      on md.module_id = t.module_id
    inner join sch_privilege p
      on p.privilege_code = t.privilege_code
    inner join v_op_role r
      on r.role_id = t.role_id
    inner join op_operator op
      on op.operator_id = t.operator_id
  where
    $(condition)
  order by
    md.module_name
    , role_short_name
    , t.privilege_code
  ) a
where
  $(rownumCondition)
'
  );

-- findModuleRolePrivilege
begin

  -- ������������ ���������� �������
  dsql.addCondition(
    't.module_role_privilege_id =', moduleRolePrivilegeId is null
  );
  dsql.addCondition( 't.module_id =', moduleId is null);
  dsql.addCondition( 't.privilege_code =', privilegeCode is null);
  dsql.addCondition( 't.role_id =', roleId is null);
  dsql.useCondition( 'condition');
  dsql.addCondition(
    'rownum <= :maxRowCount', maxRowCount is null
  );
  dsql.useCondition( 'rownumCondition');

  open rc for
    dsql.getSqlText()
  using
    coalesce( operatorId, pkg_Operator.getCurrentUserId())
    , moduleRolePrivilegeId
    , moduleId
    , privilegeCode
    , roleId
    , maxRowCount
  ;

  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ ���� �� �������� ������� �������.'
      )
    , true
  );
end findModuleRolePrivilege;



/* group: ����������� */

/* func: findModule
  ���������� ����������� ������, � ������� ���� �������� �������.

  ������� ( ������):
  module_id                   - Id ������
  module_name                 - �������� ������
  ( ���������� �� module_name, module_id)
*/
function findModule
return sys_refcursor
is

  -- ������������ ������
  rc sys_refcursor;

begin
  open rc for
    select
      t.module_id
      , t.module_name
    from
      v_mod_module t
    where
      t.module_id in
        (
        select
          bt.module_id
        from
          sch_batch bt
        )
    order by
      t.module_name
      , t.module_id
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ����������� �������.'
      )
    , true
  );
end findModule;

/* func: getIntervalType
  ������� �������� ��� ������ �� ������� sch_interval_type ��� �������������� �������.

  ������� (������):
    interval_type_code          -  ���������� �������������
    interval_type_name          -  ������������
*/
function getIntervalType
return sys_refcursor
is
  -- ������������ ������
  resultSet sys_refcursor;
begin

  open resultSet for
  select
      interval_type_code
    , interval_type_name_rus as interval_type_name
  from sch_interval_type;

  return resultSet;

end getIntervalType;

/* func: getPrivilege
  ���������� ���������� �� ������ � ��������� ���������.

  ������� ( ������):
  privilege_code              - ��� ���� ����������
  privilege_name              - �������� ���� ����������

  ( ���������� �� privilege_name)
*/
function getPrivilege
return sys_refcursor
is

  -- ������������ ������
  rc sys_refcursor;

begin
  open rc for
    select
      t.privilege_code
      , t.privilege_name
    from
      sch_privilege t
    order by
      t.privilege_name
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������� ���������� �� ������ � ��������� ���������.'
      )
    , true
  );
end getPrivilege;

/* func: getRole
  ���������� ������ �����.

  ���������:
  searchStr                   - ������-������� ��� ������ ( ������ ��� ������
                                �� ��������� ��������, �������� ��� ��������
                                ���� ��� ����� ��������)

  ������� ( ������):
  role_id                     - Id ����
  role_name                   - �������� ����

  ���������:
  - ������������ ������ ������������� �� role_name;
*/
function getRole(
  searchStr varchar2 := null
)
return sys_refcursor
is

  -- ������������ ������
  rc sys_refcursor;

begin
  open rc for
    select
      t.role_id
      , t.role_name
    from
      v_op_role t
    where
      searchStr is null
      or upper( t.role_short_name) like upper( searchStr)
      or upper( t.role_name) like upper( searchStr)
      or upper( t.role_name_en) like upper( searchStr)
      or upper( t.description) like upper( searchStr)
    order by
      role_name
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ������ �����.'
      )
    , true
  );
end getRole;

/* func: getValueType
  ���������� ���� �������� ���������� �������� �������.

  ������� ( ������):
  value_type_code             - ��� ���� �������� ���������
  value_type_name             - �������� ���� �������� ���������
*/
function getValueType
return sys_refcursor
is

  -- ������������ ������
  rc sys_refcursor;

begin
  return pkg_Option.getValueType();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������� ����� �������� ���������� ������.'
      )
    , true
  );
end getValueType;



/* group: ������� ���������� ��������� ��������� */



/* group: ���������� ������ */

/* func: calcNextDate
  ��������� ���� ���������� ������� ������ �������.

  ���������:
  batchId              - Id ������
  startDate            - ��������� ���� (������� � ������� ����������� ������)
*/
function calcNextDate(
  batchId integer
  , startDate date := sysdate
)
return date
is
  -- ���������� �������
  cursor curInterval( batchId integer) is
    select
      sd.schedule_id
      , decode( iv.interval_type_code
          , Month_IntervalTypeCode, 5
          , Dayofmonth_IntervalTypeCode, 4
          , Dayofweek_IntervalTypeCode, 4
          , Hour_IntervalTypeCode, 3
          , Minute_IntervalTypeCode, 2
          , null
        )
        as interval_level
      , iv.interval_type_code
      , iv.min_value
      , iv.max_value
      , iv.step
    from
      sch_schedule sd
      left outer join sch_interval iv
        on iv.schedule_id = sd.schedule_id
    where
      sd.batch_id = batchId
    order by
      1
      , 2 desc
      , case when iv.interval_type_code = Dayofweek_IntervalTypeCode
          then 0 else 1
        end
      , 4
  ;

  subtype TInterval is curInterval%rowtype;
  type TColInterval is table of TInterval;
  colInterval TColInterval := TColInterval();

  -- ������������ ��������
  nextDate date := null;

  -- ������ ������� ��������� ����������
  iBeginInterval integer;
  -- ������ ���������� �� ��������� ��������� ����������
  iEndInterval integer;
  -- ������������ ���� �� ����������
  scheduleDate date;



  function CalcIntervalValue(
      iv TInterval
      , minValue integer
      , maxValue integer
      , minDay date
    )
    return integer
    is
  --���������� ���������� ��������, ��������������� ���������� ���������
  --� ������������� ���������� ��������� ��������.
  --
  --���������:
  --iv                        - ��������
  --minValue                  - ���������� ���������� ��������
  --maxValue                  - ����������� ���������� ��������
  --minDay                    - ����, ��������������� ������������ ��������
  --
  --���������:
  --��� ���������� ���� "���� ������" � "���� ������" ��������
  --minValue/maxValue ������������ ����� ��� ������ � ������������� ����������
  --���� ��� ������������ ��� ������ ( minDay), � ������� ������������ ����
  --������.

    -- ������������ ��������
    n integer := null;
    -- �������� �������� �� ���������
    n1 integer := iv.min_value;
    n2 integer := iv.max_value;
    -- ��������� ����������
    k integer;

  --CalcIntervalValue
  begin
    if n1 <= n2 then
      -- �������� ������������ ��������
      if iv.step > 1 then
        n2 := n2 - mod( n2 - n1, iv.step);
      end if;
      -- ����������� ������� ��������� "��� ������" � ��� ������
      if iv.interval_type_code = Dayofweek_IntervalTypeCode then
        k := to_number( to_char( minDay, 'd'));
        k := minValue +
          case when k <= n2 then
            n1 - k
          else
            n1 + 7 - k
          end
        ;
        n2 := least(
                k + ( n2 - n1)
                , to_number( to_char( last_day( minDay), 'dd'))
              )
        ;
        n1 := k;
      -- ������ "��������� ���� ������"
      elsif iv.interval_type_code = Dayofmonth_IntervalTypeCode
          and iv.min_value = -1
          then
        n1 := to_number( to_char( last_day( minDay), 'dd'));
        n2 := n1;
      end if;
      -- ���������� ����������� ��������
      n := n1;
      if n < minValue then
        n :=
          case when iv.step > 1 then
            n1 + ceil( ( minValue - n1) / iv.step) * iv.step
          else
            minValue
          end
        ;
      end if;
      -- ��������� �� �������������
      if n > n2 or n > maxValue then
        n := null;
      end if;
    end if;
    return n;
  end CalcIntervalValue;



  procedure CalcScheduleDate( iBeginInterval integer, iEndInterval integer) is
  --�������� ���������� ��������� ���� �� ����������.
  --
  --���������:
  --iBeginInterval            - ������ ������� ��������� ����������
  --iEndInterval              - ������ ���������� �� ��������� ���������
  --                            ����������

    -- ��������, �������� �� ������� (�� ������ �� ���)
    type TColValue is varray( 6) of integer;
    -- ��������� ��������
    colStartValue constant TColValue :=
      TColValue(
        to_number( to_char( startDate, 'ss'))
        , to_number( to_char( startDate, 'mi'))
        , to_number( to_char( startDate, 'hh24'))
        , to_number( to_char( startDate, 'dd'))
        , to_number( to_char( startDate, 'mm'))
        , to_number( to_char( startDate, 'yyyy'))
      )
    ;
    -- ����������� ��������
    colMinValue constant TColValue :=
      TColValue(
         0,  0,  0,  1,  1
          , colStartValue( 6)
      )
    ;
   -- ������������ ��������: ���� ������ ��������� � 00 ������ ��������� ����
   -- ������� �� ������ ������ ������� ���������� ���
    colMaxValue constant TColValue :=
      TColValue(
        0, 59, 23, null, 12
          , colStartValue( 6) + ( 4 - mod( colStartValue(6), 4))
      )
    ;
    -- ��������� ��������
    colValue TColValue := colStartValue;
    -- ������ �� ����������� ��������
    isFromMinValue boolean := false;



    function CalcValue( maxLevel integer, iBeginInterval integer)
      return boolean
      is
    --�������� ���������� �������� ������ �� ���������� ������ ( �������) �
    --���������� ���������� �������.
    --
    --���������:
    --maxLevel                - �������, ������ �� �������� ���� �������
    --iBeginInterval          - ������ ������� ���������������� ���������

      -- ������� ���������� �������
      isCalc boolean := false;
      -- ������ �������� ���������
      i integer;
      -- ����������� ���������� �������� �� ����������
      minValue integer;
      -- ������������ ���������� ��������
      maxValue integer :=
        case when maxLevel = 4 then
          to_number( to_char(
            last_day(
              to_date(
                to_char( colValue( 6), '0999')
                || to_char( colValue( 5), '09')
                || '01'
                , 'YYYYMMDD'
              )
            )
          , 'dd'))
        else
          colMaxValue( maxLevel)
        end
      ;

    --CalcValue
    begin
      -- ���������� ��������� ��������
      if isFromMinValue then
        colValue( maxLevel) := colMinValue( maxLevel);
      end if;
      -- ���������� ��� ��������� ��������
      loop
        exit when colValue( maxLevel) > maxValue;
        -- ������������, ��� �����
        isCalc := true;
        -- ��������� �� �������� ����������
        i := iBeginInterval;
        loop
          exit when i is null or i >= iEndInterval;
          if colInterval( i).interval_level = maxLevel then
            -- ������ ������ ��������
            if isCalc then
              isCalc := false;
              minValue := null;
            end if;
            -- �����, �.�. ������ ������� ��������
            exit when
              colInterval( i).min_value > minValue
              and colInterval( i).interval_type_code
                <> Dayofweek_IntervalTypeCode
            ;
            -- ���������� ����������� ���������� �������� �� ���������
            minValue := coalesce(
              CalcIntervalValue(
                colInterval( i)
                , colValue( maxLevel)
                , coalesce( minValue, maxValue)
                , case
                    when
                      colInterval( i).interval_type_code in (
                          Dayofweek_IntervalTypeCode
                          , Dayofmonth_IntervalTypeCode
                        )
                    then
                      to_date(
                        to_char( colValue( 6), '0999')
                        || to_char( colValue( 5), '09')
                        || to_char( colValue( 4), '09')
                      , 'yyyymmdd')
                  end
              )
              , minValue
            );
            -- �����, ���� ����� ���������� ��������
            if minValue = colValue( maxLevel) then
              isCalc := true;
              exit;
            end if;
          elsif colInterval( i).interval_level < maxLevel then
            -- �����, ���� ��� ������ ����������
            exit;
          end if;
          -- ��������� � ���������� ���������
          i := colInterval.next( i);
        end loop;
        -- �������� �������� �� ����������
        if not isCalc then
          isFromMinValue := true;
          if minValue is not null then
            -- ������������� �� ���������� ��������� ��������
            colValue( maxLevel) := minValue;
          else
            -- �����, �.�. ��� ���������� ��������
            exit;
          end if;
        end if;
        -- ������������ ������� �������
        if maxLevel > 1 then
          isCalc := CalcValue( maxLevel - 1, i);
        end if;
        -- �����, ���� �������� ������
        exit when isCalc;
        -- ��������� �� ��������� ��������
        colValue( maxLevel) := colValue( maxLevel) + 1;
      end loop;
      -- ������ ������� � ����������� ��������
      if not isCalc and not isFromMinValue then
        isFromMinValue := true;
      end if;
      return isCalc;
    end CalcValue;



  --CalcScheduleDate
  begin
    scheduleDate :=
      case
        when colInterval( iBeginInterval).interval_type_code is null then
          startDate
        when CalcValue( 6, iBeginInterval) then
          to_date(
            to_char( colValue( 6), '0999')
            || to_char( colValue( 5), '09')
            || to_char( colValue( 4), '09')
            || to_char( colValue( 3), '09')
            || to_char( colValue( 2), '09')
            || to_char( colValue( 1), '09')
            , 'yyyymmddhh24miss'
          )
        else
          null
      end
    ;
  end CalcScheduleDate;


--CalcNextDate
begin
  -- �������� ���������� �� ������
  open curInterval( batchId);
  fetch curInterval bulk collect into colInterval;
  close curInterval;
  iEndInterval := colInterval.first;
  loop
    exit when iEndInterval is null;
    -- ��������� Id ����������
    iBeginInterval := iEndInterval;
    -- ������� ������ ���������� ����������
    loop
      iEndInterval := colInterval.next( iEndInterval);
      exit when
        iEndInterval is null
        or colInterval( iEndInterval).schedule_id
          <> colInterval( iBeginInterval).schedule_id;
    end loop;

    -- ������������ ���� �� ����������
    CalcScheduleDate( iBeginInterval, iEndInterval);
    -- ����� ����������� ���� �� �����������
    if scheduleDate is not null
        and ( nextDate is null or scheduleDate < nextDate)
        then
      nextDate := scheduleDate;
      -- �����, ���� ��� ������ �������
      if nextDate = startDate then
        exit;
      end if;
    end if;
  end loop;
  return coalesce( nextDate, Default_RunDate);
exception when others then
  raise_application_error(
    pkg_Error.ErrorInfo
    , '������ ��� ������� ���� ���������� ������� ������ ('
      || ' batch_id=' || to_char( batchId)
      || ', startDate=' || to_char( startDate, 'yyyy-mm-dd hh24:mi:ss')
      || ').'
    , true
  );
end calcNextDate;

/* proc: stopHandler
  ������������� ������ ����������� � ������� �������� ������� ���������.

  ���������:
  batchId                     - Id ������
  sid                         - sid ������
  serial#                     - serial# ������
  operatorId                  - Id ���������
  sessionid                   - audsid ������
                                (��� �����������, ��������� �������������)
*/
procedure stopHandler(
  batchId integer
  , sid number
  , serial# number
  , operatorId integer
  , sessionid number := null
)
is
  cursor curPipe( pSid integer, pSerial integer) is
select
  ss.audsid as sessionid
  , p.name as pipe_name
from
  v$session ss
  left join v$db_pipes p
    on p.name like
      '%.COMMANDPIPE\_' || to_char( ss.sid) || '\_' || to_char( ss.serial#)
      escape '\'
where
  ss.sid = pSid
  and ss.serial# = pSerial
  ;

  ppr curPipe%rowtype;

  -- ��������� �������� � �������
  pipeStatus number := null;
  -- ���� ������� ������
  isFound boolean := false;

--StopHandler
begin
  if operatorId is not null then
    pkg_Operator.setCurrentUserId( operatorId => operatorId);
  end if;
  logger.info(
    messageText             =>
        '������ �������� ������� ��������� ����������� ('
        || ' batch_id=' || to_char( batchId)
        || ', sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ').'
    , messageLabel          => pkg_SchedulerMain.StopHandler_BatchMsgLabel
    , messageValue          => sessionid
    , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
    , contextValueId        => batchId
    , openContextFlag       => 1
  );
  open curPipe( sid, serial#);
  fetch curPipe into ppr;
  close curPipe;
  if ppr.pipe_name is not null then
    -- �������� ���������
    dbms_pipe.pack_message( 'stop');
    pipeStatus := dbms_pipe.send_message(
      pipename  => ppr.pipe_name
      , timeout => 0
    );
    logger.log(
      levelCode               =>
          case when pipeStatus = 0 then
            lg_logger_t.getInfoLevelCode()
          else
            lg_logger_t.getWarnLevelCode()
          end
      , messageText           =>
          case when pipeStatus = 0 then
            '������� ��������� ������� ����������'
          else
            '������ ��� �������� ������� ���������'
          end
          || ' ('
          || ' pipe="' || ppr.pipe_name || '"'
          || case when pipeStatus > 0 then
            ', status=' || pipeStatus
            end
          || ').'
      , messageValue          => ppr.sessionid
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => batchId
      , openContextFlag       => 0
    );
  else
    logger.info(
      messageText             =>
          case when ppr.sessionid is null then
              '�� ������� ������'
            else
              '�� ������ �����'
            end
          || ' ��� �������� ������� ���������.'
      , messageValue          => ppr.sessionid
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => batchId
      , openContextFlag       => 0
    );
  end if;
exception when others then
  logger.error(
    messageText             =>
        '������ ��� �������� ������� ��������� �����������.'
        || chr( 10)
        || logger.getErrorStack()
    , messageValue          => ppr.sessionid
    , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
    , contextValueId        => batchId
    , openContextFlag       => 0
  );
end stopHandler;

/* iproc: execBatch
  ��������� ��������� ����� �������

  ���������:
  batchId                     - id �������
  oracleJobId                 - id ������� Oracle (��� ����������� batch_id)
  nextDate                    - ���� ���������� �������
  resultId                    - id ���������� ���������� ������

  ���������:
  - 2-� � 3-� �������� ������������ ������ ���� ������ �������� �� ����� (is
    null)
*/
procedure execBatch(
  batchId integer := null
  , oracleJobId number := null
  , nextDate in out date
  , resultId out integer
)
is

  -- ����� ��� ���������� ����� dbms_scheduler
  cServerLoginName constant varchar2(20) := 'ServerSezam';
  isOperatorLogonDone boolean := false; --������� ����, ��� ��� �������� �����
  -- �������� �� ��������� ����� � ������� Logging
  isLoggingStackAvailable boolean := false;

  lIsJob boolean := batchId is null;    --���� �������������� ���������� (job)
  lBatchId sch_batch.batch_id%type;     --Id ������������ ������
  lStartDate date := sysdate;           --���� ������ ���������� ������
  lStartLogId integer;                  --Id ���� � ������� ������

  -- ������� ������������ ������ (� 1)
  batchLevel pls_integer := nvl( gBatchLevel, 0) + 1;
  -- Id ���������� ���������� ������
  batchResultId sch_result.result_id%type := True_ResultId;
  -- ����� ��������� � ���������� ������
  batchResultMessage varchar2(4000) :=
    '���������� ������ ������� ��������� ( ������������� ���������).';



  -- ��������� ������������ ������
  batchNameRus sch_batch.batch_name_rus%type;
  batchShortName sch_batch.batch_short_name%type;
  batchRetrialCount sch_batch.retrial_count%type;
  batchRetrialTimeout sch_batch.retrial_timeout%type;
  batchRetrialNumber sch_batch.retrial_number%type;

  batchScheduleDate date;               --���� ������� �� ����������



  -- ������� ���������� �������
  cursor curContent( pBatchId number) is
    select
      bc.batch_content_id
      , j.job_id
      , j.job_name
      , j.job_what
      , cursor (
          select
            cn.condition_id
            , cn.check_batch_content_id
            , cn.result_id
          from
            sch_condition cn
          where
            cn.batch_content_id = bc.batch_content_id
          order by
            cn.check_batch_content_id
            , cn.result_id
            , cn.condition_id
        ) as condition
    from
      sch_batch_content bc
      , sch_job j
    where
      bc.date_del is null
      and bc.job_id = j.job_id
      and j.date_del is null
      and bc.batch_id = pBatchId
    order by
      bc.order_by
      , bc.batch_content_id
  ;

  type TCondition is record             --������� �� ���������� �������
  (
    conditionId sch_condition.condition_id%type
    , contentId sch_condition.check_batch_content_id%type
    , resultId sch_result.result_id%type
  );

  type TcolCondition is table of TCondition;

  type TContent is record               --��������� �������
  (
    contentId sch_batch_content.batch_content_id%type
    , jobId sch_job.job_id%type
    , jobName sch_job.job_name%type
    , jobWhat sch_job.job_what%type
    , colCondition TcolCondition := TcolCondition()
  );

  type TcolContent is table of TContent;
  -- ��� ������� ������
  colContent TcolContent := TcolContent();



  -- ��������� ���������� �������
  type TcolResult is table of sch_result.result_id%type
    index by binary_integer;

  colResult TcolResult;



  procedure CheckLogin is
  --��������� ������� ����������� � ���������
  begin
    begin
      -- ���������� ������������ ��������
      if pkg_Operator.GetCurrentUserId is not null then null; end if;
    exception when others then
      -- �������� ������������������, ���� ����� ����������� ��� ����
      if SQLCODE = pkg_Error.OperatorNotRegister and lIsJob then
        -- ���������� ������������ ��������
        if pkg_Operator.Login( cServerLoginName) is not null then null; end if;
        isOperatorLogonDone := true;
      else
        raise;
      end if;
    end;
  exception when others then            --��������� ���������� �� ������
    raise_application_error(
      pkg_Error.ErrorInfo
      , '��� ���������� ������ ���������� ������������������.'
      , true
    );
  end CheckLogin;

  procedure CheckLoggingAvailable
  is
  -- �������� ����������� ������ Logging
  -- ��� ��������� ��������� �� ������
  begin
    begin
      execute immediate
        'begin if false then pkg_Logging.ClearErrorStack(); end if;end;';
      isLoggingStackAvailable := true;
    exception when others then
      isLoggingStackAvailable := false;
    end;
  end CheckLoggingAvailable;

  function getJobScheduleDate return date is
  --���������� ���� ������ �� ���������� �������� ������������ �������

    vDate date;                         --������������ ����

  begin
    select
      j.next_date
    into vDate
    from
      user_jobs j
    where
      j.job = sys_context( 'USERENV', 'FG_JOB_Id')
    ;
    return vDate;
  exception when no_data_found then
    return null;
  end getJobScheduleDate;



  procedure findBatch is
  --���������� ����������� �����

    lOracleJobId sch_batch.oracle_job_id%type;

  begin
    if lIsJob then
      -- ������������� ����� ������ ������ � ����������� �� ���� �������
      lOracleJobId := oracleJobId;
      lBatchId := null;
      batchScheduleDate := getJobScheduleDate;
    else
      lOracleJobId := null;
      lBatchId := batchId;
    end if;
    select                              --���������� ����� ��� ����������
      bt.batch_id
      , bt.batch_name_rus
      , bt.batch_short_name
      , bt.retrial_count
      , bt.retrial_timeout
      , bt.retrial_number
    into lBatchId, batchNameRus, batchShortName
      , batchRetrialCount, batchRetrialTimeout, batchRetrialNumber
    from
      sch_batch bt
    where
      bt.date_del is null
      and
        (
        bt.batch_id = lBatchId
        or bt.oracle_job_id = lOracleJobId
        )
    ;
    -- ��������� ������ ���������� ������
    logger.info(
      messageText             =>
        '������'
          || case when lIsJob and batchRetrialNumber is not null
              then ' ���������� (N' || batchRetrialNumber || ')'
              end
          || ' ���������� ������ "' || batchNameRus
          || '" [' || batchShortName || ']'
          || case when lIsJob
              then ' (oracle_job_id=' || lOracleJobId || ')'
              end
          || '.'
      , messageLabel          => pkg_SchedulerMain.Exec_BatchMsgLabel
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => coalesce( lBatchId, batchId)
      , openContextFlag       => 1
    );
    lStartLogId := lg_logger_t.getOpenContextLogId();
  exception when no_data_found then     --������ ��������� ��� ���������� ������
    raise_application_error(
      pkg_Error.BatchNotFound
      , '�� ������ ����� ��� ����������.'
    );
  end findBatch;



  procedure LoadData is
  --��������� ������ ������

    pragma autonomous_transaction;      --���������� ���������� ����������

    -- ���������� ��� ������� �������
    type TcurCondition is ref cursor return TCondition;
    curCondition TcurCondition;


    rc TContent;                        --������������� ������ ��� fetch
    cn TCondition;

  begin
    set transaction read only;          --������������ ������������� ������
    findBatch;                          --���������� ����������� �����
    open curContent( lBatchId);         --������� �������
    loop
      fetch curContent into             --�������� ������ � ������������� ������
        rc.contentId
        , rc.jobId
        , rc.jobName
        , rc.jobWhat
        , curCondition
      ;
      exit when curContent%notFound;
      -- �������� ������� ����������
      rc.colCondition := TcolCondition();
      loop
        fetch curCondition into cn;
        exit when curCondition%notfound;
        rc.colCondition.extend;
        rc.colCondition( rc.colCondition.last) := cn;
      end loop;
      colContent.extend;                --��������� ��������� �������
      colContent( colContent.last) := rc;
    end loop;
    close curContent;
    commit;                             --��������� ���������� ����������
  end LoadData;



  function CheckCondition( iJob in binary_integer)
    return boolean is
  --���������, ��� ������� ������� ��� ���������� ������� �����������
  --���������:
  --iJob                      - ���������� ����� ������� � ��������� colContent

    -- ������� ������ � ��������� �������
    i binary_integer := colContent( iJob).colCondition.first;
    -- ������ � ����������� �������� ������ ������� Id ������������ �������
    cn TCondition;
    contentId sch_batch_content.batch_content_id%type;
    resultId sch_result.result_id%type; --��������� ���������� �������
    isOk boolean := true;               --��������� �������� �������

  begin
    loop
      exit when i is null;
      -- �������� ������� �������
      cn := colContent( iJob).colCondition( i);
      if cn.contentId = contentId then
        null;
      else                              --���� ����������� ����� �������
        -- ���������� ��������, ���� �� ���������� ������� ��� �� ������
        if contentId is not null and not isOk then
          exit;
        end if;
        contentId := cn.contentId;      --�������� ����� ��������
        isOk := false;
        if colResult.exists( contentId) then
          resultId := colResult( contentId);
        else                            --�������� � �������������� � ��������
          logger.warn(
            '������� ��������� � �������, ������� ����������� �����.'
            , messageValue    => cn.conditionId
          );
          exit;                         --���������� ������������ ��������
        end if;
      end if;
      if not isOk then                  --��������� �������, ���� ��� �����
        isOk := cn.resultId = resultId;
      end if;
      -- ��������� � ���������� �������
      i := colContent( iJob).colCondition.next( i);
    end loop;
    return isOk;
  end CheckCondition;



  procedure ExecJob(
    jobWhat in sch_job.job_what%type
    , jobResultId out sch_result.result_id%type
    , jobResultMessage out varchar2
    , restartBatchFlag out integer
    , retryBatchFlag out integer
    ) is
  --��������� PL/SQL ���� � ������������� ��������� ����������
  --
  --���������:
  --jobWhat                   - ����� ������������ PL/SQL
  --jobResultId               - Id ���������� ����������
  --jobResultMessage          - ����� ��������� � ���������� ����������
  --restartBatchFlag          - ���� ������������ ����������� ������
  --retryBatchFlag            - ���� ������������� ����������� ������
  --
  --���������:
  --������ ������� �������� ��������� ����������:
  --
  --batchShortName            - �������� ��� ������������ ������
  --
  --����� ���� ����� ������������� �������� ��������� ����������:
  --
  --jobResultId               - Id ���������� ���������� �������
  --jobResultMessage          - ����� ��������� � ���������� ���������� �������
  --restartBatchFlag          - ���� ������������ ����������� ������
  --retryBatchFlag            - ���� ���������� ���������� ������
  --
  --������� ����� ������������ ���� ������� ���������� ��� ������� ����������,

    -- ���������� ��������� �������� ����������� ����������
    lJobResultId sch_result.result_id%type := True_ResultId;
    lJobResultMessage varchar2(4000) := null;
    -- ����� ����������� � ���������� �������
    lIsRestartBatch integer := 0;
    lIsRetryBatch integer := 0;

    lErrorCode number;                  --��� ������ �������
    -- ����� ��������� �� ������ �������
    lErrorMessage varchar2( 32767);
    -- ����� sql ��� ������� �������
    sqlText varchar2( 32767) := replace(replace(
'declare
  /* batch: ' || batchShortName || ' */
  batchShortName sch_batch.batch_short_name%type:= :batchShortName;
  jobResultId sch_result.result_id%type := :lJobResult;
  jobResultMessage varchar2(4000) := :lJobResultMessage;
  restartBatchFlag integer := :lIsRestartBatch;
  retryBatchFlag integer := :lIsRetryBatch;
begin
  ' || jobWhat || '
  :lJobResult := jobResultId;
  :lJobResultMessage := jobResultMessage;
  :lIsRestartBatch := restartBatchFlag;
  :lIsRetryBatch := retryBatchFlag;
  -- ����� ��������� �������������� ������
  $(clearError);
exception when others then
  :errorCode := sqlcode; :errorMessage := $(getError);
end;'
    -- ������ ���������������
    , '$(getError)'
    , case when isLoggingStackAvailable then
        -- ����������� ��������� ����������
        'substr( pkg_Logging.GetErrorStack(), 1, 32000)'
      else
        'sqlerrm'
      end
    )
    , '$(clearError)'
    , case when isLoggingStackAvailable then
        'pkg_Logging.ClearErrorStack()'
      else
        'null'
      end
    );

    procedure LogJobError
    is
    -- ����������� ������ job, � ������ ����
    -- ���������� ���������� ����������
      Split_Message_Length constant integer := 4000-10;
    begin
      if length( lErrorMessage) < 4000 then
        logger.error(
          messageText           => lErrorMessage
          , messageValue        => lErrorCode
        );
                                       -- ����� ���������, ���� ���
                                       -- ������� �������
      elsif lErrorMessage is not null then
        for idx in
          1..ceil( length( lErrorMessage) / Split_Message_Length)
        loop
          logger.error(
            messageText           => rpad( '#' || to_char( idx), 3) || ':'
                                     ||
                                     substr( lErrorMessage
                                       , ( idx-1) * Split_Message_Length + 1
                                       , Split_Message_Length
                                     )
            , messageValue        => lErrorCode
          );
        end loop;
      else
        logger.error(
          messageText           => '��������� �� ������ ����������'
          , messageValue        => lErrorCode
        );
      end if;
    end LogJobError;

  begin
    begin
      execute immediate                -- ��������� �������
        sqlText
      using
        in batchShortName
        , in out lJobResultId, in out lJobResultMessage
        , in out lIsRestartBatch, in out lIsRetryBatch
        , out lErrorCode, out lErrorMessage;

                                       -- ��������� ������ ���������� �������
      if lErrorCode is not null then
        lJobResultId := Error_ResultId;
      end if;
    exception when others then         -- ��������� ������ ������� �������
      lJobResultId := Runerror_ResultId;
      lErrorCode := sqlcode;
      lErrorMessage := sqlerrm;
    end;
    if lErrorCode is not null then     -- ��������� ������
      LogJobError;
    end if;
                                       -- ��������� ���� ������� ���
                                       -- ������������� ����� �����������
    if lIsRestartBatch = 1
        and lIsRetryBatch = 1 then
      lIsRetryBatch := 0;
      logger.warn(
        '��������� ����� ���������� ������� ������ ���� ���������������'
        || ' � ����� � ���������� ����� ������������ �����������.'
      );

    end if;
    -- ������������� ��������� �� ����������
    if lJobResultMessage is null and lJobResultId is not null then
      lJobResultMessage :=
        case
          when lJobResultId = True_ResultId then
            '������� ��������� ( ������������� ���������).'
          when lJobResultId = False_ResultId then
            '������� ��������� ( ������������� ���������).'
          when lJobResultId = Error_ResultId then
            '������� ��������� � �������.'
          when lJobResultId = Runerror_ResultId then
            '������� �� ����������� ��-�� ������.'
          when lJobResultId = Retryattempt_ResultId then
            '������� ��������� � ����������� "��������� �������".'
        end
      ;
    end if;
    jobResultId := lJobResultId;        --���������� ��������� ����������
    jobResultMessage := lJobResultMessage;
    restartBatchFlag := lIsRestartBatch;
    retryBatchFlag := lIsRetryBatch;
  end ExecJob;



  procedure Exec is
  --��������������� ��������� ������� ������
    -- ��������� ���������� �������
    lJobResultId sch_result.result_id%type;
    -- ����� ��������� � ���������� �������
    lJobResultMessage varchar2(4000);

    restartBatchFlag integer;           --���� ������������ ����������� ������
    retryBatchFlag integer;             --���� ���������� ���������� ������
    i pls_integer := colContent.first;  --������� �����

  begin
    loop
      exit when i is null;
      -- ��������� ������ �������
      logger.info(
        messageText             =>
            '������ ���������� ������� "' || colContent( i).jobName ||'".'
        , contextTypeShortName  => pkg_SchedulerMain.Job_CtxTpSName
        , contextValueId        => colContent( i).jobId
        , openContextFlag       => 1
      );
      -- �������� � ������������� ��������� ����� ����� ������ Logging
      if not isLoggingStackAvailable then
        logger.info(
          '��������� ����� � ������� ������ Logging �� ��������'
        );
      end if;
      if CheckCondition( i) then
        ExecJob( colContent( i).jobWhat, lJobResultId, lJobResultMessage
               , restartBatchFlag, retryBatchFlag);
      else
        lJobResultId := Skip_ResultId;
        lJobResultMessage := '������� ���� ��������� �� �������.';
      end if;
      -- ��������� ���������� �������
      logger.info(
        messageText             => lJobResultMessage
        , messageValue          => lJobResultId
        , contextTypeShortName  => pkg_SchedulerMain.Job_CtxTpSName
        , contextValueId        => colContent( i).jobId
        , openContextFlag       => 0
      );
      -- ��������� ��������� ����������
      colResult( colContent( i).contentId) := lJobResultId;

      if restartBatchFlag = 1 then
        -- �������� � ����������� ������.
        logger.info(
          '���������� ������� ������ ������� � ����� � ���������� �����'
          || ' ������������ ����������� ������.'
        );
        i := colContent.first;          --������ �������� � ������� �������.
      elsif retryBatchFlag = 1 then
        -- �������� � ����������� ���������.
        logger.info(
          '���������� ������� ���������� � ����� � ���������� �����'
          || ' ���������� ���������� ������.'
        );
        -- ������������� ��������� ���������� ������.
        batchResultId := Retryattempt_ResultId;
        batchResultMessage :=
          '���������� ������ ��������� �� �������� "��������� �������".';
        exit;                           --���������� ���������� �������.
      elsif lJobResultId = Runerror_ResultId then
        -- �������� � ����������� ���������.
        logger.info(
          '���������� ������ �������� � ����� � ������� ��� ������� �������.'
        );
        -- ������������� ��������� ���������� ������.
        batchResultId := Error_ResultId;
        batchResultMessage :=
          '���������� ������ ��������� � �������.';
        exit;                           --���������� ���������� �������.
      else
        i := colContent.next( i);       --�������� ��������� ������
      end if;
    end loop;
  exception when others then            --�������� ����� ������������� ������
    raise_application_error(
      pkg_Error.ExecJobInterrupted
      , '���������� ������� ���� �������� ��-�� ������.'
      , true
    );
  end Exec;



  function LogError return boolean is
  --����� ��������� � ������� ������ � ���
  --���������� ��������� ���������� (�����/�� �����), �� �������� ����������
  begin
    if lStartLogId is null then
      -- ��������� ������ ���������� ������ ���� ��� ��� �� �������
      logger.info(
        messageText             =>
          '������ ���������� ��������� pkg_Scheduler.execBatch'
          || case
              when lIsJob then '( oracleJobId => '|| oracleJobId ||').'
              else '( batchId => ' || batchId ||').'
            end
        , messageLabel          => pkg_SchedulerMain.Exec_BatchMsgLabel
        , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
        , contextValueId        => coalesce( lBatchId, batchId)
        , openContextFlag       => 1
      );
      lStartLogId := lg_logger_t.getOpenContextLogId();
    end if;
    -- ��������� ������
    logger.error(
      messageText             => SQLERRM
      , messageValue          => SQLCODE
    );
    return true;
  exception when others then
    return false;
  end LogError;



  procedure UpdateRetrialNumber(
    retrialNumber in sch_batch.retrial_number%type) is
  --��������� ����� ��������� ���������� ������� ������� � �������
  --
  --���������:
  --retrialNumber             - ����� �������� ���� retrial_number
    pragma autonomous_transaction;      --���������� ���������� ����������

    cursor curBatch( batchId integer, oracleJobId integer) is
      select
        b.batch_id
        , b.retrial_number
      from
        sch_batch b
      where
        b.batch_id = batchId
        and b.oracle_job_id = oracleJobId
      for update of b.retrial_number nowait
    ;

  --UpdateRetrialNumber
  begin
    for rec in curBatch( lBatchId, oracleJobId) loop
      update
        sch_batch b
      set
        retrial_number = retrialNumber
      where current of curBatch;
    end loop;
    commit;
  exception when others then            --��������� ��������� �� ������
    rollback;
    raise_application_error(
      pkg_Error.ErrorInfo
      , '�� ������� �������� �������� ���� sch_batch.retrial_number.'
      , true
    );
  end UpdateRetrialNumber;



  procedure setNextDate is
  --������������� ���� ���������� ��������������� ������� ������

    -- ���������� ��������� ���� ���������� �������
    vMinDate constant date := lStartDate + 1/24/60/60;

    -- ��������� �� ��������� ����������
    isAllowRetrial boolean := nvl( batchRetrialNumber, 0) < batchRetrialCount;

    -- ����� �������
    vRetrialNumber sch_batch.retrial_number%type := null;
    vRetrialDate date;                  --���� ���������� ����������

    vDate date;                         --���� ���������� �������

  begin
    -- ���� ���������� ������� �� ����������
    begin
      vDate := calcNextDate( lBatchId, vMinDate);
    exception when others then
      if not LogError then
        raise;
      end if;
      logger.warn(
        '�� ������� ���������� ���� ������� ������ �� ����������.'
      );
      -- ������������� ��������� ������
      batchResultId := Error_ResultId;
      batchResultMessage :=
        '��� ���������� ���������� ������ �������� ������.';
    end;
    -- �������� ��������� ����� �� ��������� ����������, ���� �� ��������
    -- �������
    if isAllowRetrial and batchResultId not in ( True_ResultId, False_ResultId)
        then
      vRetrialNumber := nvl( batchRetrialNumber, 0) + 1;
      -- ���������� ���� ���������� ����������
      vRetrialDate := greatest(
        nvl( batchScheduleDate, lStartDate)
          + coalesce( batchRetrialTimeout, interval '0' second)
        , sysdate + 1 / 24 / 60 / 60    --������������ ����� ��������� ��������
        );
      -- �� ���������� ���� �������, ���� ��� ������ ��� ����� ���� ����������
      -- �������, �������� �� �����������
      if vRetrialDate >= vDate and vDate > vMinDate then
        vRetrialNumber := null;
      else
        vDate := vRetrialDate;
      end if;
    end if;
    -- ��������� ����� ���������� �������
    if nvl( vRetrialNumber, 0) != nvl( batchRetrialNumber, 0) then
      begin
        UpdateRetrialNumber( vRetrialNumber);
      exception when others then        --��������� ������, ���� ������� ��
        if not LogError then            --�������������
          raise;
        end if;
      end;
    end if;
    -- ������������ ���� ������� (����� job �� ����� � �� ����������)
    if vDate is null then
      vDate := to_date( '01.01.4000', 'dd.mm.yyyy');
    elsif vDate < sysdate then          --������������ ���� ����� ������� �����
      vDate := sysdate;
    end if;
    nextDate := vDate;                  --����������� ������������ ����

    -- ��������� ���� ���������� �������
    logger.info(
      messageText           =>
        '���� '
        || case when vRetrialNumber is null
            then '����������'
            else '���������� (N' || vRetrialNumber || ')'
            end
        || ' ������� ������ ����������� � '
        || to_char( nextDate, 'dd.mm.yyyy hh24:mi:ss') || '.'
    );
  exception when others then            --��������� ���������� �� ������
    raise_application_error(
      pkg_Error.ErrorInfo
      , '�� ����� ����������� ���� ���������� ������� ������ ��������� ������.'
      , true
    );
  end setNextDate;



  procedure FinishBatch is
  --���������� ���������� ������
  begin
    if lIsJob then                      --������������� ���� ���������� �������
      begin                             --����� ����������������� ����������
        rollback;
      exception when others then
        if not LogError then
          raise;
        end if;
        logger.warn( '�� ����� ���������� ������ (rollback) ��������� ������.');
      end;
      setNextDate;
    end if;
    logger.info(
      messageText             => batchResultMessage
      , messageValue          => batchResultId
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => coalesce( lBatchId, batchId)
      , openContextFlag       => 0
    );
    if isOperatorLogonDone is null then --��������� Logoff, ��� �������� Logon
      begin
        pkg_Operator.Logoff;
      exception when others then        --���������� ����� ������
        null;
      end;
    end if;
  end FinishBatch;



  procedure SendNotify( errorMessage in varchar2 := null) is
  --�������� ����������� �� e-mail, ���� ��� ����������.
  --
  --���������:
  --errorMessage              - ��������� �� ������ (���� ������� �� �����������
  --                            ����������)

    -- ������������ ������ ������ ���������
    maxMessageLength constant pls_integer := 32767;

    subject varchar2( 1024);            --���� ���������
    message varchar2( 32767);           --����� ���������

    nError pls_integer := 0;            --����� ������
    nWarning pls_integer := 0;          --����� ��������������



    procedure AddMessageText( text in varchar2, isPrefix boolean := false) is
    --��������� ����� � ��������� �� �������� ������������
    begin
      message :=                        --�������� ����� �� ������������ �����
        case when isPrefix then
          text
          || substr( message, 1, maxMessageLength - nvl( length( text), 0))
        else
          message
          || substr( text, 1, maxMessageLength - nvl( length( message), 0))
        end
      ;
    end;



    procedure AddHeaderInfo is
    --��������� � ��������� ���������� � ������

      -- ����������� ����� ���������
      valueSpace varchar2(10) := ':' || chr(10) || '  ';

      header varchar2( 8000);           --����� ��������� ���������

      -- ������������ ���������� ������
      duration interval day to second :=
        numtodsinterval( sysdate - lStartDate, 'day');

    begin
      -- ���� ���������
      subject :=
        coalesce( batchShortName,
          case
            when batchId is not null then 'batchId=' || batchId
            when oracleJobId is not null then 'oracleJobId=' || oracleJobId
          end
        )
        || ': ' ||
        case when nError > 0 or errorMessage is not null
          then '������'
          else '��������������'
        end
      ;
      -- ����� ���������
      header :=
        '�����'
          || valueSpace
          || coalesce( batchNameRus,
            case when batchId is not null then
              'batch_id=' || batchId
            end
            || case when batchId is not null and oracleJobId is not null then
              ', '
            end
            || case when oracleJobId is not null then
              'oracle_job_id=' || oracleJobId
            end
            )
          || '.'                        -- . ����� Outlook �� ������ ������
          || chr(10)
        || case when batchRetrialNumber is not null then
          '����� ���������� ����������'
          || valueSpace
          || to_char( batchRetrialNumber)
          || chr(10)
          end
        || '���� �������'
          || valueSpace
          || to_char( lStartDate, 'dd.mm.yyyy hh24:mi:ss')
          || chr(10)
        || '������������ ����������'
          || valueSpace
          || trim( to_char(
                extract( day from duration) * 24
                + extract( HOUR from duration)
              , '9900'))
            || ':' || to_char( extract( MINUTE from duration), 'fm00')
            || ':' || to_char( extract( second from duration), 'fm00')
          || chr(10)
        || '��������� ����������'
          || valueSpace
          || batchResultMessage
          || chr(10)
        || 'Id ��������� ����'
          || valueSpace
          || to_char( lStartLogId)
          || chr(10)
        || '���� ���������� �������'
          || valueSpace
          || to_char( nextDate, 'dd.mm.yyyy hh24:mi:ss')
          || chr(10)
      ;
      -- ��������� ���������� � ���-�� ������
      if nError > 0 or nWarning > 0 then
        header := header
          || chr(10)
          || case when nError > 0 then
            '������ - ' || to_char( nError)
            end
          || case when nWarning > 0 then
              case when nError > 0
                then ', �������������� - '
                else '�������������� - '
              end
              || to_char( nWarning)
            end
          || '.' || chr(10)
        ;
      end if;
      AddMessageText( header, true);
    end AddHeaderInfo;



    procedure AddDetailInfo is
    --��������� � ��������� ���������� �� ������ ������/��������������.

      -- ������ ������ � ��������������
      cursor curDetail is
        select
          lg.log_id
          , case lg.level_code
              when pkg_Logging.Warn_LevelCode then
                Warning_MessageTypeCode
              else
                Error_MessageTypeCode
            end
            as message_type_code
          , lg.message_text
          , (
            select
              max( jb.job_name)
                keep( dense_rank last order by js.log_id)
            from
              lg_log js
              inner join lg_context_type jct
                on jct.context_type_id = js.context_type_id
                  and jct.context_type_short_name
                    = pkg_SchedulerMain.Job_CtxTpSName
              inner join sch_job jb
                on jb.job_id = js.context_value_id
            where
              js.sessionid = lg.sessionid
              and js.log_id between lStartLogId + 1 and lg.log_id - 1
              and js.open_context_flag = 1
            )
            as job_name
        from
          v_lg_context_change_log ccl
          inner join lg_log lg
            on lg.sessionid = ccl.sessionid
              and lg.log_id >= ccl.open_log_id
              and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
          left join lg_context_type ct
            on ct.context_type_id = lg.context_type_id
        where
          ccl.log_id = lStartLogId
          and lg.level_code in
            (
              pkg_Logging.Fatal_LevelCode
              , pkg_Logging.Error_LevelCode
              , pkg_Logging.Warn_LevelCode
            )
        order by
          lg.log_id
      ;

      nDetail pls_integer := 0;         --����� ������ � ��������������

    begin
      for rec in curDetail loop
        nDetail := nDetail + 1;         --����������� ��������
        if rec.message_type_code = Error_MessageTypeCode then
          nError := nError + 1;
        else
          nWarning := nWarning + 1;
        end if;
        AddMessageText(                 --����� ��������� ��������
          chr(10) || to_char( nDetail) || '. '
          || case when rec.message_type_code = Error_MessageTypeCode
              then '������'
              else '��������������'
            end
            || ' (log_id=' || to_char( rec.log_id) || ')'
            || chr( 10)
          || case when rec.job_name is not null then
              chr(10) || '�������:' || chr(10) || '  '
              || rec.job_name || chr(10)
            end
          || chr( 10)
          || '���������:'
            || chr(10)
          || rec.message_text
            || chr(10)
        );
      end loop;
      if nDetail > 0 then               --��������� ���������
        AddMessageText( chr(10) || '��������� ����������:' || chr(10), true);
      end if;
    end AddDetailInfo;



  --SendNotify
  begin
    -- �������� ��� ������������� ����������� ������� �������� ������ ���
    -- ������� �����
    if gSendNotifyFlag = 1 and lIsJob and gBatchLevel = 1
        then
      AddDetailInfo;
      if errorMessage is not null then
        nError := nError + 1;
        AddMessageText(
          chr(10)
          || '!!! ������ ��� ���������� ������:' || chr(10) || errorMessage
        );
      end if;
      if message is not null then
        AddHeaderInfo;
        pkg_Common.SendMail(
          mailSender => pkg_Common.GetMailAddressSource( 'scheduler')
          , mailRecipient => pkg_Common.GetMailAddressDestination
          , subject => subject
          , message => message
        );
      end if;
    end if;
  exception when others then            --��������� � ���������� ����������
    if LogError then
      null;
    end if;
  end SendNotify;



--ExecBatch
begin
  gBatchLevel := batchLevel;            --������ ���������� ������� ����������
  begin
    CheckLogin;                         --�������� ����������� ���������
    CheckLoggingAvailable;              --�������� ����������� ������ Logging
    LoadData;                           --��������� ������ ������
    Exec;                               --��������� �������
  exception when others then
    batchResultId := Error_ResultId;
    batchResultMessage := '���������� ������ ��������� � �������.';
    -- ����������� ������� ����������, ���� �� ������� ����������� ������
    if not LogError then
      raise;
    end if;
  end;
  begin
    FinishBatch;                        --��������� ������
    SendNotify;                         --�������� �����������
  exception when others then            --��������� ���������� �� ������
    raise_application_error(
      pkg_Error.ErrorInfo
      , '�� ������� ��������� ��������� ���������� ������ ['
        || batchShortName || '] (log_id=' || lStartLogId || ').'
      , true
    );
  end;
  gBatchLevel := case when batchLevel = 1 then null else batchLevel - 1 end;
  resultId := batchResultId;            --���������� ��������� ���������� ������
exception when others then
  SendNotify( SQLERRM);                 --�������� �����������
  gBatchLevel := case when batchLevel = 1 then null else batchLevel - 1 end;
  -- ��������� ���������� �� ���������� ������ ���� �� ���� ������������
  if lStartLogId is null then
    raise_application_error(
      pkg_Error.ErrorInfo
      , '��� ���������� ��������� pkg_Scheduler.execBatch'
        || case
            when lIsJob then '( oracleJobId => '|| oracleJobId ||')'
            else '( batchId => ' || batchId ||')'
          end
        || ' ��������� ������.'
      , true
    );
  else
    raise;
  end if;
end execBatch;

/* proc: execBatch( BATCH_ID)
  ��������� ��������� ����� �������

  ���������:
  batchId              - Id �������
*/
function execBatch(
  batchId integer
)
return integer
is
  nextDate date;                        --��������� ����������
  resultId sch_result.result_id%type;   --��������� ���������� ������

begin
  execBatch( batchId, null, nextDate, resultId);
  return resultId;
end execBatch;

/* proc: execBatch( BATCH_SHORT_NAME)
  ��������� ��������� ����� �������

  ���������:
  batchShortName       - ��� (batch_short_name) ������������ �������
*/
function execBatch(
  batchShortName varchar2
)
return integer
is
  nextDate date;                        --��������� ����������
  batchId sch_batch.batch_id%type;      --Id ������������ �������
  resultId sch_result.result_id%type;   --��������� ���������� ������

begin
  begin
    select
      b.batch_id
    into batchId
    from
      sch_batch b
    where
      b.date_del is null
      and b.batch_short_name = batchShortName
    ;
  exception when no_data_found then
    raise_application_error(
      pkg_Error.BatchNotFound
      , '�� ������ ����� ��� ���������� � ������ ['
        || batchShortName || '].'
    );
  end;
  execBatch( batchId, null, nextDate, resultId);
  return resultId;
end execBatch;



/* group: ������ ������� */

/* func: clearLog
  ������� ������ ������ ����.

  ���������:
  toDate                      - ����, �� ������� ���� ������� ����
                                (�� �������, � ������� ����� systimestamp)

  �������:
  ����� ��������� �������.
*/
function clearLog(
  toDate date
)
return integer
is

  toTime timestamp with time zone := to_timestamp_tz(
    to_char( toDate, 'dd.mm.yyyy hh24:mi:ss')
      || to_char( systimestamp, ' tzh:tzm')
    , 'dd.mm.yyyy hh24:mi:ss tzh:tzm'
  );


  nDeleted integer := 0;

-- clearLog
begin

  -- ������� ���� ������, � ������� ��� ������ ������������ �� ��������� ����
  delete
    lg_log lg
  where
    lg.sessionid in
      (
      select
        t.sessionid
      from
        lg_log t
      where
        t.log_time < sys_extract_utc( toTime)
        and t.sessionid is not null
      group by
        t.sessionid
      having
        not exists
          (
          select
            null
          from
            lg_log tt
          where
            tt.sessionid = t.sessionid
            and tt.log_time >= toTime
          )
      )
  ;
  nDeleted := nDeleted + sql%rowcount;
  logger.debug( 'deleted by sessionid: ' || nDeleted);

  -- ������� ���������� ������ ������� ���� (��� sessionid)
  delete from
    sch_log lg
  where
    lg.rowid in
      (
      select
        t.rowid
      from
        sch_log t
      start with
        t.log_id in
          (
          select /*+ index(t2 sch_log_ix_root_date_ins) */
            t2.log_id
          from
            sch_log t2
          where
            case when
              t2.parent_log_id is null
              and t2.sessionid is null
            then
              t2.date_ins
            end < toDate
          )
      connect by
        prior t.log_id = t.parent_log_id
      )
  ;
  nDeleted := nDeleted + SQL%ROWCOUNT;

  return nDeleted;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� �������� ������ ������� ���� ('
      || ' toDate=' || to_char( toDate, 'dd.mm.yyyy hh24:mi:ss')
      || ').'
    , true
  );
end clearLog;

/* func: getLog
  ���������� ����� �� ���� ( ������� lg_log).

  ���������:
  rootLogId                - Id �������� ������ �� lg_log

  ���������:
  - ������� ������������� ��� ������������� � SQL-�������� ����:
  select lg.* from table( pkg_Scheduler.getLog( :rootLogId)) lg
*/
function getLog(
  rootLogId integer
)
return
  sch_log_table_t
pipelined parallel_enable
is

  cursor curLog( rootLogId integer) is
    select
      sch_log_t(
        lg.log_id
        , nullif( rootLogId, lg.log_id)
        , case ct.context_type_short_name
            when pkg_SchedulerMain.Batch_CtxTpSName then
              case when lg.open_context_flag != 0 then
                Bstart_MessageTypeCode
              else
                Bfinish_MessageTypeCode
              end
            when pkg_SchedulerMain.Job_CtxTpSName then
              case when lg.open_context_flag != 0 then
                Jstart_MessageTypeCode
              else
                Jfinish_MessageTypeCode
              end
            else
              case lg.level_code
                when pkg_Logging.Fatal_LevelCode then
                  Error_MessageTypeCode
                when pkg_Logging.Error_LevelCode then
                  Error_MessageTypeCode
                when pkg_Logging.Warn_LevelCode then
                  Warning_MessageTypeCode
                when pkg_Logging.Info_LevelCode then
                  Info_MessageTypeCode
                else
                  Debug_MessageTypeCode
              end
          end
        , coalesce( lg.context_value_id, lg.message_value)
        , lg.message_text
        , 1 + ( lg.context_level - ccl.open_context_level)
          + case when lg.open_context_flag in ( 1, -1) then 0 else 1 end
        , lg.date_ins
        , lg.operator_id
      )
      as log_row
    from
      v_lg_context_change_log ccl
      inner join lg_log lg
        on lg.sessionid = ccl.sessionid
          and lg.log_id >= ccl.open_log_id
          and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
      left join lg_context_type ct
        on ct.context_type_id = lg.context_type_id
    where
      ccl.log_id = rootLogId
    order by
      lg.log_id
  ;

  cursor curOldLog( rootLogId integer) is
    select
      sch_log_t(
        lg.log_id
        , lg.parent_log_id
        , lg.message_type_code
        , lg.message_value
        , lg.message_text
        , level
        , lg.date_ins
        , lg.operator_id
      )
      as log_row
    from
      sch_log lg
    start with
      lg.log_id = rootLogId
    connect by
      prior lg.log_id = lg.parent_log_id
    order siblings by
      lg.date_ins
      , lg.log_id
  ;

  -- ���� ���� � �������������� ��������� ������ Logging
  isContextLog integer;

begin
  select
    count(*)
  into isContextLog
  from
    lg_log lg
  where
    lg.log_id = rootLogId
    and lg.context_type_id is not null
  ;
  if isContextLog = 1 then
    for rec in curLog( rootLogId) loop
      pipe row( rec.log_row);
    end loop;
  else
    for rec in curOldLog( rootLogId) loop
      pipe row( rec.log_row);
    end loop;
  end if;
  return;
end getLog;



/* group: �������, ������������ � �������� */



/* group: ��������� ������ ���������� ������� */

/* func: getSendNotifyFlag
  ���������� �������� ����� �������������� �������� �����������.
*/
function getSendNotifyFlag
return integer
is
begin
  return gSendNotifyFlag;
end getSendNotifyFlag;

/* proc: setSendNotifyFlag
  ������������� ���� �������� ����������� � ��������� ��������.
*/
procedure setSendNotifyFlag(
  flagValue integer := 1
)
is
begin
  gSendNotifyFlag := flagValue;
end setSendNotifyFlag;



/* group: ���������� ��������� ������� */

/* iproc: setContext
  ������������� �������� ���������� ��������� �������.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  varValue                    - �������� ����������
  isConstant                  - ���������� �������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)
  stringValue                 - �������� � ���� ������ ( ��� ������������)
*/
procedure setContext(
  varName varchar2
  , varValue anydata
  , isConstant integer := null
  , valueIndex pls_integer := null
  , stringValue varchar2 := null
)
is

  -- ����������� ��� ����������
  vName VariableNameT;

  -- ���������� ��� ����������?
  isExist boolean;

  -- ������ ��������
  valIndex pls_integer := coalesce( valueIndex, 1);

  -- ����������
  v VariableT;

-- setContent
begin
  if valIndex < 1 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������������ ������ �������� ����������.'
    );
  end if;
  vName := upper( trim( varName));
  isExist := gVariableCol.exists( vName);
  if isExist then
    v := gVariableCol( vName);
    if v.isConstant then
      raise_application_error(
        pkg_Error.VariableAlreadyExist
        , '���������� "' || vName
          || '" ��� ���������� � �� ����� ���� ��������.'
      );
    end if;
  else
    v.valueCol := ValueColT( null);
    v.isConstant := coalesce( isConstant, 0) = 1;
  end if;

  if v.valueCol.count() < valIndex then
    v.valueCol.extend( valIndex - v.valueCol.count());
  end if;
  v.valueCol( valIndex) := varValue;
  gVariableCol( vName) := v;

  -- ��������� ��������� ��������
  if gBatchLevel > 0 or logger.isTraceEnabled() then
    logger.log(
      levelCode         =>
          case when gBatchLevel > 0 then
            lg_logger_t.getInfoLevelCode()
          else
            lg_logger_t.getTraceLevelCode()
          end
      , messageText     =>
          varName
          || case when valIndex > 1 then
              '[' || valIndex || ']'
            end
          || ' := ' || stringValue
          || case
              when isConstant = 1 then ' (���������)'
              when isExist then ' (��������)'
              else ' (�������)'
            end
    );
  end if;
end setContext;

/* proc: setContext( ANYDATA)
  ������������� �������� ���������� ��������� ������� ������������� ����.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  varValue                    - �������� ����������
  isConstant                  - ���������� �������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)
*/
procedure setContext(
  varName varchar2
  , varValue anydata
  , isConstant integer := null
  , valueIndex pls_integer := null
)
is
begin
  setContext(
    varName             => varName
    , varValue          => varValue
    , isConstant        => isConstant
    , valueIndex        => valueIndex
    , stringValue       => '<anydata>'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� �������� ���������� ������������� ���� ('
        || ' varName="' || varName || '"'
        || ', isConstant=' || isConstant
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end setContext;

/* proc: setContext( DATE)
  ������������� �������� ���������� ��������� ������� ���� ����.
  �������.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  varValue                    - �������� ����������
  isConstant                  - ���������� �������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)
*/
procedure setContext(
  varName varchar2
  , varValue date
  , isConstant integer := null
  , valueIndex pls_integer := null
)
is

  -- ������ ��������
  varData anydata;

begin
  varData := anydata.convertDate( varValue);
  setContext(
    varName             => varName
    , varValue          => varData
    , isConstant        => isConstant
    , valueIndex        => valueIndex
    , stringValue       =>
        '{' || to_char( varValue, 'dd.mm.yyyy hh24:mi:ss') || '}'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� �������� ���������� ���� ���� ('
        || ' varName="' || varName || '"'
        || ', isConstant=' || isConstant
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end setContext;

/* proc: setContext( NUMBER)
  ������������� �������� �������� ���������� ��������� �������.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  varValue                    - �������� ����������
  isConstant                  - ���������� �������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)
*/
procedure setContext(
  varName varchar2
  , varValue number
  , isConstant integer := null
  , valueIndex pls_integer := null
)
is

  -- ������ ��������
  varData anydata;

begin
  varData := anydata.convertNumber( varValue);
  setContext(
    varName             => varName
    , varValue          => varData
    , isConstant        => isConstant
    , valueIndex        => valueIndex
    , stringValue       => to_char( varValue)
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ��������� �������� ���������� ('
        || ' varName="' || varName || '"'
        || ', isConstant=' || isConstant
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end setContext;

/* proc: setContext( STRING)
  ������������� ��������� �������� ���������� ��������� �������.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  varValue                    - �������� ����������
  isConstant                  - ���������� �������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)
  encryptedValue              - ������������� �������� ����������
                                ( ���� �������, �� ������������ ��� �����������
                                  ������ �������� ����������)
*/
procedure setContext(
  varName varchar2
  , varValue varchar2
  , isConstant integer := null
  , valueIndex pls_integer := null
  , encryptedValue varchar2 := null
)
is

  -- ������ ��������
  varData anydata;

begin
  varData := anydata.convertVarchar2( varValue);
  setContext(
    varName             => varName
    , varValue          => varData
    , isConstant        => isConstant
    , valueIndex        => valueIndex
    , stringValue       =>
        case when encryptedValue is null then
          '"' || varValue || '"'
        else
          '"' || encryptedValue || '" ( encrypted)'
        end
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ���������� �������� ���������� ('
        || ' varName="' || varName || '"'
        || ', isConstant=' || isConstant
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end setContext;

/* iproc: getContext
  ���������� �������� ���������� ��������� �������.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)

  �������:
  �������� ����������.
*/
function getContext(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return anydata
is

  -- ����������� ��� ����������
  vName VariableNameT;

  -- ���������� ����������?
  isExist boolean;

begin
  vName := upper( trim( varName));
  isExist := gVariableCol.exists( vName);
  if logger.isTraceEnabled() then
    logger.trace(
      varName
      || case when valueIndex > 1 then
          '[' || valueIndex || ']'
        end
      || ' - ��������� �������� ����������'
      || case when not isExist then
          ' ( �� ����������)'
        end
    );
  end if;
  if isExist then
    return
      gVariableCol( vName).valueCol( coalesce( valueIndex, 1))
    ;
  else
    if coalesce( riseException, 0) = 0 then
      return null;
    else
      raise_application_error(
        pkg_Error.VariableNotDefined
        , '���������� "' || varName || '" �� ����������.'
      );
    end if;
  end if;
end getContext;

/* func: getContextAnydata
  ���������� �������� ���������� ��������� ������� ������������� ����.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)

  �������:
  �������� ����������.
*/
function getContextAnydata(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return anydata
is

  -- ������ ��������
  varData anydata;

begin
  varData := getContext(
    varName             => varName
    , riseException     => riseException
    , valueIndex        => valueIndex
  );
  return varData;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� �������� ���������� ������������� ���� ('
        || ' varName="' || varName || '"'
        || ', riseException=' || riseException
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end getContextAnydata;

/* func: getContextDate
  ���������� �������� ���������� ��������� ������� ���� ����.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)

  �������:
  �������� ����������.
*/
function getContextDate(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return date
is

  -- ������ ��������
  varData anydata;

  -- ��������, ������������ �������� ����������� ������
  num number;

  -- �������� ����������
  varValue date;

begin
  varData := getContext(
    varName             => varName
    , riseException     => riseException
    , valueIndex        => valueIndex
  );
  if varData is not null then
    num := varData.getDate( varValue);
  end if;
  return varValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� �������� ���������� ���� ���� ('
        || ' varName="' || varName || '"'
        || ', riseException=' || riseException
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end getContextDate;

/* func: getContextNumber
  ���������� �������� ���������� ��������� ������� ��������� ����.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)

  �������:
  �������� ����������.
*/
function getContextNumber(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return number
is

  -- ������ ��������
  varData anydata;

  -- ��������, ������������ �������� ����������� ������
  num number;

  -- �������� ����������
  varValue number;

begin
  varData := getContext(
    varName             => varName
    , riseException     => riseException
    , valueIndex        => valueIndex
  );
  if varData is not null then
    num := varData.getNumber( varValue);
  end if;
  return varValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� �������� ���������� ��������� ���� ('
        || ' varName="' || varName || '"'
        || ', riseException=' || riseException
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end getContextNumber;

/* func: getContextString
  ���������� �������� ���������� ��������� ������� ���������� ����.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)

  �������:
  �������� ����������.
*/
function getContextString(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return varchar2
is

  -- ������ ��������
  varData anydata;

  -- ��������, ������������ �������� ����������� ������
  num number;

  -- �������� ����������
  varValue varchar2(4000);

begin
  varData := getContext(
    varName             => varName
    , riseException     => riseException
    , valueIndex        => valueIndex
  );
  if varData is not null then
    num := varData.getVarchar2( varValue);
  end if;
  return varValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� �������� ���������� ���������� ���� ('
        || ' varName="' || varName || '"'
        || ', riseException=' || riseException
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end getContextString;

/* func: getContextValueCount
  ���������� ����� �������� ��� ���������� ��������� �������.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������:
  ����� �������� ��� 0 ��� ���������� ����������.
*/
function getContextValueCount(
  varName in varchar2
  , riseException integer := null
)
return integer
is

  -- ����������� ��� ����������
  vName VariableNameT;

  -- ����� �������� ����������
  valueCount pls_integer := 0;

begin
  vName := upper( trim( varName));
  if gVariableCol.exists( vName) then
    valueCount := gVariableCol( vName).valueCol.count();
  elsif riseException = 1 then
    raise_application_error(
      pkg_Error.VariableNotDefined
      , '���������� "' || varName || '" �� ����������.'
    );
  end if;
  return valueCount;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ����� �������� ���������� ('
        || ' varName="' || varName || '"'
        || ', riseException=' || riseException
        || ').'
      )
    , true
  );
end getContextValueCount;

/* proc: deleteContext
  ������� ���������� ��������� �������.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))
*/
procedure deleteContext(
  varName in varchar2
  , riseException integer := null
)
is

  -- ����������� ��� ����������
  vName VariableNameT;

begin
  vName := upper( trim( varName));
  if gVariableCol.exists( vName) then
    if gBatchLevel > 0 or logger.isTraceEnabled() then
      logger.log(
        levelCode       =>
            case when gBatchLevel > 0 then
              lg_logger_t.getInfoLevelCode()
            else
              lg_logger_t.getTraceLevelCode()
            end
        , messageText   =>
            varName || ' - ���������� �������.'
      );
    end if;
    gVariableCol.delete( vName);
  elsif riseException = 1 then
    raise_application_error(
      pkg_Error.VariableNotDefined
      , '���������� "' || varName || '" �� ����������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� �������� ���������� ('
        || ' varName="' || varName || '"'
        || ', riseException=' || riseException
        || ').'
      )
    , true
  );
end deleteContext;



/* group: ���������� ��������� ������� */

/* proc: execBatch( ORACLE_JOB)
  ��������� ��������� ����� �������

  ���������:
  oracleJobId          - Id ������� Oracle (��� ����������� batch_id)
  nextDate             - ���� ���������� �������
*/
procedure execBatch(
  oracleJobId number
  , nextDate in out date
)
is
  resultId sch_result.result_id%type;   --��������� ���������� ������

begin
  execBatch( null, oracleJobId, nextDate, resultId);
end execBatch;



/* group: ���������� ������� */

/* func: getContextInteger
  ���������� �������, ������� ������������ <getContextNumber>.
*/
function getContextInteger(
  varName in varchar2
  , riseException integer := 0
)
return number
is
begin
  return
    getContextNumber(
      varName           => varName
      , riseException   => riseException
    )
  ;
end getContextInteger;

/* func: getDebugFlag
  ���������� �������, ������� ������������ isTraceEnabled() ������ (���
  lg_logger_t).
*/
function getDebugFlag
return integer
is
begin
  return
    case when logger.isTraceEnabled() then
      1
    else
      0
    end
  ;
end getDebugFlag;

/* proc: setDebugFlag
  ���������� �������, ������� ������������ setLevel() ������ (���
  lg_logger_t).
*/
procedure setDebugFlag(
  flagValue integer := 1
)
is
begin
  if coalesce( flagValue = 1, true) then
    logger.setLevel( levelCode => lg_logger_t.getTraceLevelCode());
  else
    logger.setLevel( levelCode => null);
  end if;
end setDebugFlag;

/* proc: writeLog
  ���������� �������, ������� ������������ ����� ��������� ������� ����
  ����������� ����� (��� lg_logger_t).
*/
procedure writeLog(
  messageTypeCode varchar2
  , messageText varchar2
  , messageValue number := null
  , operatorId integer := null
)
is
begin
  if operatorId is not null then
    pkg_Operator.setCurrentUserId( operatorId => operatorId);
  end if;
  logger.log(
    levelCode                 =>
        case messageTypeCode
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
    , messageText             => messageText
    , messageValue            => messageValue
  );
end writeLog;

end pkg_Scheduler;
/
