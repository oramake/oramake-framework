-- script: Do/deactivate-all.sql
-- ������������ ��� �������� ����� � ���������� ��������� �� ��������� � ���.
--
-- (��. <pkg_Scheduler::deactivateBatchAll>)

begin
  pkg_Scheduler.deactivateBatchAll();
end;
/
