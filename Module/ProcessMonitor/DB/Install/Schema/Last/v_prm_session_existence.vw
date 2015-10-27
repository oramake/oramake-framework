-- view: v_prm_session_existence
-- Список незавершённых зарегистированных сессий 
-- и сессий, для которых не выполнены все задания
-- c признаком существования сессии Oracle
create or replace view v_prm_session_existence as 
select  
  /* SVN root: Oracle/Module/ProcessMonitor */
  registered_session_id
  , sid
  , serial#
  , 
  (
  select
    count(1)
  from 
    v$session v
  where
    v.sid = r.sid 
    and v.serial# = r.serial#
    and v.username is not null
  ) as exists_session
from  
  v_prm_registered_session r    
/  
comment on table v_prm_session_existence is
'Список незавершённых зарегистированных сессий 
и сессий, для которых не выполнены все задания
c признаком существования сессии Oracle
[ SVN root: Oracle/Module/ProcessMonitor ]
'
/
comment on column v_prm_session_existence.registered_session_id is
'Id записи. Первичный ключ таблицы'
/
comment on column v_prm_session_existence.sid is
'sid сессии Oracle'
/
comment on column v_prm_session_existence.serial# is
'serial# сессии Oracle'
/
comment on column v_prm_session_existence.exists_session is
'Существует ли сессия Oracle'
/
