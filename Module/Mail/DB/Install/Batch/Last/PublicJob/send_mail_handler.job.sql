-- Обработчик отправки почтовых сообщений
declare

  smtpServerList varchar2( 1024) := pkg_Scheduler.getContextString(
    'SmtpServerList'
  );

  username varchar2( 1024) := pkg_Scheduler.getContextString(
    'Username'
  );

  password varchar2( 1024) := pkg_Scheduler.getContextString(
    'Password'
  );

  maxMessageCount integer := pkg_Scheduler.getContextNumber(
    'MaxMessageCount'
  );

begin
  pkg_MailHandler.sendHandler(
    smtpServerList    => smtpServerList
    , username        => username
    , password        => password
    , maxMessageCount => maxMessageCount
  );
end;
