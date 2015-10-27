-- view: v_prm_execution_action
-- ѕредставление по действи€м, дл€ которых
-- подошло врем€ выполнени€
create or replace view v_prm_execution_action
as
select
  /* SVN root: Oracle/Module/ProcessMonitor */
  registered_session_id
  , sid
  , serial#
  , a.session_action_code
  , a.email_recipient
  , a.email_subject
  , exists_session
  , planned_time
from
  v_prm_session_action a
where
  a.execution_time is null
  and 
  ( a.planned_time <= sysdate and exists_session = 1
    or a.planned_time is null and exists_session = 0
  )
/  
comment on table v_prm_execution_action
is
'ѕредставление по действи€м зарегистрированных сессий
[ SVN root: Oracle/Module/ProcessMonitor ]'
/
comment on column v_prm_execution_action.registered_session_id
is 'Id зарегистрированной сессии'
/
comment on column v_prm_execution_action.sid is
'sid сессии'
/
comment on column v_prm_execution_action.serial# is
'serial# сессии'
/
comment on column v_prm_execution_action.session_action_code is
' од действи€'
/
comment on column v_prm_execution_action.email_recipient is
'ѕолучатель email-сообщени€'
/
comment on column v_prm_execution_action.email_subject is
'“ема email-сообщени€'
/
comment on column v_prm_execution_action.exists_session is
'‘лаг существовани€ сессии Oracle'
/
comment on column v_prm_execution_action.planned_time is
'«апланированное врем€ выполнени€ действи€'
/
