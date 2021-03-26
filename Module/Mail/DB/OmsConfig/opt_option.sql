-- ModuleConfig/Mail/opt_option.sql
-- Устанавливает значения настроечных параметров модуля Mail.
--

declare

  opt opt_option_list_t := opt_option_list_t(
    findModuleString => pkg_MailBase.Module_SvnRoot
  );

begin

  -- Устанавливаем SMTP-сервер если он не задан
  if opt.getString( optionShortName => pkg_MailBase.DefaultSmtpServer_OptSName)
        is null
      then
    -- SMTP-сервер для пром. БД
    opt.setValue(
      optionShortName       => pkg_MailBase.DefaultSmtpServer_OptSName
      , prodValueFlag       => 1
      , stringValue         => ''
      , skipIfNoChangeFlag  => 1
    );
    -- SMTP-сервер для тестовой БД
    opt.setValue(
      optionShortName       => pkg_MailBase.DefaultSmtpServer_OptSName
      , prodValueFlag       => 0
      , stringValue         => ''
      , skipIfNoChangeFlag  => 1
    );
  end if;
  commit;
end;
/
