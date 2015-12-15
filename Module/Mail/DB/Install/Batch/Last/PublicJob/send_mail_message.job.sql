-- �������� ��������� ���������
-- ���������� ��������� �� ����������� ����� ( ��������� ����������� � �������
-- ml_message, �������� �������� �������������� ������ ���������).
-- 
-- ���������:
-- 
-- MailRecipient                 - ������ �����������
-- MailSubject                   - ���� ������
-- MailBody                      - ����� ������
-- MailSenderPrefix              - ������� ������ �����������
-- 
-- ���������:
-- - ��� ���������� ��������� ������������ ���������� ����������;
-- - ��������� �������� 70 ����;
declare
                                        --����� ������
  recipient varchar2( 1024) := pkg_Scheduler.GetContextString(
    'MailRecipient'
  );
                                        --����� ����������
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
                                        --Id ��������������� ���������
  messageId integer;



  procedure SendMail
  is
                                        --��� ���������� ������� �� ��������
                                        --����������
    pragma autonomous_transaction;
    
  --SendMail
  begin
    messageId := pkg_Mail.SendMessage(
      sender        => pkg_Common.GetMailAddressSource( senderPrefix)
      , recipient   => coalesce(
                        recipient
                        , pkg_Common.GetMailAddressDestination
                      )
      , subject     => subject
      , messageText => replace( message, '\n', chr(10))
      , expireDate  => sysdate + 70
    );
    commit;
  end SendMail;



begin
  if subject is not null or message is not null then
    SendMail;
    jobResultMessage :=
      '��������� ������������ ��� �������� ('
      || ' message_id=' || to_char( messageId) 
      || ').'
    ;
  else
    jobResultMessage := '�������� ��������� �� �������������.';
  end if;
end;
