-- ���������� ��������� ������ ������ �� ������
declare

  dayCount number := pkg_Scheduler.GetContextInteger(
    'DayCount'
  );

begin
	pkg_DataSize.CreateReport(
    dateFrom => sysdate - dayCount
  );
end;