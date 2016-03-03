-- Отправка электронной почты
-- Отправляет письмо по электронной почте.
-- 
-- Параметры:
-- 
-- MailAddress                   - адрес получателя ( если не указан, то
--                                 используется по умолчанию из pkg_Common)
-- MailSubject                   - тема письма
-- MailBody                      - текст письма
-- MailSenderPrefix              - префикс адреса отправителя
declare
                                        --Адрес назначения
  address varchar2( 100) := pkg_Scheduler.GetContextString(
    'MailAddress'
  );
                                        --Тема письма
  subject varchar2( 1024) := pkg_Scheduler.GetContextString(
    'MailSubject'
  );
                                        --Текст письма
  message varchar2( 32767) := pkg_Scheduler.GetContextString(
    'MailBody'
  );
                                        --Префикс адреса отправителя
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
    jobResultMessage := 'Письмо отправлено.';
  else
    jobResultMessage := 'Отправка письма не производилась.';
  end if;
end;
