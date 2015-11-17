--script: Show/command-pipe.sql
--Показывает командные каналы ( из <v_th_command_pipe>).

select
  ss.*
from
  v_th_command_pipe ss
order by
  ss.sid
  , ss.serial#
/
