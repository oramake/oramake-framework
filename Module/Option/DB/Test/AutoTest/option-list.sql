set feedback off

begin
  pkg_OptionTest.testOptionList();
exception when others then
  -- выводим полный текст ошибки
  pkg_Common.outputMessage( pkg_Logging.getErrorStack());
  raise_application_error(
    pkg_Error.ProcessError
    , 'Ошибка при выполнении теста.'
  );
end;
/

set feedback on
