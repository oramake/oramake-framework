@oms-default traceCopyPath "\\test"

declare

  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_ProcessMonitorBase.Module_Name
  );

begin
  optionList.addString(
    optionShortName => pkg_ProcessMonitorBase.TraceCopyPath_OptionName
    , optionName => '���������� ��� ����������� ������ ����������� ��-���������'
    , stringValue => '&traceCopyPath'
  );
end;
/
commit;

