--script: Show/task.sql
--���������� ������ �����.
--
--���������:
--taskPattern                 - ������ ����� ������ ( ������
--                              "<module_name>:<process_full_name>" ������������
--                              �� like � ���� ��������, �� ��������� ���
--                              �����������)
--

define taskPattern = "coalesce( nullif( '&1', 'null'), '%')"



select
  ss.*
from
  v_th_session ss
where
  ss.module_name || ':' || ss.process_full_name like &taskPattern
order by
  ss.module_name
  , ss.process_full_name
  , ss.sid
/



undefine taskPattern
