--view: v_sch_batch_result
--
--Данные о запусках и результате завершения пакетов по данным лога ( <sch_log>).
--Использует представление <v_sch_batch_root_log>.
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
  v_sch_batch_root_log rl
  inner join sch_log lg
    on lg.parent_log_id = rl.log_id
      and lg.message_type_code = 'BFINISH'
where
  rl.message_type_code = 'BSTART'
/
