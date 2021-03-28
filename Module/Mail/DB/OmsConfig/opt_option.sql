-- ModuleConfig/Mail/opt_option.sql
-- Устанавливает значения настроечных параметров модуля Mail.
--

declare

  -- Устанавливаемые значения параметров
  cursor dataCur is
    select
      -- значения для промышленной БД
      1 as prod_value_flag
      , '' as smtp_server
      , '' as username
      , '' as password
    from
      dual
    union all
    select
      -- значения для тестовой БД
      0 as prod_value_flag
      , '' as smtp_server
      , '' as username
      , '' as password
    from
      dual
  ;

  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName => pkg_MailBase.Module_Name
    , objectName => 'ModuleConfig/Mail/opt_option.sql'
  );

  opt opt_option_list_t := opt_option_list_t(
    findModuleString => pkg_MailBase.Module_SvnRoot
  );

begin
  for rec in dataCur loop
    -- Устанавливаем SMTP-сервер если он задан в курсоре и не задан в БД
    if rec.smtp_server is not null
      and opt.getString(
            optionShortName => pkg_MailBase.DefaultSmtpServer_OptSName
            , prodValueFlag => rec.prod_value_flag
          )
          is null
        then
      opt.setValue(
        optionShortName       => pkg_MailBase.DefaultSmtpServer_OptSName
        , prodValueFlag       => rec.prod_value_flag
        , stringValue         => rec.smtp_server
        , skipIfNoChangeFlag  => 1
      );
      opt.setValue(
        optionShortName       => pkg_MailBase.DefaultSmtpUsername_OptSName
        , prodValueFlag       => rec.prod_value_flag
        , stringValue         => rec.username
        , skipIfNoChangeFlag  => 1
      );
      opt.setValue(
        optionShortName       => pkg_MailBase.DefaultSmtpPassword_OptSName
        , prodValueFlag       => rec.prod_value_flag
        , stringValue         => rec.password
        , skipIfNoChangeFlag  => 1
      );
      logger.info(
        case rec.prod_value_flag
          when 1 then 'Промышленные'
          else 'Тестовые'
        end
        || ' параметры установлены (SMTP-сервер: ' || rec.smtp_server || ')'
      );
    end if;
  end loop;
  commit;
end;
/
