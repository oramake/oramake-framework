-- script: Install/Grant/2.3.0.2/run.sql
-- �������� ����� �� ������������� ������ �������� ���������� � ������ 2.3.0.2.
--
-- ���������:
-- toUserName                  - ��� ������������, �������� �������� �����
--
-- ���������:
--  - ������ ����������� ��� �������������, �������� ����������� ������� ������
--   ;
--

define toUserName = "&1"



grant execute on pkg_TaskProcessorBase to &toUserName
/
create or replace synonym &toUserName..pkg_TaskProcessorBase for pkg_TaskProcessorBase
/

grant merge view on v_tp_active_task to &toUserName
/

grant merge view on v_tp_task to &toUserName
/

grant merge view on v_tp_task_type to &toUserName
/



undefine toUserName
