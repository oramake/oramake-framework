--script: Show/command-pipe.sql
--���������� ��������� ������ ( �� <v_th_command_pipe>).

select
  ss.*
from
  v_th_command_pipe ss
order by
  ss.sid
  , ss.serial#
/
