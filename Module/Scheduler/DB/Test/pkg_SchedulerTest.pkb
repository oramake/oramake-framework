create or replace package body pkg_SchedulerTest is
/* package body: pkg_SchedulerTest::body */



/* group: ?????????? */

/* ivar: logger
  ????? ??????.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Scheduler.Module_Name
  , objectName  => 'pkg_SchedulerTest'
);

/* iconst: Max_LoopCounter
  ???????????? ????? ???????? ?????.
*/
Max_LoopCounter constant integer := 10000;

/* ivar: outputFlag
  ????? ? ????? dbms_output.
*/
outputFlag number(1,0) not null :=
  case when
    logger.isInfoEnabled()
  then
    1
  else
    0
  end;



/* group: ??????? */

/* ifunc: getBatchId
  ?????????? Id ????????? ???????.

  ?????????:
  batchShortName              - ??????? ???????????? ????????? ???????
  raiseNotFoundFlag           - ???? ?????????? ??? ?????????? ?????
                                (1 ??????????? (?? ?????????), 0 ??????????
                                null)
*/
function getBatchId(
  batchShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer
is

  batchId integer;

begin
  select
    max( b.batch_id)
  into batchId
  from
    sch_batch b
  where
    b.batch_short_name = batchShortName
  ;
  if batchId is null and coalesce( raiseNotFoundFlag, 1) != 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '???????? ??????? ?? ???????.'
    );
  end if;
  return batchId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '?????? ??? ????????? Id ????? ('
        || 'batchShortName="' || batchShortName || '"'
        || ').'
      )
    , true
  );
end getBatchId;

/* iproc: checkLog
  ????????? ??? ???????? ??? ???????? ????????.

  ?????????:
  batchShortName              - ??????? ???????????? ????????? ???????
  batchOperationLabel         - ????? ????????
  expectedMessageMask         - ????? ?????????, ??????? ?????? ???? ? ????
  failMessageText             - ????????? ? ?????????? ?????????? ?????
                                (????? ???????????? ?????? $(waitSecond)
                                ? $(sessionId))
  expectedExistsFlag          - ???? ??????? ????????? ??? ????????? ??????????
                                ????????
                                (1 ???? ?????? ???? (?? ?????????), 0 ????
                                ?????? ?????????????)
  waitSecond                  - ????? ???????? ????????? ?????????
                                (?? ????????? ??? ????????)
*/
procedure checkLog(
  batchShortName varchar2
  , batchOperationLabel varchar2
  , expectedMessageMask varchar2
  , failMessageText varchar2
  , expectedExistsFlag integer := null
  , waitSecond number := null
)
is

  endTime timestamp with time zone :=
    systimestamp + numtodsinterval( waitSecond, 'SECOND')
  ;

  batchId integer;

  existsFlag integer;
  sessionId integer;

-- checkLog
begin
  batchId := getBatchId( batchShortName);
  loop
    select
      count(*)
      , max( lg.sessionid) as sessionid
    into existsFlag, sessionId
    from
      v_lg_context_change_log ccl
      inner join lg_log lg
        on lg.sessionid = ccl.sessionid
          and lg.log_id >= ccl.open_log_id
          and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
    where
      ccl.log_id =
        (
        select
          max( bo.start_log_id)
        from
          v_sch_batch_operation bo
        where
          bo.batch_operation_label = batchOperationLabel
          and bo.batch_id = batchId
        )
      and lg.message_text like expectedMessageMask escape '\'
      and rownum <= 1
    ;
    exit when existsFlag = 1 or coalesce( systimestamp >= endTime, true);
    dbms_lock.sleep(1);
  end loop;
  if existsFlag != coalesce( expectedExistsFlag, 1) then
    pkg_TestUtility.failTest(
      replace(
      replace(
        failMessageText
        , '$(sessionId)', sessionId)
        , '$(waitSecond)', waitSecond)
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '?????? ??? ???????? ???? ???????? ('
        || 'batchShortName="' || batchShortName || '"'
        || ', batchOperationLabel="' || batchOperationLabel || '"'
        || ', expectedMessageMask="' || expectedMessageMask || '"'
        || ', expectedExistsFlag=' || expectedExistsFlag
        || ', failMessageText="' || failMessageText || '"'
        || ').'
      )
    , true
  );
end checkLog;

/* iproc: checkBatchSession
  ????????? ???????/?????????? ?????? ? ?????.

  ?????????:
  batchShortName              - ??????? ???????????? ????????? ???????
  existsFlag                  - ???? ??????? ??? ?????????? ??????
                                (1 ???? (?? ?????????), 0 ???)
  waitSecond                  - ???????????? ????? ???????? ? ????????
                                (?? ????????? ??? ????????)
*/
procedure checkBatchSession(
  batchShortName varchar2
  , existsFlag integer := null
  , waitSecond number := null
)
is

  endTime timestamp with time zone :=
    systimestamp + numtodsinterval( waitSecond, 'SECOND')
  ;

  rec v_sch_batch%rowtype;

-- checkBatchSession
begin
  loop
    select
      b.*
    into rec
    from
      v_sch_batch b
    where
      b.batch_short_name = batchShortName
    ;
    exit when
      coalesce( existsFlag, 1)
      = case when rec.sid is not null then 1 else 0 end
    ;
    if coalesce( systimestamp >= endTime, true) then
      raise_application_error(
        pkg_Error.ProcessError
        , case existsFlag
            when 0 then
              '???????? ??????? ??????????? ('
              || 'sid=' || rec.sid
              || ', serial#=' || rec.serial#
              || ').'
            else
              '?? ??????? ?????? ????????? ???????.'
          end
      );
    end if;
    dbms_lock.sleep(1);
  end loop;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '?????? ??? ???????? ?????? ????? ('
        || 'batchShortName="' || batchShortName || '"'
        || ', existsFlag=' || existsFlag
        || ', waitSecond=' || waitSecond
        || ').'
      )
    , true
  );
end checkBatchSession;

/* proc: killBatchSession
  ????????? ?????????? ?????? ?????.

  ?????????:
  batchShortName              - ??????? ???????????? ????????? ???????
  waitSecond                  - ???????????? ????? ???????? ?????????? ??????
                                ? ????????
                                (?? ????????? ??? ????????)
*/
procedure killBatchSession(
  batchShortName varchar2
  , waitSecond number := null
)
is

  endTime timestamp with time zone :=
    systimestamp + numtodsinterval( waitSecond, 'SECOND')
  ;

  rec v_sch_batch%rowtype;
  existsFlag integer;
  killError varchar2(4000);

-- killBatchSession
begin
  select
    b.*
  into rec
  from
    v_sch_batch b
  where
    b.batch_short_name = batchShortName
  ;
  if rec.sid is null then
    raise_application_error(
      pkg_Error.ProcessError
      , '???????? ??????? ?? ??????????? (??? ??????).'
    );
  end if;
  begin
    execute immediate
      'alter system kill session '''
        || rec.sid || ',' || rec.serial#
        || ''' immediate'
    ;
  exception when others then
    killError := logger.getErrorStack();
  end;
  logger.info(
    'Kill batch session ' || rec.sid || ',' || rec.serial# || ' ('
    || 'batch_short_name="' || batchShortName || '"'
    || ', batch_id=' || rec.batch_id
    || ')'
    || case when killError is not null then
        ' with errors:'
        || chr(10) || killError
      end
  );
  loop
    select
      count(*)
    into existsFlag
    from
      v$session ss
    where
      ss.sid = rec.sid
      and ss.serial# = rec.serial#
    ;
    exit when existsFlag = 0;
    if coalesce( systimestamp >= endTime, true) then
      raise_application_error(
        pkg_Error.ProcessError
        , '?????? ????? ?????????? ???????? ('
          || 'sid=' || rec.sid
          || ', serial#=' || rec.serial#
          || ').'
          || case when killError is not null then
              chr(10) || '??? ?????????? ?????? ???? ??????:'
              || chr(10) || killError
            end
      );
    end if;
    dbms_lock.sleep(1);
  end loop;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '?????? ??? ?????????? ?????? ????? ('
        || 'batchShortName="' || batchShortName || '"'
        || ', waitSecond=' || waitSecond
        || ').'
      )
    , true
  );
end killBatchSession;

/* iproc: execOperation
  ????????? ???????? ??? ???????? ????????.

  ?????????:
  batchShortName              - ??????? ???????????? ????????? ???????
  operationCode               - ??? ????????
  waitSecond                  - ???????????? ????? ???????? ? ????????
                                (?? ????????? 60 ??????)
  nextDate                    - ???? ?????????? ??????? ??? SET_NEXT_DATE
                                (?? ????????? ??????????)
  ignoreMarkedForKillError    - ???????????? ??????
                                "ORA-00031: session marked for kill"
                                ??? ?????????? ????????? ???????
                                (1 ??, 0 ??? (?? ?????????))
*/
procedure execOperation(
  batchShortName varchar2
  , operationCode varchar2
  , waitSecond number := 60
  , nextDate timestamp with time zone := null
  , ignoreMarkedForKillError integer := null
)
is

  operatorId integer := pkg_Operator.getCurrentUserId();

  pkgLogger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => pkg_Scheduler.Module_Name
    , objectName  => 'pkg_Scheduler'
  );

  oldLevel varchar2(10) := pkgLogger.getLevel();

-- execOperation
begin
  case operationCode
    when 'ABORT' then
      -- ????????? ????? ?????? ??? ??????????
      if ignoreMarkedForKillError = 1
          and lg_logger_t.getLogger( pkg_Scheduler.Module_Name)
              .getEffectiveLevel()
            = lg_logger_t.getWarnLevelCode()
          then
        pkgLogger.setLevel( lg_logger_t.getFatalLevelCode());
      end if;
      pkg_Scheduler.abortBatch(
        batchId       => getBatchId( batchShortName)
        , operatorId  => operatorId
      );
      commit;
    when 'ACTIVATE' then
      pkg_Scheduler.activateBatch(
        batchId       => getBatchId( batchShortName)
        , operatorId  => operatorId
      );
      commit;
    when 'DEACTIVATE' then
      pkg_Scheduler.deactivateBatch(
        batchId       => getBatchId( batchShortName)
        , operatorId  => operatorId
      );
      commit;
    when 'SET_NEXT_DATE' then
      pkg_Scheduler.setNextDate(
        batchId       => getBatchId( batchShortName)
        , operatorId  => operatorId
        , nextDate    => coalesce( nextDate, systimestamp)
      );
      commit;
    when 'START' then
      checkBatchSession( batchShortName, existsFlag => 0);
      execOperation( batchShortName, 'ACTIVATE');
      execOperation( batchShortName, 'SET_NEXT_DATE');
      checkBatchSession(
        batchShortName, existsFlag => 1, waitSecond => waitSecond
      );
    else
      raise_application_error(
        pkg_Error.IllegalArgument
        , '??????????? ??? ????????.'
      );
  end case;
exception when others then
  pkgLogger.setLevel( oldLevel);
  if ignoreMarkedForKillError = 1
        and operationCode = 'ABORT'
        and logger.getErrorStack( isStackPreserved => 1) like '%ORA-00031:%'
      then
    logger.trace(
      'Ignored exception during abortBatch:'
      || logger.getErrorStack()
    );
    rollback;
  else
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ?????????? ???????? ('
          || 'batchShortName="' || batchShortName || '"'
          || ', operationCode="' || operationCode || '"'
          || ').'
        )
      , true
    );
  end if;
end execOperation;

/* proc: testBatchOperation
  ????????? ???????????? ?????????? ???????? ??? ????????? ?????????.

  ?????????:
  testCaseNumber              - ????? ???????????? ????????? ??????
                                (?? ????????? ??? ???????????)
  saveDataFlag                - ???? ?????????? ???????? ??????
                                (1 ??, 0 ??? (?? ?????????))
*/
procedure testBatchOperation(
  testCaseNumber integer := null
  , saveDataFlag integer := null
)
is

  -- ?????????? ????? ?????????? ????????? ??????
  checkCaseNumber integer := 0;

  -- ???????? ???????????? ????????? ??????
  cinfo varchar2(200);

  -- ???????? ????
  batchSName sch_batch.batch_short_name%type :=
    'TestBatchOperation'
  ;

  -- Id ????????? ?????
  testBatchId integer;

  -- ????????? ????????? ?????
  bopt sch_batch_option_t;

  -- ??????? ???? ?????? (?? ????????? ? moveSessionTimeZone)
  oldSessionTimeZone varchar2(100);



  /*
    ?????????? ??????, ???? ???????? ?????? ?? ?????? ???????????, ?????
    ???????? ?????????? ? ?????? ????????.
  */
  function skipCheckCase(
    caseDescription varchar2
    , nextCaseUsedCount integer := null
  )
  return boolean
  is
  begin
    checkCaseNumber := checkCaseNumber + 1;
    if pkg_TestUtility.isTestFailed()
          or testCaseNumber is not null
            and testCaseNumber
              not between checkCaseNumber
                and checkCaseNumber + coalesce( nextCaseUsedCount, 0)
        then
      return true;
    end if;
    cinfo :=
      'CASE ' || to_char( checkCaseNumber)
      || ' "' || caseDescription || '": '
    ;
    logger.info( '*** ' || cinfo);
    return false;
  end skipCheckCase;



  /*
    ??????? ???????? ??????.
  */
  procedure clearTestData
  is

    cursor batchCur is
      select
        b.*
      from
        v_sch_batch b
      where
        b.batch_short_name in (
          batchSName
        )
      order by
        b.batch_short_name
    ;

    operatorId integer := pkg_Operator.getCurrentUserId();

  begin
    for rec in batchCur loop
      if rec.sid is not null then
        pkg_Scheduler.abortBatch(
          batchId       => rec.batch_id
          , operatorId  => operatorId
        );
        commit;
      end if;
      if rec.oracle_job_id is not null then
        pkg_Scheduler.deactivateBatch(
          batchId       => rec.batch_id
          , operatorId  => operatorId
        );
        commit;
      end if;
      pkg_SchedulerLoad.deleteBatch(
        batchShortName => batchSName
      );
      commit;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ??????? ???????? ??????.'
        )
      , true
    );
  end clearTestData;



  /*
    ?????????????? ?????? ??? ?????.
  */
  procedure prepareTestData
  is



    /*
      ????????? ????.
    */
    procedure loadBatch(
      batchShortName varchar2 := batchSName
      , moduleName varchar2 := pkg_ModuleInfoTest.getTestModuleName( 'Module1')
      , jobShortName varchar2 := 'process'
    )
    is
    begin
      pkg_SchedulerLoad.loadJob(
        moduleName                => moduleName
        , jobShortName            => jobShortName
        , jobName                 => '???????? job'
        , description             => '???????? job'
        , batchShortName          => batchShortName
        , jobWhat                 =>
'declare
  endDate date :=
    sysdate + pkg_Scheduler.getContextNumber( ''WorktimeSecond'') / 86400
  ;
begin
  loop
    exit when coalesce( sysdate >= endDate, true);
    dbms_lock.sleep( 1);
  end loop;
end;'
      );
      pkg_SchedulerLoad.loadBatch(
        moduleName            => moduleName
        , batchShortName      => batchShortName
        , updateScheduleFlag  => 1
        , updateOptionValue   => 1
        , xmlText             =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || batchShortName || '">
  <name>???????? ???? ?????? Scheduler (?????? pkg_SchedulerTest.testBatchOperation)</name>
  <batch_config>
    <retry_count>5</retry_count>
    <retry_interval>30</retry_interval>
    <schedule>
      <name>every day at 04:18</name>
      <interval type="hh24">
        <value>04</value>
      </interval>
      <interval type="mi">
        <value>18</value>
      </interval>
    </schedule>
    <option short_name="RunLabel" type="string" name="????? ???????"/>
    <option short_name="WorktimeSecond" type="number" name="????? ??????"/>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
  <content id="2" job="process">
    <condition id="1">true</condition>
  </content>
  <content id="3" job="commit" module="Scheduler">
    <condition id="2">true</condition>
  </content>
  <content id="4" job="retry_batch" module="Scheduler">
    <condition id="3">error</condition>
    <condition id="3">skip</condition>
  </content>
</batch>'
      );
      commit;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '?????? ??? ???????? ????? ('
            || 'batchShortName="' || batchShortName || '"'
            || ').'
          )
        , true
      );
    end loadBatch;



  -- prepareTestData
  begin
    clearTestData();
    loadBatch();
    select
      t.batch_id
    into testBatchId
    from
      sch_batch t
    where
      t.batch_short_name = batchSName
    ;
    bopt := sch_batch_option_t( batchSName);
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ?????????? ?????? ??? ?????.'
        )
      , true
    );
  end prepareTestData;



  /*
    ???????? ??????? ???? ??????, ????? ?? ????????? ?? ???????? ?????
    ??????? (systimestamp).
  */
  procedure moveSessionTimeZone
  is

    tzh integer;
    newTimeZone varchar2(100);

  begin
    oldSessionTimeZone := to_char( current_timestamp, 'tzh:tzm');
    tzh := extract( timezone_hour from current_timestamp);
    tzh := mod( tzh + 4, 24);
    newTimeZone := to_char( tzh, 's09') || ':00';
    execute immediate
      'alter session set time_zone = ''' || newTimeZone || ''''
    ;
    logger.trace(
      'moveSessionTimeZone: set session time zone: '
      || newTimeZone || ' (old: ' || oldSessionTimeZone || ')'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ????????? ???????? ????? ??????.'
        )
      , true
    );
  end moveSessionTimeZone;



  /*
    ??????????????? ???????? ???????? ???????? ????? ??????.
  */
  procedure restoreSessionTimeZone
  is

    tzh integer;
    newTimeZone varchar2(100);

  begin
    if oldSessionTimeZone is not null then
      execute immediate
        'alter session set time_zone = ''' || oldSessionTimeZone || ''''
      ;
      logger.trace(
        'restoreSessionTimeZone: set session time zone: ' || oldSessionTimeZone
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ?????????????? ???????? ????? ??????.'
        )
      , true
    );
  end restoreSessionTimeZone;



  /*
    ???????? ??????? ???? ?????????? ???????.
  */
  procedure checkCalcNextDate
  is

    btr v_sch_batch%rowtype;


    /*
      ????????? ???????? ??????.
    */
    procedure checkCase(
      caseDesc varchar2
      , startDate timestamp with time zone
      , nextDate timestamp with time zone
    )
    is

      caseDescription varchar2(100) :=
        '???????? calcNextDate: ' || caseDesc
      ;

      -- ???????? ????????? ??????
      cinfo varchar2(200);

      retVal timestamp with time zone;

    begin
      if skipCheckCase( '???????? calcNextDate: ' || caseDesc) then
        return;
      end if;
      cinfo :=
        'CASE ' || to_char( checkCaseNumber)
        || ' "' || caseDescription || '": '
      ;
      begin
        retVal := pkg_Scheduler.calcNextDate(
          batchId       => testBatchId
          , startDate   => startDate
        );
      exception when others then
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || '?????????? ??????????? ? ???????:'
            || chr(10) || logger.getErrorStack()
        );
      end;
      if not pkg_TestUtility.isTestFailed() then
        pkg_TestUtility.compareChar(
          actualString        =>
              to_char( retVal, 'yyyy-mm-dd hh24:mi:ss.ff tzh:tzm')
          , expectedString    =>
              to_char( nextDate, 'yyyy-mm-dd hh24:mi:ss.ff tzh:tzm')
          , failMessageText   =>
              cinfo || '??????????? ????????? ?????????? ???????'
        );
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '?????? ??? ???????? calcNextDate ('
            || ' caseDesc="' || caseDesc || '"'
            || ').'
          )
        , true
      );
    end checkCase;



  -- checkCalcNextDate
  begin
    checkCase(
      'time zone 01:00'
      , startDate => TIMESTAMP '2018-03-05 18:42:03.08543 +01:00'
      , nextDate  => TIMESTAMP '2018-03-06 04:18:00.00000 +01:00'
    );
    checkCase(
      'time zone 02:00'
      , startDate => TIMESTAMP '2019-08-08 19:52:03.08543 +02:00'
      , nextDate  => TIMESTAMP '2019-08-09 04:18:00.00000 +02:00'
    );
    checkCase(
      'startDate is NULL'
      , startDate => null
      , nextDate  =>
          to_timestamp_tz(
            to_char( sysdate + 1, 'yyyy-mm-dd') || ' 04:18:00 '
              || to_char( systimestamp, 'tzh:tzm')
            , 'yyyy-mm-dd hh24:mi:ss tzh:tzm'
          )
    );
  exception when others then
    rollback;
    pkg_TestUtility.failTest(
      cinfo || '?????? ??? ???????? ????????? ??????:'
      || chr(10) || logger.getErrorStack()
    );
  end checkCalcNextDate;



  /*
    ???????? ?????????? ?????????? ?????.
  */
  procedure checkAbortBatch
  is

    restartLabel varchar2(100) :=
      'RestartAfterAbort:' || dbms_utility.get_time()
    ;

    btr v_sch_batch%rowtype;

  begin
    if skipCheckCase( '???????? ?????????? ?????????? ?????') then
      return;
    end if;
    bopt.setNumber( 'WorktimeSecond', 120);
    commit;
    execOperation( batchSName, 'START');
    bopt.setNumber( 'WorktimeSecond', 0);
    bopt.setString( 'RunLabel', restartLabel);
    commit;
    execOperation( batchSName, 'ABORT', ignoreMarkedForKillError => 1);
    checkBatchSession( batchSName, existsFlag => 0, waitSecond => 120);
    checkLog(
      batchShortName        => batchSName
      , batchOperationLabel => pkg_SchedulerMain.Exec_BatchMsgLabel
      , expectedMessageMask => '%RunLabel := "' || restartLabel || '"%'
      , expectedExistsFlag  => 0
      , waitSecond          => 90
      , failMessageText     =>
          cinfo || '??????????? ?????? ????? ????? ??????????'
          || ' (sessionid=$(sessionId))'
    );
    select
      bt.*
    into btr
    from
      v_sch_batch bt
    where
      bt.batch_short_name = batchSName
    ;
    pkg_TestUtility.compareChar(
      actualString      =>
          to_char( btr.next_date, 'dd.mm.yyyy hh24:mi:ss tzh:tzm')
      , expectedString  =>
          to_char( trunc(sysdate + 1), 'dd.mm.yyyy')
          || ' 04:18:00'
          || to_char( systimestamp, ' tzh:tzm')
      , failMessageText =>
          cinfo || '???? ?????????? ??????? ??????????? ?? ?? ??????????'
    );
  exception when others then
    rollback;
    pkg_TestUtility.failTest(
      cinfo || '?????? ??? ???????? ????????? ??????:'
      || chr(10) || logger.getErrorStack()
    );
  end checkAbortBatch;



  /*
    ???????? ???????? ????? ????? kill session.
  */
  procedure checkRestartAfterKill
  is

    restartLabel varchar2(100) :=
      'RestartAfterKill:' || dbms_utility.get_time()
    ;

    btr v_sch_batch%rowtype;

  begin
    if skipCheckCase( '?????????? ????? ????? ?????????? (kill) ??????') then
      return;
    end if;
    bopt.setNumber( 'WorktimeSecond', 120);
    commit;
    execOperation( batchSName, 'START');
    bopt.setNumber( 'WorktimeSecond', 0);
    bopt.setString( 'RunLabel', restartLabel);
    commit;
    killBatchSession( batchSName, waitSecond => 60);
    checkLog(
      batchShortName        => batchSName
      , batchOperationLabel => pkg_SchedulerMain.Exec_BatchMsgLabel
      , expectedMessageMask => '%RunLabel := "' || restartLabel || '"%'
      , waitSecond          => 120
      , failMessageText     =>
          cinfo || '???? ?? ??? ???????????'
          || ' (????? ????????: $(waitSecond) ??????)'
    );
    checkBatchSession( batchSName, existsFlag => 0, waitSecond => 10);
    select
      bt.*
    into btr
    from
      v_sch_batch bt
    where
      bt.batch_short_name = batchSName
    ;
    pkg_TestUtility.compareChar(
      actualString      =>
          to_char( btr.next_date, 'dd.mm.yyyy hh24:mi:ss tzh:tzm')
      , expectedString  =>
          to_char( trunc(sysdate + 1), 'dd.mm.yyyy')
          || ' 04:18:00'
          || to_char( systimestamp, ' tzh:tzm')
      , failMessageText =>
          cinfo || '???? ?????????? ??????? ??????????? ?? ?? ??????????'
    );
    execOperation( batchSName, 'DEACTIVATE');
  exception when others then
    rollback;
    pkg_TestUtility.failTest(
      cinfo || '?????? ??? ???????? ????????? ??????:'
      || chr(10) || logger.getErrorStack()
    );
  end checkRestartAfterKill;



-- testBatchOperation
begin
  moveSessionTimeZone();
  prepareTestData();
  pkg_TestUtility.beginTest( 'batch operation');
  checkCalcNextDate();
  checkAbortBatch();
  checkRestartAfterKill();
  if coalesce( saveDataFlag, 0) != 1 then
    clearTestData();
  end if;
  pkg_TestUtility.endTest();
  restoreSessionTimeZone();
exception when others then
  restoreSessionTimeZone();
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '?????? ??? ???????????? ?????????? ???????? ??? ??????? ('
        || ' testCaseNumber=' || testCaseNumber
        || ', saveDataFlag=' || saveDataFlag
        || ').'
      )
    , true
  );
end testBatchOperation;

/* proc: setOutputFlag
  ????????? ???? ?????? ? ????? dbms_output.

  ?????????:
  outputFlag                  - ???? ?????? ? ????? dbms_output.
*/
procedure setOutputFlag(
  outputFlag number
)
is
-- setOutputFlag
begin
  pkg_SchedulerTest.outputFlag := setOutputFlag.outputFlag;
end setOutputFlag;

/* iproc: outputMessage
  ??????? ????????? ??? ??????????.
*/
procedure outputMessage(
  messageText varchar2
)
is
begin
  if outputFlag = 1 then
    pkg_Common.outputMessage(
      messageText
    );
  else
    logger.trace( messageText);
  end if;
end outputMessage;

/* proc: showLastRunLog
  ??????? ??? ?????????? ?????????? ????? ?? ?????.

  ?????????:
  batchId                     - id ?????
*/
procedure showLastRunLog(
  batchId integer
)
is

  cursor parentLogCur is
    select
      a.start_log_id
      , lg.date_ins
      , lg.operator_id
    from
      (
      select
        max( bo.start_log_id) as start_log_id
      from
        v_sch_batch_operation bo
      where
        bo.batch_id = batchId
        and bo.batch_operation_label = pkg_SchedulerMain.Exec_BatchMsgLabel
      ) a
      inner join lg_log lg
        on lg.log_id = a.start_log_id
  ;

  parentLog parentLogCur%rowtype;

  cursor logCur( startLogId integer) is
    select
      ' ' || to_char( lg.date_ins, 'hh24:mi:ss') || ' '
      || decode( lg.message_level
          , 1, ''
          , lpad( '  ', (lg.message_level - 1) * 2, ' ')
        )
        -- ????????? ?????? ??-?? ?????? ?????? ?????? 4000 ????????
        || substr( lg.message_text, 1, 3900 - (lg.message_level - 1) * 2)
        as message_line
    from
      (
      select
        lg.*
        , 1 + ( lg.context_level - ccl.open_context_level)
          + case when lg.open_context_flag in ( 1, -1) then 0 else 1 end
          as message_level
      from
        v_lg_context_change_log ccl
        inner join lg_log lg
          on lg.sessionid = ccl.sessionid
            and lg.log_id >= ccl.open_log_id
            and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
      where
        ccl.log_id = startLogId
      ) lg
    order by
      lg.log_id
  ;

  /*
    ????????? ???????????? ?????.
  */
  procedure getParentLog
  is
  begin
    outputMessage( '*');
    open
      parentLogCur
    ;
    fetch
      parentLogCur
    into
      parentLog
    ;
    close parentLogCur;
    outputMessage(
      'root log_id: ' || to_char( parentLog.start_log_id)
      || ', dateBegin={' || to_char( parentLog.date_ins, 'dd.mm.yyyy hh24:mi:ss') || '}'
      || ', operator_id=' || to_char( parentLog.operator_id)
    );
  end getParentLog;

begin
  getParentLog();
  outputMessage( '>');
  for logMessage in logCur( parentLog.start_log_id) loop
    outputMessage(
      logMessage.message_line
    );
  end loop;
  outputMessage( '>');
end showLastRunLog;

/* func: isOfMask
  ???????? ???????????? ?????? ??????.

  ?????????:
  testString                  - ??????
  maskList                    - ?????? ?????
*/
function isOfMask(
  testString varchar2
  , maskList varchar2
)
return integer
is
  currentMaskList varchar2(1000);
  safeCycle integer := 0;
begin
  currentMaskList := upper( maskList || ',' );
  loop
    exit when
      currentMaskList is null
      or
        upper( testString )
        like substr( currentMaskList , 1, instr( currentMaskList, ',' ) - 1 )
        escape '\'
    ;
    currentMaskList := substr( currentMaskList, instr( currentMaskList, ',' ) + 1 );
    safeCycle := safeCycle + 1;
    if SafeCycle > 100 then
      raise_application_error(
        pkg_Error.ProcessError,
        '????????? ???????????? ? ??????? isOfMask'
      );
    end if;
  end loop;
  if
    upper( testString)
      like substr( currentMaskList , 1, instr( currentMaskList, ',' ) - 1)
    escape '\'
  then
    return 1;
  else
    return 0;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '?????? ???????? ???????????? ?????? ?????? ('
        || ' testString="' || testString || '"'
        || ', maskList="' || maskList || '"'
        || ')'
      )
    , true
  );
end isOfMask;

/* iproc: execBatchOperation
  ????????? ???????? ? ???????.

  waitBatchCount              - ?????????? ??????, ??????? ?? ????????? ??????????
  retryBatchCount            - ?????????? ??????, ??????? ????????? ??????????
                                ? ??????? ????????? ???????
  batchShortNameList          - ?????? ????? ?????? ????? ","
  operationCode               - ??? ???????? ( ??. <pkg_SchedulerTest::?????????);
  operationStartDate          - ???? ?????? ?????????? ????????
*/
procedure execBatchOperation(
  waitBatchCount out integer
  , retryBatchCount out integer
  , batchShortNameList varchar2
  , operationCode varchar2
  , operationStartDate timestamp with time zone
)
is
  pragma autonomous_transaction;

  operatorId integer := pkg_Operator.getCurrentUserId();

  nextDate timestamp with time zone;

  -- ????? ?????????? ??????
  batchCount integer;

  -- ?????????? ???????????? ??????
  processedCount integer := 0;

  -- ?????? ??? ????????? ?????? ??????
  cursor batchCur is
    select
      batch_short_name
      , batch_id
      , activated_flag
      -- ????? ????????? ? ????????????? last_start_date, ????? ??? ????? ????
      -- timestamp with time zone
      , coalesce( this_date, last_date) as last_start_date
      , sid
      , batch_result_id
    from
      v_sch_batch
    where
      pkg_SchedulerTest.isOfMask( batch_short_name, batchShortNameList) = 1
  ;

begin
  if operationCode in(
    WaitRun_OperCode
    , WaitSession_OperCode
    , WaitAbsentSession_OperCode
  )
  then
    waitBatchCount := 0;
    retryBatchCount := 0;
  else
    outputMessage( '*');
    outputMessage( '*');
  end if;
  batchCount := 0;
  for batch in batchCur loop
    if operationCode in (
      Activate_OperCode, Deactivate_OperCode, ShowLog_OperCode
    )
    then
      outputMessage(
        rpad(
          case
            operationCode
          when
            Activate_OperCode
          then
            'Activate batch: '
          when
            Deactivate_OperCode
          then
            'Deactivate batch: '
          when
            ShowLog_OperCode
          then
            'Show log: '
          end
          , 20
        )
        ||  rpad( batch.batch_short_name, 30)
        || ' ( batch_id =' || lpad( batch.batch_id, 5)
        || ')'
      );
    end if;
    case
      operationCode
    when
      Activate_OperCode
    then
      if batch.activated_flag = 0 then
        pkg_Scheduler.activateBatch(
          batchId => batch.batch_id
          , operatorId => operatorId
        );
        processedCount := processedCount + 1;
      end if;
    when
      Deactivate_OperCode
    then
      if batch.activated_flag = 1 then
        pkg_Scheduler.deactivateBatch(
          batchId => batch.batch_id
          , operatorId => operatorId
        );
        processedCount := processedCount + 1;
      end if;
    when
      Run_OperCode
    then
      nextDate := systimestamp;
      pkg_Scheduler.setNextDate(
        batchId => batch.batch_id
        , operatorId => operatorId
        , nextDate => nextDate
      );
      outputMessage(
        rpad( batch.batch_short_name, 30)
        || ' ( batch_id =' || lpad( batch.batch_id, 3)
        || ')   - set date '
        || to_char( nextDate, 'dd.mm.yyyy hh24:mi:ss.ff3 tzh:tzm')
      );
    when
      ShowLog_OperCode
    then
      showLastRunLog(
        batchId => batch.batch_id
      );
    when
      WaitRun_OperCode
    then
      logger.trace(
        'batch: ' || batch.batch_short_name
        || ': last_start_date={' || to_char( batch.last_start_date, 'dd.mm.yyyy hh24:mi:ss.ff3 tzh:tzm') || '}'
        || ', operationStartDate={' || to_char( operationStartDate, 'dd.mm.yyyy hh24:mi:ss.ff3 tzh:tzm') || '}'
        || ', sid=' || to_char( batch.sid)
      );
      if
        batch.last_start_date < operationStartDate
        or batch.last_start_date is null
        or batch.sid is not null
      then
        waitBatchCount := waitBatchCount + 1;
      elsif  batch.batch_result_id = pkg_Scheduler.RetryAttempt_ResultId then
        retryBatchCount := retryBatchCount + 1;
      end if;
      logger.trace(
        'waitBatchCount=' || to_char( waitBatchCount)
      );
    when
      WaitSession_OperCode
    then
      if
        batch.sid is null
        and batch.last_start_date < operationStartDate
      then
        waitBatchCount := waitBatchCount + 1;
      end if;
    when
      WaitAbsentSession_OperCode
    then
      if
        batch.sid is not null
      then
        waitBatchCount := waitBatchCount + 1;
      end if;
    end case;
    batchCount := batchCount + 1;
  end loop;
  if batchCount = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'No batches found'
    );
  end if;
  commit;
  if operationCode in (
    Activate_OperCode, Deactivate_OperCode
  ) then
    outputMessage(
      '- done ( processed: ' || to_char( processedCount)
      || ', checked: ' || to_char( batchCount)
      || ')'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '?????? ?????????? ???????? ??? ??????? ('
        || ' operationCode="' || operationCode || '"'
        || ')'
      )
    , true
  );
end execBatchOperation;

/* proc: execBatchOperation
  ????????? ???????? ? ???????.

  batchShortNameList          - ?????? ????? ?????? ????? ","
  operationCode               - ??? ???????? ( ??. <pkg_SchedulerTest::?????????);
*/
procedure execBatchOperation(
  batchShortNameList varchar2
  , operationCode varchar2
)
is
  -- ?????????? ??????, ??? ??????? ?? ??????? ?????????? ??????????
  waitBatchCount integer;
  lastWaitBatchCount integer;
  retryBatchCount integer;

    -- ????? ?????????? ????????
  limitDate timestamp with time zone := systimestamp + INTERVAL '1' MINUTE;
  -- ???? ?????? ????????
  operationStartDate timestamp with time zone := systimestamp;
begin
  if operationCode in
  (
    WaitAbsentSession_OperCode
    , WaitSession_OperCode
  ) then
    loop
      execBatchOperation(
        waitBatchCount => waitBatchCount
        , retryBatchCount => retryBatchCount
        , batchShortNameList => batchShortNameList
        , operationCode => operationCode
        , operationStartDate => operationStartDate
      );
      if lastWaitBatchCount <> waitBatchCount
        or lastWaitBatchCount is null
      then
        lastWaitBatchCount := waitBatchCount;
        outputMessage(
          to_char( sysdate, 'hh24:mi:ss')
          || ': Waiting for batches: left: ' || to_char( lastWaitBatchCount)
        );
      end if;
      exit when
        waitBatchCount = 0 or systimestamp >= limitDate
      ;
      dbms_lock.sleep( 1);
    end loop;
    if waitBatchCount > 0 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Batches not started or not finished: ' || to_char( waitBatchCount)
      );
    end if;
  else
    execBatchOperation(
      waitBatchCount => waitBatchCount
      , retryBatchCount => retryBatchCount
      , batchShortNameList => batchShortNameList
      , operationCode => operationCode
      , operationStartDate => operationStartDate
    );
  end if;
  logger.trace(
    'waitBatchCount=' || to_char( waitBatchCount)
    || ', retryBatchCount=' || to_char( retryBatchCount)
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '?????? ?????????? ???????? ??? ??????? ('
        || ' operationCode="' || operationCode || '"'
        || ')'
      )
    , true
  );
end execBatchOperation;

/* proc: testBatch
  ?????????? ?????, ?????????, ??????? ?????????? ?????? ? ????????????, ?????
  ?????????? ??? ??????????.

  ?????????:
  batchShortNameList          - ?????? ????? ?????? ????? ","
  batchWaitSecond             - ????? ???????? ?????? ????? ? ???????? ( ??
                                ????????? ???????????? ??????????,
                                ??-????????? ??????);
  raiseWhenRetryFlag          - ????????? ?????????? ? ?????? ??????? ??????????
                                ????? "????????? ???????". ??-????????? ????????????.
*/
procedure testBatch(
  batchShortNameList varchar2
  , batchWaitSecond number := null
  , raiseWhenRetryFlag number := null
)
is

  -- ????? ?????????? ????????
  limitDate timestamp with time zone :=
    systimestamp + numtodsinterval( coalesce( batchWaitSecond, 60), 'SECOND')
  ;

  -- ?????????? ??????, ??? ??????? ?? ??????? ?????????? ??????????
  waitBatchCount integer;
  lastWaitBatchCount integer;
  -- ?????????? ??????, ??????? ??????????? ? ??????? "????????? ???????"
  retryBatchCount integer;

  -- ???? / ????? ??????? ??????
  operationStartDate timestamp with time zone;

-- testBatch
begin
  execBatchOperation(
    batchShortNameList => batchShortNameList
    , operationCode => Activate_OperCode
  );
  operationStartDate := systimestamp;
  execBatchOperation(
    batchShortNameList => batchShortNameList
    , operationCode => Run_OperCode
  );
  outputMessage( '*');
  outputMessage( '*');
  loop
    execBatchOperation(
      waitBatchCount => waitBatchCount
      , retryBatchCount => retryBatchCount
      , batchShortNameList => batchShortNameList
      , operationCode => WaitRun_OperCode
      , operationStartDate => operationStartDate
    );
    if lastWaitBatchCount <> waitBatchCount
      or lastWaitBatchCount is null
    then
      lastWaitBatchCount := waitBatchCount;
      outputMessage(
        to_char( sysdate, 'hh24:mi:ss')
        || ': Waiting for batches: left: ' || to_char( lastWaitBatchCount)
      );
    end if;
    exit when
      waitBatchCount = 0 or systimestamp >= limitDate
    ;
    dbms_lock.sleep( 1);
  end loop;
  execBatchOperation(
    batchShortNameList => batchShortNameList
    , operationCode => Deactivate_OperCode
  );
  if waitBatchCount > 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Batches not started or not finished: ' || to_char( waitBatchCount)
    );
  end if;
  execBatchOperation(
    batchShortNameList => batchShortNameList
    , operationCode => ShowLog_OperCode
  );
  if coalesce( raiseWhenRetryFlag, 1) = 1 and
     retryBatchCount > 0
  then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Some batches completed with status "Retry": ' || to_char( retryBatchCount)
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '?????? ???????????? ?????? ('
        || ' batchShortNameList="' || batchShortNameList || '"'
        || ')'
      )
    , true
  );
end testBatch;

/* proc: testLoadBatch
  ???????????? ???????? ?????.

  ?????????:
  jobWhat                     - plsql-??? ??????? ( job)
  batchXmlText                - ?????????? ????????? ??????? ? ???? xml
  testCaseNumber              - ????? ???????????? ????????? ??????
                                ( ?? ????????? ??? ??????????? ???? ?? ???????
                                  ????????? jobWhat ? batchXmlText, ?????
                                  ?????? 1 ???? ( ???????? ??????? ? ?????))
*/
procedure testLoadBatch(
  jobWhat varchar2 := null
  , batchXmlText clob := null
  , testCaseNumber integer := null
)
is

  pragma autonomous_transaction;

  Batch_ShortName constant varchar2(50) := 'TestBatch';
  Batch_ShortName2 constant varchar2(50) := 'TestBatch_2';
  Check_String constant varchar2(50) := 'Hello world!';
  Option_Name constant varchar2(50) := 'Hello';

  Config_RetrialCount1 constant integer := 11;
  Config_RetrialCount2 constant integer := 17;

  -- ?????????? ????? ?????????? ????????? ??????
  checkCaseNumber integer := 0;

  -- ?????? ??? ????????????
  moduleName1 varchar2(100);
  moduleName2 varchar2(100);

  batch sch_batch%rowtype;



  /*
    ?????????? ?????? ??? ?????.
  */
  procedure prepareData
  is

    cursor batchCur is
      select
        t.batch_id
      from
        sch_batch t
      where
        t.batch_short_name in (
          Batch_ShortName
          , Batch_ShortName2
        )
      order by
        t.batch_short_name
    ;

  begin
    moduleName1 := pkg_ModuleInfoTest.getTestModuleName( 'Module1');
    moduleName2 := pkg_ModuleInfoTest.getTestModuleName( 'Module2');
    for rec in batchCur loop
      pkg_SchedulerLoad.deleteBatch(
        batchId => rec.batch_id
      );
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ????????? ?????? ??? ?????.'
        )
      , true
    );
  end prepareData;



  /*
    ????????? ?????? ?????.
  */
  procedure getBatch(
    batchShortName varchar2 := Batch_ShortName
  )
  is
  begin
    select
      *
    into
      batch
    from
      sch_batch
    where
      batch_short_name = batchShortName
    ;
  end getBatch;



  /*
    ????????? ???????? job.
  */
  procedure loadJob(
    cinfo varchar2
    , moduleName varchar2 := moduleName1
    , moduleSvnRoot varchar2 := null
    , moduleInitialSvnPath varchar2 := null
    , jobShortName varchar2
    , jobName varchar2 := null
    , jobWhat varchar2 := null
    , description varchar2 := null
    , publicFlag number := null
    , batchShortName varchar2 := null
    , skipCheckJob number := null
  )
  is

    jobInfo varchar2(200) :=
      ' ( job_short_name="' || jobShortName || '"'
      || ', batch_short_name="' || batchShortName || '"'
      || ')'
    ;

    moduleId integer;

    jbr sch_job%rowtype;

  begin
    pkg_SchedulerLoad.loadJob(
      moduleName                => moduleName
      , moduleSvnRoot           => moduleSvnRoot
      , moduleInitialSvnPath    => moduleInitialSvnPath
      , jobShortName            => jobShortName
      , jobName                 => coalesce( jobName, '???????? job')
      , jobWhat                 => coalesce( jobWhat, 'null;')
      , description             => coalesce( description, '???????? job')
      , publicFlag              => publicFlag
      , batchShortName          => batchShortName
      , skipCheckJob            => skipCheckJob
    );
    moduleId := pkg_ModuleInfo.getModuleId(
      moduleName          => moduleName
      , svnRoot           => moduleSvnRoot
      , initialSvnPath    => moduleInitialSvnPath
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'sch_job'
      , filterCondition       =>
          'module_id = ' || moduleId
          || ' and job_short_name = ''' || jobShortName || ''''
          || ' and batch_short_name'
            || case when batchShortName is not null  then
                ' = ''' || batchShortName || ''''
              else
                ' is null'
              end
      , expectedRowCount      => 1
      , failMessageText       =>
          cinfo || '??????? ?? ???????'
          || jobInfo
    );
    if not pkg_TestUtility.isTestFailed() then
      select
        t.*
      into jbr
      from
        sch_job t
      where
        t.module_id = moduleId
        and t.job_short_name = jobShortName
        and (
          t.batch_short_name = batchShortName
          or coalesce( batchShortName, t.batch_short_name) is null
        )
      ;
      pkg_TestUtility.compareChar(
        actualString      => jbr.public_flag
        , expectedString  => coalesce( publicFlag, 0)
        , failMessageText =>
            cinfo || '???????????? ???????? public_flag'
            || jobInfo
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ???????? ????????? ??????? ('
          || ' cinfo="' || cinfo || '"'
          || ', jobShortName="' || jobShortName || '"'
          || ', batchShortName="' || batchShortName || '"'
          || ', publicFlag=' || publicFlag
          || ').'
        )
      , true
    );
  end loadJob;



  /*
    ????????? ???????? ????
  */
  procedure loadBatch(
    cinfo varchar2
    , moduleName varchar2 := moduleName1
    , batchShortName varchar2 := Batch_ShortName
    , setNewBatchFlag pls_integer := null
    , xmlText varchar2
    , updateScheduleFlag number := null
    , skipLoadOption number := null
    , updateOptionValue number := null
  )
  is
  begin
    pkg_SchedulerLoad.loadBatch(
      moduleName              => moduleName
      , moduleSvnRoot         => null
      , moduleInitialSvnPath  => null
      , batchShortName        => batchShortName
      , xmlText               => xmlText
      , updateScheduleFlag    => updateScheduleFlag
      , skipLoadOption        => skipLoadOption
      , updateOptionValue     => updateOptionValue
    );

    -- ???? ????? ???????????? date_ins, ?.?. ?? ???? ???????????? "?????"
    -- ???? ??? ???, ??? ?????? ?? ?????????? ???????? ??????????
    if setNewBatchFlag is not null then
      update
        sch_batch t
      set
        t.date_ins =
          case when setNewBatchFlag = 1 then
            greatest( t.date_ins, sysdate - 23/24)
          else
            least( t.date_ins, sysdate - 1)
          end
      where
        t.batch_short_name = Batch_ShortName
      ;
    end if;

    getBatch( batchShortName => batchShortName);
    pkg_TestUtility.compareChar(
      actualString        => batch.module_id
      , expectedString    => pkg_ModuleInfo.getModuleId( moduleName)
      , failMessageText   =>
          cinfo || '???????????? ???????? module_id'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ???????? ????????? ????? ('
          || ' cinfo="' || cinfo || '"'
          || ', moduleName="' || moduleName || '"'
          || ', batchShortName="' || batchShortName || '"'
          || ').'
        )
      , true
    );
  end loadBatch;




  /*
    ?????????? ????????????? ???????? ????????? ??????.
  */
  function isCheckCase(
    caseInfo out varchar2
    , caseDescription varchar2
    , nextCaseUsedCount pls_integer := null
  )
  return boolean
  is
  begin
    checkCaseNumber := checkCaseNumber + 1;
    caseInfo :=
      'CASE ' || to_char( checkCaseNumber)
      || ' "' || caseDescription || '": '
    ;
    if pkg_TestUtility.isTestFailed()
          or testCaseNumber is not null
            and testCaseNumber
              not between checkCaseNumber
                and checkCaseNumber + coalesce( nextCaseUsedCount, 0)
        then
      return false;
    end if;
    logger.info( '*** ' || caseInfo);
    return true;
  end isCheckCase;



  /*
    ???????? ???????? ?????.
  */
  procedure checkLoadBatch(
    nextCaseUsedCount integer
  )
  is

    Case_Name constant varchar2(100) :=
      '???????? ?????'
    ;

    cinfo varchar2(200);

  begin
    if not isCheckCase( cinfo, Case_Name, nextCaseUsedCount) then
      return;
    end if;
    loadJob(
      cinfo             => cinfo
      , batchShortName  => Batch_ShortName
      , jobShortName    => 'process'
      , jobWhat         => coalesce(
          jobWhat
          ,
'declare

  procedure compareChar(
    actualString varchar2
    , expectedString varchar2
    , failMessageText varchar2
  )
  is
  begin
    if coalesce(
            nullif( actualString, expectedString)
            , nullif( expectedString, actualString)
          ) is not null
        then
      raise_application_error(
        pkg_Error.ProcessError
        , failMessageText
          || '': "'' || actualString || ''"''
      );
    end if;
  end compareChar;

begin
  sch_batch_option_t( ''' || Batch_ShortName || ''').setString(
    ''' || Option_Name || '''
    , ''' || Check_String || '''
  );

  -- getContextDate
  compareChar(
    to_char(
      pkg_Scheduler.getContextDate( ''DateOpt'')
      , ''dd.mm.yyyy hh24:mi:ss''
    )
    , ''01.05.2001 18:59:09''
    , ''getContextDate: bad value for DateOpt''
  );

  -- getContextNumber
  compareChar(
    pkg_Scheduler.getContextNumber( ''CheckPointList'')
    , -1.05
    , ''getContextNumber: bad value for CheckPointList''
  );
  compareChar(
    pkg_Scheduler.getContextNumber( ''CheckPointList'', valueIndex => 3)
    , 8
    , ''getContextNumber[3]: bad value for CheckPointList[3]''
  );

  -- getContextString
  compareChar(
    pkg_Scheduler.getContextString( ''Simple'', riseException => 1)
    , null
    , ''getContextString: bad value for Simple''
  );

  -- getContextValueCount
  compareChar(
    pkg_Scheduler.getContextValueCount( ''CheckPointList'')
    , 3
    , ''getContextValueCount: bad value for CheckPointList''
  );
end;'
        )
    );
    loadBatch(
      cinfo             => cinfo
      , xmlText         => coalesce( batchXmlText,
to_clob(
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>???????? ???? ?????? Scheduler ( ?????? pkg_SchedulerTest.testLoadBatch)</name>
  <batch_config>
    <retry_count>' || to_char( Config_RetrialCount1) || '</retry_count>
    <retry_interval>30</retry_interval>
    <schedule>
      <name>every day at 03.26</name>
      <interval type="hh24">
        <value>03</value>
      </interval>
      <interval type="mi">
        <value>26</value>
      </interval>
    </schedule>
    <option type="string" short_name="' || Option_Name || '" name="???????? ?????">
      <value>' || Check_String || '</value>
    </option>
    <option short_name="Simple" type="string" name="????????? ????????"/>
    <option short_name="DateOpt" type="date" name="???????? ???? ????" access_level="full" encryption="0" description="???????? ???? ???? ( ????????)">
      <value>01.05.2001 18:59:09</value>
      <value instance="Db1">05.05.2001</value>
      <value instance="Db2">05.05.2001 05:00:00</value>
    </option>
    <option short_name="DateList" type="date" access_level="value"
          name="???????? ?? ??????? ???"
          description="???????? ?? ??????? ??? ( ????????)"
        >
      <value_list instance="Db1">
        <item>01.05.2002 18:59:09</item>
        <item>02.05.2002</item>
        <item>03.05.2002 05:00:00</item>
      </value_list>
      <value_list instance="Db3" separator="|"/>
    </option>
    <option short_name="NumberOpt" type="number" name="???????? ????????" access_level="read">
      <prod_value>81.5</prod_value>
      <test_value>.5</test_value>
    </option>
    <option short_name="NumberList" type="number" name="???????? ?? ??????? ?????">
      <test_value_list/>
    </option>
    <option short_name="CheckPointList" type="number" name="???????? ?? ????? ????????">
      <prod_value_list>
        <item>80.98</item>
      </prod_value_list>
      <test_value_list>
        <item>-1.05</item>
        <item>0.05</item>
        <item>8</item>
      </test_value_list>
    </option>
    <option short_name="Password" type="string" name="??????" access_level="value" encryption="' || pkg_OptionCrypto.isCryptoAvailable() || '">
      <test_value instance="Db1">jdk15</test_value>
      <test_value instance="Db2">jdk16</test_value>
    </option>
    <option short_name="FieldList" type="string" name="?????? ?????">
      <prod_value_list separator=",">
        <item>ContractNumber</item>
        <item>LastName</item>
        <item>FirstName</item>
      </prod_value_list>
    </option>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
  <content id="2" job="process">
    <condition id="1">true</condition>
  </content>
  <content id="3" job="commit" module="Scheduler">
    <condition id="2">true</condition>
  </content>
  <content id="4" job="retry_batch" module="Scheduler">
    <condition id="3">error</condition>
    <condition id="3">skip</condition>
  </content>
</batch>'))
    );
    commit;
    pkg_SchedulerTest.testBatch( Batch_ShortName);
    if jobWhat is null then
      pkg_TestUtility.compareChar(
        expectedString => Check_String
        , actualString =>
            sch_batch_option_t( Batch_ShortName).getString( Option_Name)
        , failMessageText =>
            cinfo || 'compare option'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ????????: ' || Case_Name
        )
      , true
    );
  end checkLoadBatch;



  /*
    ???????? ???????? ????????????
  */
  procedure checkLoadBatchConfig
  is

    Case_Name constant varchar2(100) :=
      '???????? ????????????'
    ;

    cinfo varchar2(200);

  begin
    if not isCheckCase( cinfo, Case_Name) then
      return;
    end if;
    getBatch();
    pkg_TestUtility.compareChar(
      expectedString => to_char( Config_RetrialCount1)
      , actualString => to_char( batch.retrial_count)
      , failMessageText =>
          cinfo || 'compare retrial count before config loading'
    );
    pkg_SchedulerLoad.loadBatchConfig(
      moduleName => moduleName1
      , xmlText =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch_config short_name="' || Batch_ShortName || '">
  <retry_count>' || to_char( Config_RetrialCount2) || '</retry_count>
  <retry_interval>30</retry_interval>
 </batch_config>
'
      , updateScheduleFlag => 1
    );
    getBatch();
    pkg_TestUtility.compareChar(
      expectedString => to_char( Config_RetrialCount2)
      , actualString => to_char( batch.retrial_count)
      , failMessageText =>
          cinfo || 'compare retrial count after config loading'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ????????: ' || Case_Name
        )
      , true
    );
  end checkLoadBatchConfig;



  /*
    ???????? ????????? ????????? ???????.
  */
  procedure checkChangeJobVisibility
  is

    Case_Name constant varchar2(100) :=
      '????????? ????????? ???????'
    ;

    cinfo varchar2(200);

  begin
    if not isCheckCase( cinfo, Case_Name) then
      return;
    end if;
    loadJob(
      cinfo             => cinfo
      , jobShortName    => 'testMovedJob'
      , batchShortName  => Batch_ShortName
    );

    -- ... : ???? -> ??????
    loadJob(
      cinfo             => cinfo
      , jobShortName    => 'testMovedJob'
      , batchShortName  => null
    );

    -- ... : ?????? -> public
    loadJob(
      cinfo             => cinfo
      , jobShortName    => 'testMovedJob'
      , batchShortName  => null
      , publicFlag      => 1
    );

    -- ... : public -> ????
    loadJob(
      cinfo             => cinfo
      , jobShortName    => 'testMovedJob'
      , batchShortName  => Batch_ShortName
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ????????: ' || Case_Name
        )
      , true
    );
  end checkChangeJobVisibility;



  /*
    ???????? ????????? ?????? ?????.
  */
  procedure checkChangeModule
  is

    Case_Name constant varchar2(100) := '????????? ?????? ?????';

    -- ???????? ????????? ??????
    cinfo varchar2(200);

  begin
    if not isCheckCase( cinfo, Case_Name) then
      return;
    end if;

    loadBatch(
      cinfo                 => cinfo
      , moduleName          => moduleName1
      , setNewBatchFlag     => 0
      , xmlText             =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>Test batch</name>
  <batch_config>
    <option short_name="NumOpt" type="number" name="???????? ????????">
      <value>101</value>
    </option>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
</batch>'
    );

    sch_batch_option_t( Batch_ShortName).setNumber( 'NumOpt', 1049);
    loadBatch(
      cinfo                 => cinfo
      , moduleName          => moduleName2
      , xmlText             =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>Test batch</name>
  <batch_config>
    <option short_name="NumOpt" type="number" name="???????? ????????">
      <value>102</value>
    </option>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
</batch>'
      , updateOptionValue   => null
    );
    pkg_TestUtility.compareChar(
      actualString      =>
          sch_batch_option_t( Batch_ShortName).getNumber( 'NumOpt')
      , expectedString  => to_char( 1049)
      , failMessageText =>
          cinfo || '?? ????????? ???????? ?????????'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ????????: ' || Case_Name
        )
      , true
    );
  end checkChangeModule;



  /*
    ???????? ?????????????? ?????.
  */
  procedure checkRenameBatch
  is

    Case_Name constant varchar2(100) := '?????????????? ?????';

    -- ???????? ????????? ??????
    cinfo varchar2(200);

    batchId integer;

  begin
    if not isCheckCase( cinfo, Case_Name) then
      return;
    end if;

    loadBatch(
      cinfo                 => cinfo
      , xmlText             =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>Test batch</name>
  <batch_config>
    <option short_name="SaveDay" type="number" name="???? ????????">
      <value>30</value>
    </option>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
</batch>'
      , updateOptionValue   => 1
    );
    sch_batch_option_t( Batch_ShortName).setNumber( 'SaveDay', 62);
    batchId := batch.batch_id;

    pkg_SchedulerLoad.renameBatch(
      batchShortName      => Batch_ShortName
      , newBatchShortName => Batch_ShortName2
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'sch_batch'
      , filterCondition       =>
          'batch_id = ' || batchId
          || ' and batch_short_name = ''' || Batch_ShortName2 || ''''
      , expectedRowCount      => 1
      , failMessageText       =>
          cinfo || '?????????????? ?? ?????????'
    );
    pkg_TestUtility.compareChar(
      actualString      =>
          sch_batch_option_t( Batch_ShortName2).getNumber( 'SaveDay')
      , expectedString  => to_char( 62)
      , failMessageText =>
          cinfo || '?? ????????? ???????? ?????????'
    );

    sch_batch_option_t( Batch_ShortName2).setNumber( 'SaveDay', 63);

    pkg_SchedulerLoad.renameBatch(
      batchId             => batchId
      , newBatchShortName => Batch_ShortName
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'sch_batch'
      , filterCondition       =>
          'batch_id = ' || batchId
          || ' and batch_short_name = ''' || Batch_ShortName || ''''
      , expectedRowCount      => 1
      , failMessageText       =>
          cinfo || '?????????????? ?? Id ?? ?????????'
    );
    pkg_TestUtility.compareChar(
      actualString      =>
          sch_batch_option_t( Batch_ShortName).getNumber( 'SaveDay')
      , expectedString  => to_char( 63)
      , failMessageText =>
          cinfo || '?? ????????? ???????? ?????????'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ????????: ' || Case_Name
        )
      , true
    );
  end checkRenameBatch;



-- testLoadBatch
begin
  pkg_TestUtility.beginTest( 'testLoadBatch');

  prepareData();

  checkLoadBatch( nextCaseUsedCount => 1);

  if jobWhat is null and batchXmlText is null then
    checkLoadBatchConfig();

    checkChangeJobVisibility();
    checkChangeModule();
    checkRenameBatch();
  end if;

  pkg_SchedulerLoad.deleteBatch( Batch_ShortName);
  pkg_TestUtility.endTest();
  commit;
end testLoadBatch;

/* proc: testNlsLanguage
  ???????? ????? ?????????.

  ?????????:
  nlsLanguage                 - ???????? ?????????? NLS_LANGUAGE
*/
procedure testNlsLanguage(
  nlsLanguage varchar2
)
is
  Batch_ShortName constant varchar2(50) := 'TestBatch';
-- testNlsLanguage
begin
  pkg_SchedulerLoad.loadJob(
    moduleName => pkg_Scheduler.Module_Name
    , batchShortName => Batch_ShortName
    , jobShortName => 'process'
    , jobName => '???????? job'
    , description => '???????? job'
    , jobWhat =>
        'begin
           if 1/0 = 0 then
             null;
           end if;
        end;'
  );
  pkg_SchedulerLoad.loadBatch(
    moduleName => pkg_Scheduler.Module_Name
    , batchShortName => Batch_ShortName
    , xmlText =>
to_clob(
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>Test batch</name>
  <batch_config>
    <retry_count>1</retry_count>
    <retry_interval>30</retry_interval>
    <nls_language>' || nlsLanguage || '</nls_language>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
  <content id="2" job="process">
    <condition id="1">true</condition>
  </content>
  <content id="3" job="commit" module="Scheduler">
    <condition id="2">true</condition>
  </content>
  <content id="4" job="retry_batch" module="Scheduler">
    <condition id="3">error</condition>
    <condition id="3">skip</condition>
  </content>
</batch>')
  );
  commit;
  pkg_SchedulerTest.testBatch(
    Batch_ShortName
    , raiseWhenRetryFlag => 0
  );
  commit;
end testNlsLanguage;

/* proc: testWebApi
  ???? API ??? web-??????????.
*/
procedure testWebApi
is

  pragma autonomous_transaction;

  -- Id ?????? ??? ????????????
  moduleId integer := pkg_SchedulerMain.getModuleId();

  -- ???????? ????
  Batch_ShortName constant varchar2(50) := 'TestBatch_WebApi';
  Batch_Name constant varchar2(100) :=
    '???????? ???? ( pkg_SchedulerTest.testWebApi)'
  ;
  batchId integer;

  -- ??????? ????????
  currentOperatorId integer;

  -- Id ?????????, ??????????? ? API-????????
  testOperatorId integer;



  /*
    ????????? ???????? ????.
  */
  procedure addTestBatch
  is
  begin
    pkg_SchedulerLoad.loadBatch(
      moduleName => pkg_Scheduler.Module_Name
      , batchShortName => Batch_ShortName
      , xmlText =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>' || Batch_Name || '</name>
  <batch_config>
    <retrial_count>1</retrial_count>
    <retrial_interval>30</retrial_interval>
    <schedule>
      <name>every day at 03.26</name>
      <interval type="hh24">
        <value>03</value>
      </interval>
      <interval type="mi">
        <value>26</value>
      </interval>
    </schedule>
    <option type="string" short_name="TestOption" name="???????? ?????">
      <value></value>
    </option>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
</batch>'
      );
    commit;

    select
      t.batch_id
    into batchId
    from
      sch_batch t
    where
      t.batch_short_name = Batch_ShortName
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ?????????? ????????? ?????.'
        )
      , true
    );
  end addTestBatch;



  /*
    ???????? ?????? ??????? ??? ??????????? ??????????.
  */
  procedure testOptionApi
  is

    optionId integer;
    valueId integer;

    rc sys_refcursor;

  begin
    pkg_TestUtility.beginTest( 'testWebApi: option API');

    -- ???????? ?????????
    optionId := pkg_Scheduler.createOption(
      batchId                 => batchId
      , optionShortName       => 'DataServerName'
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => null
      , encryptionFlag        => null
        -- ?????? ???? 1 ( ?? ?????????)
      , testProdSensitiveFlag => null
      , optionName            => '??? ????????? ???????'
      , optionDescription     => '??? ????????? ??????? ( ????? ????????)'
      , dateValue             => null
      , numberValue           => null
      , stringValue           => 'UsedServer'
      , stringListSeparator   => null
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'option_id = ' || optionId
          || ' and object_short_name = ''' || Batch_ShortName || ''''
          || ' and object_type_short_name = '''
            || pkg_SchedulerMain.Batch_OptionObjTypeSName || ''''
          || ' and string_value = ''UsedServer'''
      , expectedRowCount      => 1
      , failMessageText       =>
          'createOption: ???????????? ?????? ? v_opt_option_value'
    );

    -- ????????? ???????? ????????
    pkg_Scheduler.setOptionValue(
      batchId                 => batchId
      , optionId              => optionId
      , dateValue             => null
      , numberValue           => null
      , stringValue           => 'UsedServer2'
      , valueIndex            => null
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'option_id = ' || optionId
          || ' and string_value = ''UsedServer2'''
      , expectedRowCount      => 1
      , failMessageText       =>
          'setOptionValue: ???????????? ?????? ? v_opt_option_value'
    );

    -- ????????? ?????????
    pkg_Scheduler.updateOption(
      batchId                 => batchId
      , optionId              => optionId
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => 0
      , encryptionFlag        => 0
      , testProdSensitiveFlag => 1
      , optionName            => '??? ????????? ??????? (2)'
      , optionDescription     => ''
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'option_id = ' || optionId
          || ' and option_name = ''??? ????????? ??????? (2)'''
      , expectedRowCount      => 1
      , failMessageText       =>
          'updateOption: ???????????? ?????? ? v_opt_option_value'
    );

    -- ????? ??????????
    rc := pkg_Scheduler.findOption(
      batchId                 => batchId
      , optionId              => null
      , maxRowCount           => 5
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 1 + 1
      , failMessageText       =>
          'findOption(batchId): ??????????? ????? ??????? ? ???????'
    );

    rc := pkg_Scheduler.findOption(
      batchId                 => null
      , optionId              => optionId
      , maxRowCount           => 5
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 1
      , failMessageText       =>
          'findOption(optionId): ??????????? ????? ??????? ? ???????'
    );

    -- ????????? ?????? ???????? ??????? ????
    valueId := pkg_Scheduler.createValue(
      batchId                   => batchId
      , optionId                => optionId
      , prodValueFlag           => pkg_Common.isProduction()
      , instanceName            => pkg_Common.getInstanceName()
      , dateValue               => null
      , numberValue             => null
      , stringValue             => 'UsedServer3'
      , stringListSeparator     => null
      , operatorId              => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'option_id = ' || optionId
          || ' and value_id = ' || valueId
          || ' and string_value = ''UsedServer3'''
      , expectedRowCount      => 1
      , failMessageText       =>
          'createValue: ???????????? ?????? ? v_opt_option_value'
    );

    -- ????????? ????????
    pkg_Scheduler.updateValue(
      batchId                   => batchId
      , valueId                 => valueId
      , dateValue               => null
      , numberValue             => null
      , stringValue             => 'UsedServer4'
      , valueIndex              => null
      , operatorId              => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'value_id = ' || valueId
          || ' and string_value = ''UsedServer4'''
      , expectedRowCount      => 1
      , failMessageText       =>
          'updateValue: ???????????? ?????? ? v_opt_option_value'
    );

    -- ????? ????????
    rc := pkg_Scheduler.findValue(
      batchId                 => batchId
      , valueId               => null
      , optionId              => optionId
      , maxRowCount           => 20
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 2
      , failMessageText       =>
          'findValue: ??????????? ????? ??????? ? ???????'
    );

    -- ???????? ????????
    pkg_Scheduler.deleteValue(
      batchId                 => batchId
      , valueId               => valueId
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'option_id = ' || optionId
          || ' and value_id = ' || valueId
      , expectedRowCount      => 0
      , failMessageText       =>
          'deleteValue: ???????????? ?????? ? v_opt_option_value'
    );

    -- ???????? ?????????
    pkg_Scheduler.deleteOption(
      batchId                 => batchId
      , optionId              => optionId
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'option_id = ' || optionId
      , expectedRowCount      => 0
      , failMessageText       =>
          'deleteOption: ???????????? ?????? ? v_opt_option_value'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ???????????? ??????? ??? ??????????? ??????????.'
        )
      , true
    );
  end testOptionApi;



  /*
    ???? ??????? %ModuleRolePrivilege.
  */
  procedure testModuleRolePrivilegeApi
  is

    -- ???? ??? ????????????
    roleId integer;

    moduleRolePrivilegeId integer;

    rc sys_refcursor;

  begin
    select
      t.role_id
    into roleId
    from
      v_op_role t
    where
      t.role_short_name = 'AllBatchAdmin'
    ;

    moduleRolePrivilegeId := pkg_Scheduler.createModuleRolePrivilege(
      moduleId        => moduleId
      , roleId        => roleId
      , privilegeCode => pkg_Scheduler.Read_PrivilegeCode
      , operatorId    => testOperatorId
    );

    rc := pkg_Scheduler.findModuleRolePrivilege(
      moduleRolePrivilegeId   => moduleRolePrivilegeId
      , moduleId              => moduleId
      , privilegeCode         => pkg_Scheduler.Read_PrivilegeCode
      , roleId                => roleId
      , maxRowCount           => 5
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 1
      , failMessageText       =>
          'findModuleRolePrivilege: ??????????? ????? ??????? ? ???????'
    );

    pkg_Scheduler.deleteModuleRolePrivilege(
      moduleRolePrivilegeId => moduleRolePrivilegeId
      , operatorId          => testOperatorId
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ???????????? ??????? %ModuleRolePrivilege.'
        )
      , true
    );
  end testModuleRolePrivilegeApi;



  /*
    ???? ??????? %Batch.
  */
  procedure testBatchApi
  is

    rc sys_refcursor;

  begin
    rc := pkg_Scheduler.findBatch(
      batchId                 => batchId
      , batchShortName        => Batch_ShortName
      , batchName             => Batch_Name
      , moduleId              => moduleId
      , retrialCount          => null
      , lastDateFrom          => null
      , lastDateTo            => null
      , rowCount              => 5
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 1
      , failMessageText       =>
          'findBatch: ??????????? ????? ??????? ? ???????'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ???????????? ??????? %Batch.'
        )
      , true
    );
  end testBatchApi;



  /*
    ???? ??????? ????????????.
  */
  procedure testDictionaryFunction
  is

    rc sys_refcursor;

    nRow integer;

  begin
    rc := pkg_Scheduler.findModule();
    select
      count(*)
    into nRow
    from
      v_mod_module md
    where
      exists
        (
        select
          null
        from
          sch_batch bt
        where
          bt.module_id = md.module_id
        )
    ;
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => nRow
      , failMessageText       =>
          'findModule: ??????????? ????? ??????? ? ???????'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ???????????? ??????? ????????????.'
        )
      , true
    );
  end testDictionaryFunction;



-- testWebApi
begin
  addTestBatch();

  -- ??????? ???????? ?????????, ????? ??????????? ?????? ?????
  -- web-?????????
  currentOperatorId := pkg_Operator.getCurrentUserId();
  pkg_Operator.logoff();
  testOperatorId := currentOperatorId;

  testOptionApi();

  pkg_TestUtility.beginTest( 'testWebApi: other API');
  testModuleRolePrivilegeApi();
  testBatchApi();
  testDictionaryFunction();
  pkg_TestUtility.endTest();

  -- ??????????????? ??????????? ?????????
  pkg_Operator.setCurrentUserId( currentOperatorId);

  pkg_SchedulerLoad.deleteBatch( Batch_ShortName);
  commit;
exception when others then
  pkg_Operator.setCurrentUserId( currentOperatorId);
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '?????? ??? ???????????? API ??? web-??????????.'
      )
    , true
  );
end testWebApi;

/* proc: testBatchOption
  ???? ???? sch_batch_option_t.
*/
procedure testBatchOption
is

  pragma autonomous_transaction;

  -- ???????? ????
  Batch_ShortName constant varchar2(50) := 'TestBatch_BatchOption';
  batchId integer;



  /*
    ????????? ???????? ????.
  */
  procedure addTestBatch
  is
  begin
    pkg_SchedulerLoad.loadBatch(
      moduleName => pkg_Scheduler.Module_Name
      , batchShortName => Batch_ShortName
      , xmlText =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>???????? ???? ( pkg_SchedulerTest.testBatchOption)</name>
  <batch_config>
    <option type="string" short_name="TestOption1" name="???????? ????? 1">
      <value>Test1</value>
    </option>
    <option type="string" short_name="TestOption2" name="???????? ????? 2">
      <value>Test2</value>
    </option>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
</batch>'
      );
    commit;

    select
      t.batch_id
    into batchId
    from
      sch_batch t
    where
      t.batch_short_name = Batch_ShortName
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ?????????? ????????? ?????.'
        )
      , true
    );
  end addTestBatch;



  /*
    ????????? ????.
  */
  procedure processTest
  is

    opt sch_batch_option_t;

  begin
    pkg_TestUtility.beginTest( 'testBatchOption: sch_batch_option_t');

    -- ????????? ??????????????? ????? ( ?????? ?????? ???????????)
    opt := sch_batch_option_t(
      batchShortName  => 'TestBatch_BatchOption_???'
      , moduleId      => pkg_SchedulerMain.getModuleId()
    );

    -- ??????????? ?? batchShortName
    opt := sch_batch_option_t( Batch_ShortName);
    pkg_TestUtility.compareChar(
      expectedString => opt.getString( 'TestOption1')
      , actualString => 'Test1'
      , failMessageText => '???????????? ???????? ????????? TestOption1'
    );

    -- ??????????? ?? batchId
    opt := sch_batch_option_t( batchId);
    pkg_TestUtility.compareChar(
      expectedString => opt.getObjectShortName()
      , actualString => Batch_ShortName
      , failMessageText => '???????????? ???????? getObjectShortName()'
    );
    pkg_TestUtility.compareChar(
      expectedString => opt.getString( 'TestOption2')
      , actualString => 'Test2'
      , failMessageText => '???????????? ???????? ????????? TestOption2'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '?????? ??? ?????????? ?????.'
        )
      , true
    );
  end processTest;



-- testBatchOption
begin
  addTestBatch();
  processTest();
  pkg_SchedulerLoad.deleteBatch( Batch_ShortName);
  commit;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '?????? ??? ???????????? ???? sch_batch_option_t.'
      )
    , true
  );
end testBatchOption;

end pkg_SchedulerTest;
/
