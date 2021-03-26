-- ModuleConfig/Mail/opt_option.sql
-- ������������� �������� ����������� ���������� ������ Mail.
--

declare

  opt opt_option_list_t := opt_option_list_t(
    findModuleString => pkg_MailBase.Module_SvnRoot
  );

begin

  -- ������������� SMTP-������ ���� �� �� �����
  if opt.getString( optionShortName => pkg_MailBase.DefaultSmtpServer_OptSName)
        is null
      then
    -- SMTP-������ ��� ����. ��
    opt.setValue(
      optionShortName       => pkg_MailBase.DefaultSmtpServer_OptSName
      , prodValueFlag       => 1
      , stringValue         => ''
      , skipIfNoChangeFlag  => 1
    );
    -- SMTP-������ ��� �������� ��
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
