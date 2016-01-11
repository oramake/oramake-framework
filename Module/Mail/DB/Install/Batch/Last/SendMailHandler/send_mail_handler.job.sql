-- ���������� �������� �������� ���������
-- ���������� �������� �������� ���������.
-- 
-- SmtpServer                    - SMTP-������
declare
                                        --ID ��������� ������
  smtpServerList varchar2( 1024) := pkg_Scheduler.GetContextString(
    'SmtpServerList'
  );

  maxMessageCount integer := pkg_Scheduler.GetContextInteger(
    'MaxMessageCount'
  );

begin
  pkg_MailHandler.SendHandler(
    smtpServerList => smtpServerList
    , maxMessageCount => maxMessageCount
  );
end;