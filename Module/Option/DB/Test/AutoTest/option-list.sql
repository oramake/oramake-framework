set feedback off

begin
  pkg_OptionTest.testOptionList();
exception when others then
  -- ������� ������ ����� ������
  pkg_Common.outputMessage( pkg_Logging.getErrorStack());
  raise_application_error(
    pkg_Error.ProcessError
    , '������ ��� ���������� �����.'
  );
end;
/

set feedback on
