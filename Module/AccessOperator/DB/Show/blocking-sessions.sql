-- script: db/Show/blocking-sessions.sql
-- Блокирующие сессии.
select distinct
  v.sid
, v.serial#
from
  dba_ddl_locks d
inner join
  v$session v
on
  v.sid = d.session_id
where
  d.name = 'PKG_OPERATOR'
order by
  v.sid
/
