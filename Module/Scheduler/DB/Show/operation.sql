-- script: Show/operation.sql
-- Операции по управлению и выполнению пакетных заданий (по данным лога,
-- созданным после обновления модуля Scheduler до версии 4.6.0).
--
-- Параметры:
--
-- [<batchPattern>[:[<maxRowCount>]]]
--
-- где:
--
-- batchPattern               - Маска краткого имени пакетного задания
--                              (like по полю batch_short_name)
--                              (по умолчанию без ограничений)
-- maxRowCount                - Максимальное число выводимых записей
--                              (последних по start_log_id)
--                              (по умолчанию 30)
--
--

var batchPattern varchar2(255)
var maxRowCount number

set feedback off

declare
  paramStr varchar2(255) := trim( '&1');
  i pls_integer;
begin
  i := instr( paramStr || ':', ':');
  :batchPattern := coalesce( substr( paramStr, 1, i - 1), '%');
  :maxRowCount := coalesce( to_number( substr( paramStr, i + 1)), 30);
end;
/

set feedback on


select
  *
from
  (
  select
    bo.start_log_id
    , bo.batch_id
    , b.batch_short_name
    , bo.batch_operation_label
    , bo.batch_sessionid
    , bo.execution_level
    , bo.start_time_utc
    , bo.finish_time_utc
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
    , op.login as operator_login
  from
    v_sch_batch_operation bo
    left join sch_batch b
      on b.batch_id = bo.batch_id
    left join sch_result r
      on r.result_id = bo.result_id
    left join lg_log slg
      on slg.log_id = bo.start_log_id
    left join v_op_operator op
      on op.operator_id = slg.operator_id
  where
    b.batch_short_name like :batchPattern escape '\'
  order by
    bo.start_log_id desc
  ) a
where
  rownum <= :maxRowCount
order by
  1
/
