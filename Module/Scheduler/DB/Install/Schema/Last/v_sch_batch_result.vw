-- view: v_sch_batch_result
-- Данные о запусках и результате завершения пакетов по данным лога
-- (устаревшее представление, следует использовать v_sch_batch_operation).
--
create or replace force view v_sch_batch_result
(
  batch_id
  , start_date
  , finish_date
  , result_id
  , root_log_id
  , finish_log_id
  , start_message_text
  , finish_message_text
  , operator_id
)
as
select
  rl.batch_id
  , rl.date_ins as start_date
  , lg.date_ins as finish_date
  , lg.message_value as result_id
  , rl.log_id as root_log_id
  , lg.log_id as finish_log_id
  , rl.message_text as start_message_text
  , lg.message_text as finish_message_text
  , rl.operator_id
from
  v_sch_batch_root_log_old rl
  inner join sch_log lg
    on lg.parent_log_id = rl.log_id
      and lg.message_type_code = 'BFINISH'
where
  rl.message_type_code = 'BSTART'
union all
select
  bo.batch_id
  , lg.date_ins as start_date
  , lg2.date_ins as finish_date
  , bo.result_id
  , bo.start_log_id as root_log_id
  , bo.finish_log_id
  , lg.message_text as start_message_text
  , lg2.message_text as finish_message_text
  , lg.operator_id
from
  v_sch_batch_operation bo
  inner join lg_log lg
    on lg.log_id = bo.start_log_id
  inner join lg_log lg2
    on lg2.log_id = bo.finish_log_id
where
  -- pkg_SchedulerMain.Exec_BatchMsgLabel
  bo.batch_operation_label = 'EXEC'
  and bo.execution_level = 1
/



comment on table v_sch_batch_result is
  'Данные о запусках и результате завершения пакетов по данным лога (устаревшее представление, следует использовать v_sch_batch_operation) [SVN root: Oracle/Module/Scheduler]'
/
