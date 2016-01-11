declare

  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_Mail.Module_Name
  );

begin
  optionList.addOptionString(
    moduleOptionName => pkg_MailInternal.MassDistributeSmtp_OptionName
    , optionName => '��� ��� ip smtp-������� ��� �������� ��������'
    , defaultStringValue => '&massDistributionSmtp'
  );
  optionList.addOptionString(
    moduleOptionName => pkg_MailInternal.FaxSenderSmtp_OptionName
    , optionName => '��� ��� ip smtp-������� ��� �������� ������'
    , defaultStringValue => '&faxSenderSmtp'
  );
  optionList.addOptionString(
    moduleOptionName => pkg_MailInternal.DebtInfoSmtp_OptionName
    , optionName => '��� ��� ip smtp-������� ��� �������� ���������� � �������������'
    , defaultStringValue => 'mail.prosrochka-info.ru'
  );
end;
/
commit;

