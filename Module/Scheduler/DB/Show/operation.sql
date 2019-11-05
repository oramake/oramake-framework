-- script: Show/operation.sql
-- Операции по управлению и выполнению пакетных заданий.
--
-- Параметры:
--
-- [<batch>][:<operation>][:<maxRowCount>]
--
-- где:
--
-- batch                      - Маска краткого имени пакетного задания
--                              (like по полю batch_short_name)
--                              (по умолчанию без ограничений)
-- operation                  - Маска имени операции над пакетным заданием
--                              (like по полю batch_operation_label)
--                              (по умолчанию без ограничений)
-- maxRowCount                - Максимальное число выводимых записей
--                              (последних по start_log_id)
--                              (по умолчанию 30)
--
--

var batchPattern varchar2(255)
var operationPattern varchar2(255)
var maxRowCount number

set feedback off

declare
  paramStr varchar2(255) := trim( '&1');
  i1 pls_integer;
  i2 pls_integer;
begin
  i1 := instr( paramStr, ':', 1, 1);
  i2 := instr( paramStr, ':', 1, 2);
  if i2 = 0 then
    if i1 > 0 and substr( paramStr, i1 + 1, 1) between '0' and '9' then
      i2 := i1;
    else
      i2 := length( paramStr) + 1;
    end if;
  end if;
  if i1 = 0 then
    i1 := i2;
  end if;

  :batchPattern := substr( paramStr, 1, i1 - 1);
  :operationPattern := coalesce( substr( paramStr, i1 + 1, i2 - i1 - 1), '%');
  :maxRowCount := coalesce( to_number( substr( paramStr, i2 + 1)), 30);
end;
/

set feedback on


select
  bo.start_log_id
  , bo.batch_id
  , b.batch_short_name
  , bo.batch_operation_label
  , bo.batch_sessionid
  , bo.execution_level
  , from_tz( bo.start_time_utc, '00:00')
    at time zone to_char( systimestamp, 'tzh:tzm')
    as start_time
  , from_tz( bo.finish_time_utc, '00:00')
    at time zone to_char( systimestamp, 'tzh:tzm')
    as finish_time
  , trim(
      rtrim( rtrim(
        ltrim( to_char( bo.finish_time_utc - bo.start_time_utc), '+0')
        , '0123456789'), '.')
    )
    as exec_time
  , bo.sessionid
  , bo.finish_log_id
  , bo.result_id
  , r.result_name_rus as result_name
  , bo.processed_count
  , op.login as operator_login
from
  (
  select
    *
  from
    (
    select
      bo.*
    from
      sch_batch ba
      inner join v_sch_batch_operation bo
        on bo.batch_id = ba.batch_id
    where
      :batchPattern is not null
      and ba.batch_short_name like :batchPattern escape '\'
      and bo.batch_operation_label like :operationPattern escape '\'
    order by
      bo.start_log_id desc
    )
  where
    rownum <= :maxRowCount
  union all
  select
    *
  from
    (
    select
      bo.*
    from
      v_sch_batch_operation bo
    where
      :batchPattern is null
      and bo.batch_operation_label like :operationPattern escape '\'
    order by
      bo.start_log_id desc
    )
  where
    rownum <= :maxRowCount
  ) bo
  left join sch_batch b
    on b.batch_id = bo.batch_id
  left join sch_result r
    on r.result_id = bo.result_id
  left join lg_log slg
    on slg.log_id = bo.start_log_id
  left join v_op_operator op
    on op.operator_id = slg.operator_id
order by
  1
/
