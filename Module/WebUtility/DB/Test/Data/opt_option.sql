-- script: Test/Data/opt_option.sql
-- Creates or changes the values of the test parameters listed in
-- <pkg_WebUtilityTest::Test parameters>.
--
-- Remarks:
-- - values to be set are taken from SQL*Plus substitution variables of the
--  same name which can be specified using <SQL_DEFINE>;
--

@oms-default TestHttpAbsentHost ""
@oms-default TestHttpAbsentPath ""
@oms-default TestHttpTextUrl ""
@oms-default TestHttpTextPattern ""

declare

  opt opt_plsql_object_option_t :=
    opt_plsql_object_option_t(
      moduleName      => pkg_WebUtility.Module_Name
      , objectName    => 'pkg_WebUtilityTest'
    )
  ;



  /*
    Adds or sets the string value of a parameter.
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



  /*
    Adds or sets the string value of a parameter.
  */
  procedure addNumber(
    optionShortName varchar2
    , optionName varchar2
    , numberValue number
  )
  is
  begin
    opt.addNumber(
      optionShortName   => optionShortName
      , optionName      => optionName
      , numberValue     => numberValue
      , changeValueFlag =>
          case when numberValue is not null then 1 end
    );
    if numberValue is not null then
      dbms_output.put_line(
        rpad( optionShortName, 30) || ' := ' || numberValue
      );
    end if;
  end addNumber;



-- main
begin
  addString(
    optionShortName   => pkg_WebUtilityTest.TestHttpAbsentHost_OptSName
    , optionName      =>
        'Tests: URL of non-existent accessible host'
    , stringValue     => '&TestHttpAbsentHost'
  );
  addString(
    optionShortName   => pkg_WebUtilityTest.TestHttpAbsentPath_OptSName
    , optionName      =>
        'Tests: URL with non-existent path on accessible host'
    , stringValue     => '&TestHttpAbsentPath'
  );
  addString(
    optionShortName   => pkg_WebUtilityTest.TestHttpTextUrl_OptSName
    , optionName      =>
        'Tests: URL for downloading text data available via HTT'
    , stringValue     => '&TestHttpTextUrl'
  );
  addString(
    optionShortName   => pkg_WebUtilityTest.TestHttpTextPattern_OptSName
    , optionName      =>
        'Tests: Pattern (SQL like) for text data downloaded by URL specified in TestHttpTextUrl parameter'
    , stringValue     => '&TestHttpTextPattern'
  );

  commit;
end;
/
