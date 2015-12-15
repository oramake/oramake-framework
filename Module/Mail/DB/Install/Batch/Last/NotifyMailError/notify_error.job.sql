-- ����������� �� ������� ������ � ������
-- ����������� �� ������� ������ � ������.
-- 
-- SendLimitMinute               - ����� �������� ��������� � �������
declare
                                        --����� �������� ��������� � �������
  sendLimitMinute integer := pkg_Scheduler.GetContextInteger(
    'SendLimitMinute'
  );
                                        --����� ������
  nError integer;

begin
  nError := pkg_MailHandler.NotifyError(
    sendLimit => numtodsinterval( sendLimitMinute, 'MINUTE')
  );
                                        --������������� ��������� ����������
  jobResultMessage :=
    '�������� ��������� ( ' || to_char( nError) || ' ������).'
  ;
end;