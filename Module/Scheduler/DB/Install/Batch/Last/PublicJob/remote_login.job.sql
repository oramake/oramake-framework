-- ����������� ��������� � ��������� ��
-- ������������ �������� ��������� � ��������� �� (�� �����).
-- 
-- ���������:
-- 
-- TargetDbLink                  - ��� ����� � ��������� ��
declare
                                        --��� ����� ����������
  dbLink varchar2(100) := pkg_Scheduler.GetContextString( 
    'TargetDbLink'
    , 1
  );

begin
  pkg_Operator.RemoteLogin( dbLink);
  jobResultMessage := '�������� "' || pkg_Operator.GetCurrentUserName
      || '" �������������� � ' || dbLink || '.';
end;
