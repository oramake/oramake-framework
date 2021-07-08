-- view: v_tp_task_operation
-- ќперации по управлению и выполнению заданий.
--
create or replace force view
  v_tp_task_operation
as
select
  cc.open_log_id as start_log_id
  , cc.context_value_id as task_id
  , cc.open_message_label as task_operation_label
  , case when
      -- pkg_TaskProcessorBase.Exec_TaskMsgLabel
      cc.open_message_label = 'EXEC'
    then
      cc.open_message_value
    end
    as start_number
  , cc.sessionid
  , cc.open_log_time_utc as start_time_utc
  , cc.close_log_time_utc as finish_time_utc
  , cc.close_log_id as finish_log_id
  , case when
      -- pkg_TaskProcessorBase.Exec_TaskMsgLabel
      cc.open_message_label = 'EXEC'
    then
      cc.close_message_label
    end
    as result_code
  , case when
      -- pkg_TaskProcessorBase.Exec_TaskMsgLabel
      cc.open_message_label = 'EXEC'
      -- pkg_Logging.Info_LevelCode
      and cc.close_level_code = 'INFO'
    then
      cc.close_message_value
    end
    as exec_result
  , cc.context_type_id as task_context_type_id
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
      -- pkg_TaskProcessorBase.Module_SvnRoot
      md.svn_root = 'Oracle/Module/TaskProcessor'
      -- pkg_TaskProcessorBase.Task_CtxTpSName
      and ct.context_type_short_name = 'TASK'
    )
/



comment on table v_tp_task_operation is
  'ќперации по управлению и выполнению заданий [SVN root: Oracle/Module/TaskProcessor]'
/
comment on column v_tp_task_operation.start_log_id is
  'Id записи лога начала выполнени€ операции'
/
comment on column v_tp_task_operation.task_id is
  'Id задани€'
/
comment on column v_tp_task_operation.task_operation_label is
  'ћетка операции ("CREATE" - —оздание; "EXEC" - ¬ыполнение; "START" - ѕостановка на выполнение; "STOP" - —н€тие с выполнени€; "UPDATE" - ќбновление параметров)'
/
comment on column v_tp_task_operation.start_number is
  'Ќомер запуска, начина€ с 1 (в случае операции по выполнению задани€)'
/
comment on column v_tp_task_operation.sessionid is
  '»дентификатор сессии, в которой выполн€лась операци€ (значение v$session.audsid)'
/
comment on column v_tp_task_operation.start_time_utc is
  '¬рем€ начала выполнени€ операции (по UTC)'
/
comment on column v_tp_task_operation.finish_time_utc is
  '¬рем€ завершени€ выполнени€ операции (по UTC)'
/
comment on column v_tp_task_operation.finish_log_id is
  'Id записи лога завершени€ выполнени€ операции'
/
comment on column v_tp_task_operation.result_code is
  ' од результата выполнени€ (в случае операции по выполнению задани€)'
/
comment on column v_tp_task_operation.exec_result is
  '–езультат выполнени€ в виде числа, возвращенный прикладным обработчиком (в случае операции по выполнению задани€)'
/
comment on column v_tp_task_operation.task_context_type_id is
  'Id типа контекста выполнени€ дл€ логировани€ операций над пакетными задани€ми (одинаковое значение дл€ всех записей представлени€, добавлено дл€ дальнейшего использовани€ в выборках)'
/
