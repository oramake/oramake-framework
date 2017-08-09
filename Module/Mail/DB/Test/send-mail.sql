begin
  -- Отправка письма для тестового ящика
  pkg_Mail.sendMail(
    sender                  =>
          pkg_Common.getMailAddressSource( pkg_Mail.Module_Name)
    , recipient             => pkg_Common.getMailAddressDestination()
    , subject               => 'Тест'
    , messageText           =>
        'Тестовое сообщение'
    , attachmentFileName    => null
    , attachmentType        => null
    , attachmentData        => null
  );
end;
/
