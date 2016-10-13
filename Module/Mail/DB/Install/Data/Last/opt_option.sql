declare

  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_Mail.Module_Name
  );

begin
  optionList.addString(
    optionShortName => pkg_MailInternal.MassDistributeSmtp_OptionName
    , optionName => 'Имя или ip smtp-сервера для массовых рассылок'
    , testStringValue => '&massDistributionSmtp'
    , prodStringValue => '&massDistributionSmtp'
  );
  optionList.addString(
    optionShortName => pkg_MailInternal.FaxSenderSmtp_OptionName
    , optionName => 'Имя или ip smtp-сервера для отправки факсов'
    , testStringValue => '&faxSenderSmtp'
    , prodStringValue => '&faxSenderSmtp'
  );
end;
/

commit
/

