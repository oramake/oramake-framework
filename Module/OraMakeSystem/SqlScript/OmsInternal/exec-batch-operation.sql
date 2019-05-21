-- script: OmsInternal/exec-batch-operation.sql
-- Выполняет операцию над пакетными заданиями, реализованными с помощью модуля
-- Scheduler.
--
-- Параметры:
-- operationCode              - код операции ( возможные коды перечислены ниже)
-- patternList                - список масок пакетных заданий ( формат:
--                              список через запятую масок для like имени
--                              пакетного задания с опциональной маской
--                              имени типа пакетного задания вида
--                              [<batchTypePattern>/]<batchPattern>)
-- batchWaitSecond            - максимальное время ожидания запуска или
--                              завершения пакетных заданий при выполнении
--                              операций RESUME и STOP ( в секундах,
--                              0 не ожидать, по умолчанию 60)
--
-- Коды операций:
-- ACT                        - активация пакетных заданий
-- DEACT                      - деактивация пакетных заданий ( применяется
--                              только к активированным заданиям)
-- REACT                      - реактивация пакетных заданий ( применяется к
--                              активированным заданиям или к деактивированным
--                              заданиям, по которым в течение последних суток
--                              производились операции ( подразумевается
--                              деактивация) текущим оператором)
-- RESUME                     - реактивация пакетных заданий с ожиданием
--                              запуска пакетных заданий, которые должны
--                              начать выполняться
-- STOP                       - деактивация пакетных заданий с ожиданием
--                              завершения сессий выполняющихся пакетных
--                              заданий
--
--
-- Замечания:
--  - операция выполняется в одной транзакции по всем пакетным заданиям, т.о.
--    в случае возникновения ошибки она не выполнится ни по одному из пакетных
--    заданий;
--  - маска имени пакетного задания применяется к полю batch_short_name
--    таблицы sch_batch, а маска имени типа пакетного задания к полю
--    batch_type_short_name таблицы sch_batch_type либо при его отсутствии к
--    полю batch_type_name_eng той же таблицы;
--  - для выполнения операций STOP и RESUME у пользователя должны быть права
--    на пакет dbms_lock;
--

var oms_operationCode varchar2(10)
var oms_patternList varchar2(1000)
var oms_batchWaitSecond number

var oms_resumeBatchIdList varchar2(4000)
var oms_stopSessionUidList varchar2(4000)

set feedback off

-- Define a field with a name of the type of a batch for comparison with a
-- mask
define oms_batchTypeNameColumn = ""

column oms_batch_type_name_column new_value oms_batchTypeNameColumn noprint
set heading off

select
  max( tc.column_name)
    keep (
      dense_rank first order by
        nullif( tc.owner, sys_context( 'USERENV', 'CURRENT_SCHEMA'))
          nulls first
        , nullif( tc.column_name, 'BATCH_TYPE_SHORT_NAME') nulls first
    )
  as oms_batch_type_name_column
from
  all_tab_columns tc
where
  tc.table_name = 'SCH_BATCH_TYPE'
  and tc.column_name in (
      'BATCH_TYPE_NAME_ENG'
      , 'BATCH_TYPE_SHORT_NAME'
    )
/

set heading on
column oms_batch_type_name_column clear


timing start

begin
  :oms_operationCode := '&1';
  :oms_patternList := '&2';
  :oms_batchWaitSecond := '&3';
end;
/



declare

  -- Valid operation codes
  Activate_Code constant varchar2(10)       := 'ACT';
  Deactivate_Code constant varchar2(10)     := 'DEACT';
  Reactivate_Code constant varchar2(10)     := 'REACT';
  Resume_Code constant varchar2(10)         := 'RESUME';
  Stop_Code constant varchar2(10)           := 'STOP';

  -- Timeout (in days) for reactivation
  reactivateTimeout constant number := 1;

  -- Id of the current operator
  operatorId constant integer := pkg_Operator.GetCurrentUserId();

  -- Code of the operation to be performed
  mainOperationCode constant varchar2(10) := :oms_operationCode;

  -- List of masks
  patternList constant varchar2(1000) := :oms_patternList;

  -- List of processed batch Id (separated by commas)
  resumeBatchIdList varchar2(4000);

  -- List of sessions to wait for completion in the case of a STOP operation
  -- (separated by commas, "<sid>:<serial#>")
  stopSessionUidList varchar2(4000);



  /*
    Returns the name of the operation to be performed (with a capital letter).

    Parameters:
    operationCode             - operation code
  */
  function getOperationName(
    operationCode varchar2
  )
  return varchar2
  is

    -- Operation name
    operationName varchar2(30);

  begin
    operationName :=
      case operationCode
        when Activate_Code then
          'Activate'
        when Deactivate_Code then
          'Deactivate'
        when Reactivate_Code then
          'Reactivate'
        when Resume_Code then
          'Resume'
        when Stop_Code then
          'Stop'
      end
    ;
    if operationName is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Unknown operation code ('
          || ' operationCode="' || operationCode || '"'
          || ').'
      );
    end if;
    return operationName;
  end getOperationName;



  /*
    Performs processing of suitable batchs.

    Parameters:
    operationCode             - operation code

    Return:
    number of batchs processed

    Remarks:
    - resumeBatchIdList is filled in, as well as stopSessionUidList in the
      case of STOP operation;
  */
  function processBatch( operationCode varchar2)
  return pls_integer
  is

    -- Basic operation of batchs
    baseOperationCode varchar2(10) :=
      case operationCode
        when Resume_Code  then Reactivate_Code
        when Stop_Code    then Deactivate_Code
        else operationCode
      end
    ;

    -- Batchs for the operation
    cursor curBatch is
select
  f.*
  , case when
      operationCode = Stop_Code
      and f.is_for_process = 1
    then
      (
      select
        to_char( b.sid) || ':' || to_char( b.serial#) as session_uid
      from
        v_sch_batch b
      where
        b.batch_id = f.batch_id
        and b.sid is not null
      )
    end
    as session_uid
from
  (
  select
    e.*
      -- Need to process a batch?
    , case
        when
          baseOperationCode = Activate_Code
          or baseOperationCode = Deactivate_Code
            and e.oracle_job_id is not null
          or baseOperationCode = Reactivate_Code
            and (
              e.oracle_job_id is not null
              or e.oracle_job_id is null
                and exists
                  (
                  select
                    null
                  from
                    v_sch_batch_operation bo
                    inner join lg_log lg
                      on lg.log_id = bo.start_log_id
                  where
                    bo.batch_id = e.batch_id
                    and bo.start_time_utc >=
                      sys_extract_utc(
                        systimestamp
                        - numtodsinterval( reactivateTimeout, 'DAY')
                      )
                    and lg.operator_id = operatorId
                  )
            )
        then 1 else 0
      end
      as is_for_process
  from
    (
    select
      min( p.order_number) as pattern_number
      , d.batch_short_name
      , d.batch_id
      , d.oracle_job_id
    from
      (
      -- Parsing a list of masks
      select
        b.order_number
        , case when b.delim_pos > b.begin_pos then
            substr( b.pattern_list, b.begin_pos, b.delim_pos - b.begin_pos)
          end
          as batch_type_pattern
        , substr(
            b.pattern_list
            , b.delim_pos + 1
            , b.end_pos - b.delim_pos - 1
          )
          as batch_pattern
      from
        (
        select
          a.*
          , coalesce(
              nullif( least(
                nullif( instr( a.pattern_list, '/', a.begin_pos), 0)
                , a.end_pos), a.end_pos
              )
              , a.begin_pos - 1
            )
            as delim_pos
        from
          (
          select
            s.order_number
            , s.pattern_list
            , case when s.order_number = 1 then
                1
              else
                instr( s.pattern_list, ',', 1, s.order_number - 1) + 1
              end
              as begin_pos
            , instr( s.pattern_list || ',', ',', 1, s.order_number)
              as end_pos
          from
            (
            select
              patternList as pattern_list
              , sq.order_number
            from
              cmn_sequence sq
            ) s
          where
            s.order_number <=
              length( s.pattern_list) + 1
              - coalesce( length( replace( s.pattern_list, ',')), 0)
          ) a
        where
          a.end_pos > a.begin_pos
        ) b
      ) p
      inner join
        (
        select
          b.batch_id
          , b.batch_short_name
          , b.oracle_job_id
          , bt.&oms_batchTypeNameColumn as batch_type_short_name
        from
          sch_batch b
          inner join sch_batch_type bt
            on bt.batch_type_id = b.batch_type_id
        ) d
        on d.batch_short_name like p.batch_pattern
          and (
            p.batch_type_pattern is null
            or d.batch_type_short_name like p.batch_type_pattern
            )
    group by
      d.batch_short_name
      , d.batch_id
      , d.oracle_job_id
    ) e
  ) f
order by
  1, 2
;

    -- Number of checked batches, satisfying the mask
    nChecked pls_integer := 0;

    -- Number of processed batches
    nProcessed pls_integer := 0;

  --processBatch
  begin
    for rec in curBatch loop
      nChecked := nChecked + 1;
      if rec.is_for_process = 1 then
        if nProcessed = 0 then
          dbms_output.put_line(
            getOperationName( baseOperationCode) || ' batch:'
          );
        end if;
        dbms_output.put_line(
          rpad( rec.batch_short_name, 30)
          || ' ( batch_id =' || lpad( rec.batch_id, 5)
          || ', job =' || lpad( rec.oracle_job_id, 6)
          || ')'
        );
        case
          when baseOperationCode in ( Activate_Code, Reactivate_Code) then
            pkg_Scheduler.ActivateBatch(
              batchId       => rec.batch_id
              , operatorId  => operatorId
            );
          when baseOperationCode = Deactivate_Code then
            pkg_Scheduler.DeactivateBatch(
              batchId       => rec.batch_id
              , operatorId  => operatorId
            );
          else
            raise_application_error(
              pkg_Error.IllegalArgument
              , 'Unknown code of base operation ('
                || ' baseOperationCode="' || baseOperationCode || '"'
                || ').'
            );
        end case;
        if operationCode = Resume_Code then
          resumeBatchIdList :=
            case when resumeBatchIdList is not null then
              resumeBatchIdList || ','
            end
            || to_char( rec.batch_id)
          ;
        end if;
        if rec.session_uid is not null then
          stopSessionUidList :=
            case when stopSessionUidList is not null then
              stopSessionUidList || ','
            end
            || rec.session_uid
          ;
        end if;
        nProcessed := nProcessed + 1;
      end if;
    end loop;
    if nProcessed > 0 then
      commit;
      dbms_output.put_line(
        '- done ( processed: ' || to_char( nProcessed)
        || ', checked: ' || to_char( nChecked)
        || ')'
      );
    elsif nChecked > 0 then
      dbms_output.put_line(
        getOperationName( operationCode)
        || ' batch: no batch for process ( checked: '
        || to_char( nChecked)
        || ').'
      );
    else
      pkg_Common.OutputMessage(
        'Warning: ' || getOperationName( operationCode)
        || ' batch: batch not found'
        || ' ( patternList="' || patternList || '").'
      );
    end if;
    return nProcessed;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Error processing batches ('
        || ' operationCode="' || operationCode || '"'
        || ').'
      , true
    );
  end processBatch;



--main
begin
  if processBatch( mainOperationCode) > 0 then
    if resumeBatchIdList is not null then
      dbms_output.put_line(
        'Waiting for start batch...'
      );
      :oms_resumeBatchIdList := resumeBatchIdList;
    elsif stopSessionUidList is not null then
      dbms_output.put_line(
        'Waiting for stop batch...'
      );
      :oms_stopSessionUidList := stopSessionUidList;
    end if;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Error while executing operation on batches ('
      || ' mainOperationCode="' || mainOperationCode || '"'
      || ', patternList="' || patternList || '"'
      || ').'
    , true
  );
end;
/


--
-- The wait is placed in a separate PL / SQL block, so that before it starts,
-- the console displays a list of processed batches
--

declare

  -- Maximum waiting time for starting / stopping batches
  batchWaitSecond integer := coalesce( :oms_batchWaitSecond, 60);

  -- Id list of processed batches (separated by commas)
  resumeBatchIdList varchar2(4000) := :oms_resumeBatchIdList;

  -- List of sessions for waiting of terminate during STOP operation
  -- (comma separated, "<sid>:<serial #>")
  stopSessionUidList varchar2(4000) := :oms_stopSessionUidList;



  /*
    Waiting for batches to start from the list resumeBatchIdList.
  */
  procedure waitBatchStart
  is

    -- Time to end waiting
    limitDate date := sysdate + batchWaitSecond / 86400;

    -- Number of sessions of batches
    nSession integer;

    -- Number of batches waiting to be launched
    nWaitStart integer;

  begin
    loop
      select
        count( b.sid) as session_count
        , count(
            case when
              b.sid is null
              and b.next_date <= sysdate
            then 1
            end
          )
          as wait_start_count
      into nSession, nWaitStart
      from
        v_sch_batch b
      where
        instr(
          ',' || resumeBatchIdList || ','
          , ',' || to_char( b.batch_id) || ','
        ) > 0
      ;
      exit when nWaitStart = 0 or sysdate >= limitDate;

      -- We use it dynamically to allow execution of other operations (except
      -- STOP) when there are no rights to dbms_lock
      execute immediate 'begin dbms_lock.sleep( 1); end;';
    end loop;
    if nWaitStart > 0 then
      dbms_output.put_line(
        'Warning: Batch not started: '
        || to_char( nWaitStart)
        || ' ( started batch: ' || to_char( nSession) || ').'
      );
    else
      dbms_output.put_line(
        'Started batch: ' || to_char( nSession)
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Error on waiting to start batches ('
        || ' resumeBatchIdList="' || stopSessionUidList || '"'
        || ').'
      , true
    );
  end waitBatchStart;



  /*
    Pending the sessions listed in stopSessionUidList.
  */
  procedure waitSessionStop
  is

    -- Time to end waiting
    limitDate date := sysdate + batchWaitSecond / 86400;

    -- Number of sessions of batches
    nSession integer := 0;

    -- Number of uncompleted sessions
    nWaitStop integer := 0;

  begin
    if stopSessionUidList is not null then
      nSession :=
        length( stopSessionUidList)
        - length( replace( stopSessionUidList, ','))
        + 1
      ;
    end if;
    loop
      select
        count(*)
      into nWaitStop
      from
        v$session ss
      where
        instr(
          ',' || stopSessionUidList || ','
          , ',' || to_char( ss.sid) || ':' || to_char( ss.serial#) || ','
        ) > 0
      ;
      exit when nWaitStop = 0 or sysdate >= limitDate;

      -- We use it dynamically to allow execution of other operations (except
      -- STOP) when there are no rights to dbms_lock
      execute immediate 'begin dbms_lock.sleep( 1); end;';
    end loop;

    if nWaitStop > 0 then
      dbms_output.put_line(
        'Warning: Batch not stopped: '
        || to_char( nWaitStop)
        || ' ( stopped batch: ' || to_char( nSession - nWaitStop) || ').'
      );
    else
      dbms_output.put_line(
        'Stopped batch: ' || to_char( nSession)
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Error waiting to start batches ('
        || ' stopSessionUidList="' || stopSessionUidList || '"'
        || ').'
      , true
    );
  end waitSessionStop;

--main
begin
  if resumeBatchIdList is not null then
    waitBatchStart();
  elsif stopSessionUidList is not null then
    waitSessionStop();
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Error on waiting to start or finish batches ('
      || ' batchWaitSecond=' || batchWaitSecond
      || ').'
    , true
  );
end;
/

timing stop

set feedback on


undefine oms_batchTypeNameColumn
