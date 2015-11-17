--script: Show/session.sql
--Показывает сессии задач ( из <v_th_session>).

select
  ss.*
from
  v_th_session ss
order by
  ss.logon_time
  , ss.sid
/
