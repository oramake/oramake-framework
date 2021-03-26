declare

  opt opt_option_list_t := opt_option_list_t(
    findModuleString => pkg_MailBase.Module_SvnRoot
  );

begin
  opt.addString(
    optionShortName       => pkg_MailBase.DefaultSmtpServer_OptSName
    , optionName          =>
        'SMTP-сервер по умолчанию для отправки писем (если не задан, то используется SMTP-сервер, возвращаемый функцией pkg_Common.getSmtpServer модуля Common)'
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
