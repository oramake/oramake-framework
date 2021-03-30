declare

  -- Параметры тестирования
  opt opt_plsql_object_option_t := opt_plsql_object_option_t(
    moduleName        => pkg_MailBase.Module_Name
    , objectName      => 'pkg_MailTest'
  );

  messageId integer;

begin
  messageId := pkg_Mail.sendMessage(
    sender                  => opt.getString( pkg_MailTest.TestSender_OptSName)
    , recipient             =>
        coalesce(
          opt.getString( pkg_MailTest.TestRecipient_OptSName)
          , pkg_Common.getMailAddressDestination()
        )
    , copyRecipient         => null
    , subject               =>
        'test subject'
    , messageText           =>
        'Тестовое сообщение'
    , attachmentFileName    => null
    , attachmentType        => null
    , attachmentData        => null
    , smtpServer            =>
        opt.getString( pkg_MailTest.TestSmtpServer_OptSName)
    , expireDate            => add_months( sysdate, 1)
  );
  dbms_output.put_line(
    'messageId: ' || messageId
  );
  commit;
end;
/
