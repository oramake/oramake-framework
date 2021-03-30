-- Отправка почтового сообщения
-- Отправляет сообщение по электронной почте ( сообщение сохраняется в таблице
-- ml_message, реальная отправка осуществляется другим процессом).
-- 
-- Параметры:
-- 
-- MailRecipient                 - список получателей
-- MailSubject                   - тема письма
-- MailBody                      - текст письма
-- MailSenderPrefix              - префикс адреса отправителя
-- 
-- Замечания:
-- - для сохранения сообщения используется автономная транзакция;
-- - сообщения хранятся 70 дней;
declare
                                        --Текст письма
  recipient varchar2( 1024) := pkg_Scheduler.GetContextString(
    'MailRecipient'
  );
                                        --Адрес назначения
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
                                        --Id сформированного сообщения
  messageId integer;



  procedure SendMail
  is
                                        --Для исключения влияния на основную
                                        --транзакцию
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
      'Сообщение сформировано для отправки ('
      || ' message_id=' || to_char( messageId) 
      || ').'
    ;
  else
    jobResultMessage := 'Отправка сообщения не производилась.';
  end if;
end;
