-- ������� ������ ������� ����.
--
declare

  -- ����� ���� ��� ���������� ������
  saveDayCount number := pkg_Scheduler.getContextNumber(
    'SaveDayCount', riseException => 1
  );

  -- ����� ��������� �������
  nDelete integer;

begin
  nDelete := pkg_Scheduler.clearLog( trunc( sysdate) - saveDayCount);
  jobResultMessage := '������� ' || to_char( nDelete) || ' �������.';
end;
