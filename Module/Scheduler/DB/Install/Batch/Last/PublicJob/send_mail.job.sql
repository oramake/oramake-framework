-- �������� ����������� �����
-- ���������� ������ �� ����������� �����.
-- 
-- ���������:
-- 
-- MailAddress                   - ����� ���������� ( ���� �� ������, ��
--                                 ������������ �� ��������� �� pkg_Common)
-- MailSubject                   - ���� ������
-- MailBody                      - ����� ������
-- MailSenderPrefix              - ������� ������ �����������
declare
                                        --����� ����������
  address varchar2( 100) := pkg_Scheduler.GetContextString(
    'MailAddress'
  );
                                        --���� ������
  subject varchar2( 1024) := pkg_Scheduler.GetContextString(
    'MailSubject'
  );
                                        --����� ������
  message varchar2( 32767) := pkg_Scheduler.GetContextString(
    'MailBody'
  );
                                        --������� ������ �����������
  senderPrefix varchar2( 255) := pkg_Scheduler.GetContextString(
    'MailSenderPrefix'
  );

begin
  if subject is not null or message is not null then
    pkg_Common.SendMail(
      mailSender => pkg_Common.GetMailAddressSource( senderPrefix)
      , mailRecipient =>
          case when address is not null then
            address
          else
            pkg_Common.GetMailAddressDestination
          end
      , subject => subject
      , message => replace( message, '\n', chr(10))
    );
    jobResultMessage := '������ ����������.';
  else
    jobResultMessage := '�������� ������ �� �������������.';
  end if;
end;
