-- view: v_sch_batch_root_log
-- Корневые записи лога по управлению и выполнению пакетных заданий
-- (устаревшее представление, следует использовать v_sch_batch_operation).
--
create or replace force view
  v_sch_batch_root_log
as
select
  bo.batch_id
  , bo.start_log_id as log_id
  , cast(
      case when
        -- pkg_SchedulerMain.Exec_BatchMsgLabel
        bo.batch_operation_label = 'EXEC'
      then
        -- pkg_Scheduler.Bstart_MessageTypeCode
        'BSTART'
      else
        -- pkg_Scheduler.Bmanage_MessageTypeCode
        'BMANAGE'
      end
      as varchar2(10)
    )
    as message_type_code
  , lg.message_text
  , lg.date_ins
  , lg.operator_id
  , bo.start_time_utc
  , bo.finish_time_utc
from
  v_sch_batch_operation bo
  inner join lg_log lg
    on lg.log_id = bo.start_log_id
where
  bo.execution_level = 1
union all
select
  bro.*
  , null as start_time_utc
  , null as finish_time_utc
from
  v_sch_batch_root_log_old bro
/



comment on table v_sch_batch_root_log is
  'Корневые записи лога по управлению и выполнению пакетных заданий (устаревшее представление, следует использовать v_sch_batch_operation) [ SVN root: Oracle/Module/Scheduler]'
/
