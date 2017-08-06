-- script: Test/Data/opt_option.sql
-- —оздает или мен€ет значени€ параметров тестировани€, перечисленных в
-- <pkg_FileTest::ѕараметры тестировани€>.
--
-- «амечани€:
-- - устанавливаемые значени€ берутс€ из одноименных переменных SQL*Plus,
--   которые могут быть заданы с помощью <SQL_DEFINE>.
--
-- »спользуемые макропеременные.
@oms-default TestDirectoryPath ""

declare

  opt opt_plsql_object_option_t :=
    opt_plsql_object_option_t(
      moduleName    => pkg_File.Module_Name
    , objectName    => 'pkg_FileTest'
    )
  ;

  /*
    ƒобавл€ет или устанавливает значение параметра.
  */
  procedure addString(
    optionShortName varchar2
    , optionName varchar2
    , encryptionFlag integer := null
    , stringValue varchar2
  )
  is
  begin
    opt.addString(
      optionShortName   => optionShortName
      , optionName      => optionName
      , encryptionFlag  => encryptionFlag
      , stringValue     => stringValue
      , changeValueFlag =>
          case when stringValue is not null then 1 end
    );
    if stringValue is not null then
      dbms_output.put_line(
        rpad( optionShortName, 30) || ' := "' || stringValue || '"'
      );
    end if;
  end addString;

-- main
begin
  addString(
    optionShortName => pkg_FileTest.TestDirectoryPath_OptionSName
  , optionName      => '“есты: ƒиректори€ дл€ тестировани€'
  , stringValue     => '&TestDirectoryPath'
  );
end;
/
