-- Обработчик отправки почтовых сообщений
-- Обработчик отправки почтовых сообщений.
-- 
-- SmtpServer                    - SMTP-сервер
declare
                                        --ID источника данных
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