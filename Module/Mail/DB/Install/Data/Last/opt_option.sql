declare

  opt opt_option_list_t := opt_option_list_t(
    findModuleString => pkg_MailBase.Module_SvnRoot
  );

begin
  opt.addString(
    optionShortName       => pkg_MailBase.DefaultMailSender_OptSName
    , optionName          =>
        'Адрес отправителя по умолчанию для отправки сообщений'
    , optionDescription   =>
'В значении можно использовать макросы:
$(instanceName) - имя инстанса БД
$(systemName)   - имя системы, отправляющей сообщение (параметр systemName функции pkg_Mail.getMailSender)

Пример: "$(systemName).$(instanceName).oracle <user@example.com>"

Если значение не задано, то используется значение, возвращаемое функцией pkg_Common.getMailAddressSource модуля Common.'
    , prodStringValue     => ''
    , testStringValue     => ''
  );
  opt.addString(
    optionShortName       => pkg_MailBase.DefaultSmtpServer_OptSName
    , optionName          =>
        'SMTP-сервер по умолчанию для отправки писем'
    , optionDescription   =>
'Если не задан, то используется SMTP-сервер, возвращаемый функцией pkg_Common.getSmtpServer модуля Common.'
    , prodStringValue     => ''
    , testStringValue     => ''
  );
  opt.addString(
    optionShortName       => pkg_MailBase.DefaultSmtpUsername_OptSName
    , optionName          =>
        'Имя пользователя для авторизации на SMTP-сервере по умолчанию'
    , prodStringValue     => ''
    , testStringValue     => ''
  );
  opt.addString(
    optionShortName       => pkg_MailBase.DefaultSmtpPassword_OptSName
    , optionName          =>
        'Пароль для авторизации на SMTP-сервере по умолчанию'
    , prodStringValue     => ''
    , testStringValue     => ''
    , encryptionFlag      => 1
  );
  commit;
end;
/
