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

-- Определяем поле с именем типа батча для сравнения с маской
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

  -- Допустимые коды операций
  Activate_Code constant varchar2(10)       := 'ACT';
  Deactivate_Code constant varchar2(10)     := 'DEACT';
  Reactivate_Code constant varchar2(10)     := 'REACT';
  Resume_Code constant varchar2(10)         := 'RESUME';
  Stop_Code constant varchar2(10)           := 'STOP';

  -- Таймаут ( в днях) для повторной активации
  reactivateTimeout constant number := 1;

  -- Id текущего оператора
  operatorId constant integer := pkg_Operator.GetCurrentUserId();

  -- Код выполняемой операции 
  mainOperationCode constant varchar2(10) := :oms_operationCode;

  -- Список масок
  patternList constant varchar2(1000) := :oms_patternList;

  -- Список Id обработанных пакетных заданий ( через запятую)
  resumeBatchIdList varchar2(4000);

  -- Список сессий, завершения которых нужно ожидать по операции STOP
  -- ( через запятую, "<sid>:<serial#>")
  stopSessionUidList varchar2(4000);



  /*
    Возвращает название выполняемой операции ( с большой буквы).

    Параметры:
    operationCode             - код операции
  */
  function getOperationName(
    operationCode varchar2
  )
  return varchar2
  is

    -- Название операции
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
        , 'Неизвестный код типа операции ('
          || ' operationCode="' || operationCode || '"'
          || ').'
      );
    end if;
    return operationName;
  end getOperationName;



  /*
    Выполняет обработку подходящих пакетных заданий.

    Параметры:
    operationCode             - код операции

    Возврат:
    число обработанных пакетных заданий

    Замечания:
    - заполняется resumeBatchIdList, а также stopSessionUidList при операции
      STOP;
  */
  function processBatch( operationCode varchar2)
  return pls_integer
  is

    -- Основная операция над пакетными заданиями
    baseOperationCode varchar2(10) :=
      case operationCode
        when Resume_Code  then Reactivate_Code
        when Stop_Code    then Deactivate_Code
        else operationCode
      end
    ;

    -- Батчи для выполнения операции
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
      -- Необходимость обработки батча
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
                    v_sch_batch_root_log brl
                    inner join sch_log lg
                      on lg.log_id = brl.log_id
                  where
                    -- По батчу выполнялись действия текущим оператором за
                    -- последний период
                    brl.batch_id = e.batch_id
                    and brl.message_type_code
                      = pkg_Scheduler.BManage_MessageTypeCode
                    and brl.date_ins >= sysdate - reactivateTimeout
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
      -- Разбор списка масок
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

    -- Число проверенных батчей, подходящих под маску
    nChecked pls_integer := 0;

    -- Число обработанных батчей
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
              , 'Неизвестный код базовой операции ('
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
      , 'Ошибка при обработке пакетных заданий ('
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
    , 'Ошибка при выполнении операции над пакетными заданиями ('
      || ' mainOperationCode="' || mainOperationCode || '"'
      || ', patternList="' || patternList || '"'
      || ').'
    , true
  );
end;
/


--
-- Ожидание вынесено в отдельный PL/SQL-блок, чтобы до его начала в консоли
-- был выведен список обработанных пакетных заданий.
--

declare

  -- Максимальное время ожидания запуска/остановки сессий пакетных заданий
  batchWaitSecond integer := coalesce( :oms_batchWaitSecond, 60);

  -- Список Id обработанных пакетных заданий ( через запятую)
  resumeBatchIdList varchar2(4000) := :oms_resumeBatchIdList;

  -- Список сессий, завершения которых нужно ожидать по операции STOP
  -- ( через запятую, "<sid>:<serial#>")
  stopSessionUidList varchar2(4000) := :oms_stopSessionUidList;



  /*
    Ожидает запуска сессий пакетных заданий из списка resumeBatchIdList.
  */
  procedure waitBatchStart
  is

    -- Время завершения ожидания
    limitDate date := sysdate + batchWaitSecond / 86400;

    -- Число сессий пакетных заданий 
    nSession integer;

    -- Число ожидающих запуска пакетных заданий
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

      -- Используем динамически, чтобы обеспечить возможность выполнения
      -- других операций ( кроме STOP) при отсутствии прав на dbms_lock
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
      , 'Ошибка при ожидании запуска пакетных заданий ('
        || ' resumeBatchIdList="' || stopSessionUidList || '"'
        || ').'
      , true
    );
  end waitBatchStart;



  /*
    Ожидает завершения сессий, перечисленных в списке stopSessionUidList.
  */
  procedure waitSessionStop
  is

    -- Время завершения ожидания
    limitDate date := sysdate + batchWaitSecond / 86400;

    -- Число сессий пакетных заданий 
    nSession integer := 0;

    -- Число незавершившихся сессий
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

      -- Используем динамически, чтобы обеспечить возможность выполнения
      -- других операций ( кроме STOP) при отсутствии прав на dbms_lock
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
      , 'Ошибка при ожидании завершения сессий ('
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
    , 'Ошибка при ожидании запуска или завершения пакетных заданий ('
      || ' batchWaitSecond=' || batchWaitSecond
      || ').'
    , true
  );
end;
/

timing stop

set feedback on


undefine oms_batchTypeNameColumn
