--view: v_sch_batch_root_log
create or replace force view
  v_sch_batch_root_log
as
select
  cc.context_value_id as batch_id
  , cc.open_log_id as log_id
  , cast(
      case when
        -- pkg_SchedulerMain.Exec_BatchMsgLabel
        cc.open_message_label = 'EXEC'
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
  , cc.open_log_time_utc as start_time_utc
  , cc.close_log_time_utc as finish_time_utc
from
  v_lg_context_change cc
  inner join lg_log lg
    on lg.log_id = cc.open_log_id
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
union all
select
  bro.*
  , null as start_time_utc
  , null as finish_time_utc
from
  v_sch_batch_root_log_old bro
/



comment on table v_sch_batch_root_log is
  'Корневые записи лога по управлению и выполнению пакетных заданий [ SVN root: Oracle/Module/Scheduler]'
/

