-- Обработчик отправки почтовых сообщений
declare

  smtpServerList varchar2( 1024) := pkg_Scheduler.getContextString(
    'SmtpServerList'
  );

  maxMessageCount integer := pkg_Scheduler.getContextNumber(
    'MaxMessageCount'
  );

begin
  pkg_MailHandler.sendHandler(
    smtpServerList => smtpServerList
    , maxMessageCount => maxMessageCount
  );
end;
