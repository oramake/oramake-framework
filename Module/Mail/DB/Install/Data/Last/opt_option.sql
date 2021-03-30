declare

  opt opt_option_list_t := opt_option_list_t(
    findModuleString => pkg_MailBase.Module_SvnRoot
  );

begin
  opt.addString(
    optionShortName       => pkg_MailBase.DefaultMailSender_OptSName
    , optionName          =>
        '����� ����������� �� ��������� ��� �������� ���������'
    , optionDescription   =>
'� �������� ����� ������������ �������:
$(instanceName) - ��� �������� ��
$(systemName)   - ��� �������, ������������ ��������� (�������� systemName ������� pkg_Mail.getMailSender)

������: "$(systemName).$(instanceName).oracle <user@example.com>"

���� �������� �� ������, �� ������������ ��������, ������������ �������� pkg_Common.getMailAddressSource ������ Common.'
    , prodStringValue     => ''
    , testStringValue     => ''
  );
  opt.addString(
    optionShortName       => pkg_MailBase.DefaultSmtpServer_OptSName
    , optionName          =>
        'SMTP-������ �� ��������� ��� �������� �����'
    , optionDescription   =>
'���� �� �����, �� ������������ SMTP-������, ������������ �������� pkg_Common.getSmtpServer ������ Common.'
    , prodStringValue     => ''
    , testStringValue     => ''
  );
  opt.addString(
    optionShortName       => pkg_MailBase.DefaultSmtpUsername_OptSName
    , optionName          =>
        '��� ������������ ��� ����������� �� SMTP-������� �� ���������'
    , prodStringValue     => ''
    , testStringValue     => ''
  );
  opt.addString(
    optionShortName       => pkg_MailBase.DefaultSmtpPassword_OptSName
    , optionName          =>
        '������ ��� ����������� �� SMTP-������� �� ���������'
    , prodStringValue     => ''
    , testStringValue     => ''
    , encryptionFlag      => 1
  );
  commit;
end;
/
