-- ������� ������ ������������ �������� ���������� ����������� �����
declare

  numDays number := pkg_Scheduler.getContextNumber(
    'NumDays'
  );

begin
  pkg_MailHandler.clearFetchRequest(
    beforeDate => sysdate - numDays
  );
end;
