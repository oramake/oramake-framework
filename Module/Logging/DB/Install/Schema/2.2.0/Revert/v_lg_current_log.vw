-- view: v_lg_current_log
-- Лог работы программных модулей текущей сессии.
--
create or replace force view
  v_lg_current_log
as
select
  -- SVN root: Oracle/Module/Logging
  t.log_id
  , t.sessionid
  , t.level_code
  , t.message_value
  , t.message_label
  , t.message_text
  , t.context_level
  , t.context_type_id
  , t.context_value_id
  , t.open_context_log_id
  , t.open_context_log_time
  , t.open_context_flag
  , t.context_type_level
  , t.module_name
  , t.object_name
  , t.module_id
  , t.log_time
  , t.date_ins
  , t.operator_id
from
  lg_log t
where
  t.sessionid = sys_context('USERENV','SESSIONID')
/



comment on table v_lg_current_log is
  'Лог работы программных модулей текущей сессии [ SVN root: Oracle/Module/Logging]'
/
-- Устанавливает комментарии к полям
@oms-run Install/Schema/Last/set-log-comment.sql v_lg_current_log
