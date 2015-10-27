-- view: v_prm_registered_session
-- Список незавершённых зарегистированных сессий 
-- и сессий, для которых не выполнены все задания
create or replace view v_prm_registered_session as 
select  
  /* SVN root: Oracle/Module/ProcessMonitor */
  registered_session_id
  , sid
  , serial#
  , spid 
  , sql_trace_level_set
  , sql_trace_date
from
  (
  select /*+index(s prm_reg_session_ux_exist)*/
    case is_finished when 0 then sid end as sid
    , case is_finished when 0 then serial# end as serial#
    , s.registered_session_id
    , s.sql_trace_level_set
    , s.spid
    , s.sql_trace_date
  from
    prm_registered_session s 
  ) s
where
  sid is not null
/  
comment on table v_prm_registered_session is
'Список незавершённых зарегистированных сессий 
и сессий, для которых не выполнены все задания
[ SVN root: Oracle/Module/ProcessMonitor ]
'
/
comment on column v_prm_registered_session.registered_session_id is
'Id записи. Первичный ключ таблицы'
/
comment on column v_prm_registered_session.sid is
'sid сессии Oracle'
/
comment on column v_prm_registered_session.serial# is
'serial# сессии Oracle'
/
comment on column v_prm_registered_session.spid is
'spid сессии Oracle'
/
comment on column v_prm_registered_session.sql_trace_level_set is
'Включённый уровень трассировки для сессии'
/
comment on column v_prm_registered_session.sql_trace_date is
'Дата/время включения трассировки'
/
