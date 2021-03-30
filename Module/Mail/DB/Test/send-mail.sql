begin
  -- Отправка письма для тестового ящика
  pkg_Mail.sendMail(
    recipient               =>
        coalesce(
          opt_plsql_object_option_t(
              moduleName        => pkg_MailBase.Module_Name
              , objectName      => 'pkg_MailTest'
            )
            .getString( pkg_MailTest.TestRecipient_OptSName)
          , pkg_Common.getMailAddressDestination()
        )
    , subject               => 'Mail: Тест'
    , messageText           =>
'Тестовое сообщение

Time: ' || to_char( systimestamp, 'dd.mm.yyyy hh24:mi:ss tzh:tzm') || '
'
    , attachmentFileName    => null
    , attachmentType        => null
    , attachmentData        => null
    , smtpServer            => null
    , username              => null
    , password              => null
    , isHtml                => null
  );
end;
/
