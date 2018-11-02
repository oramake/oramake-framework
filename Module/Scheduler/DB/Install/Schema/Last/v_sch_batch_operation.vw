-- view: v_sch_batch_operation
-- Операции по управлению и выполнению пакетных заданий (по данным
-- лога, созданным после обновления модуля Scheduler до версии 4.6.0).
--
create or replace force view
  v_sch_batch_operation
as
select
  cc.open_log_id as start_log_id
  , cc.context_value_id as batch_id
  , cc.open_message_label as batch_operation_label
  , cc.context_type_level as execution_level
  , cc.open_log_time_utc as start_time_utc
  , cc.close_log_time_utc as finish_time_utc
  , cc.sessionid
  , cc.close_log_id as finish_log_id
  , case when
      -- pkg_SchedulerMain.Exec_BatchMsgLabel
      cc.open_message_label = 'EXEC'
      -- pkg_Logging.Info_LevelCode
      and cc.close_level_code = 'INFO'
    then
      cc.close_message_value
    end
    as result_id
from
  v_lg_context_change cc
where
  cc.context_type_id =
    (
    select
      ct.context_type_id
    from
      v_mod_module md
      inner join lg_context_type ct
        on ct.module_id = md.module_id
    where
      -- pkg_SchedulerMain.Module_SvnRoot
      md.svn_root = 'Oracle/Module/Scheduler'
      -- pkg_SchedulerMain.Batch_CtxTpSName
      and ct.context_type_short_name = 'BATCH'
    )
/



comment on table v_sch_batch_operation is
  'Операции по управлению и выполнению пакетных заданий (по данным лога, созданным после обновления модуля Scheduler до версии 4.6.0) [ SVN root: Oracle/Module/Scheduler]'
/
