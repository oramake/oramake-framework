-- script: Do/activate-all.sql
-- ���������� �������� �������.
--
-- ���������:
-- usedDayCount               - ������ ������, ������� ���������������
--                              �������� <pkg_Scheduler:deactivateBatchAll> �
--                              ��������� usedDayCount ���� (0 ������� ����,
--                              null ��� ����������� (�� ���������))
--


declare

  usedDayCount number := to_number( '&1');

begin
  pkg_Scheduler.activateBatchAll(usedDayCount => usedDayCount);
end;
/
