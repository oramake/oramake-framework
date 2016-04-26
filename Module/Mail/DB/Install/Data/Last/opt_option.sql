declare

  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_Mail.Module_Name
  );

begin
  optionList.addOptionString(
    moduleOptionName => pkg_MailInternal.MassDistributeSmtp_OptionName
    , optionName => 'Имя или ip smtp-сервера для массовых рассылок'
    , defaultStringValue => '&massDistributionSmtp'
  );
  optionList.addOptionString(
    moduleOptionName => pkg_MailInternal.FaxSenderSmtp_OptionName
    , optionName => 'Имя или ip smtp-сервера для отправки факсов'
    , defaultStringValue => '&faxSenderSmtp'
  );
end;
/
commit;

