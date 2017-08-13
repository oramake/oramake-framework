-- script: Test/Data/opt_option.sql
-- ������� ��� ������ �������� ���������� ������������, ������������� �
-- <pkg_FileTest::��������� ������������>.
--
-- ���������:
-- - ��������������� �������� ������� �� ����������� ���������� SQL*Plus,
--   ������� ����� ���� ������ � ������� <SQL_DEFINE>.
--
-- ������������ ���������������.
@oms-default TestDirectoryPath ""

declare

  opt opt_plsql_object_option_t :=
    opt_plsql_object_option_t(
      moduleName    => pkg_File.Module_Name
    , objectName    => 'pkg_FileTest'
    )
  ;

  /*
    ��������� ��� ������������� �������� ���������.
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
    ��������� ��� ������������� �������� ���������.
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
    );
    if numberValue is not null then
      dbms_output.put_line(
        rpad( optionShortName, 30) || ' := ' || to_char( numberValue)
      );
    end if;
  end addNumber;

-- main
begin
  addString(
    optionShortName => pkg_FileTest.TestDirectoryPath_OptionSName
  , optionName      => '�����: ���������� ��� ������������'
  , stringValue     => '&TestDirectoryPath'
  );
  addString(
    optionShortName => pkg_FileTest.TestHttpBinaryUrl_OptionSName
  , optionName      => '�����: URL ��� �������� ��������� �����, ���������� �� HTTP'
  , stringValue     => coalesce( '&TestHttpBinaryUrl', 'http://yastatic.net/morda-logo/i/arrow2/logo_simple.svg')
  );
  addNumber(
    optionShortName => pkg_FileTest.TestHttpBinarySize_OptionSName
  , optionName      => '�����: ������ ��������� �����, ���������� �� HTTP'
  , numberValue     => coalesce( '&TestHttpBinarySize', 2240)
  );
  addString(
    optionShortName => pkg_FileTest.TestHttpTextUrl_OptionSName
  , optionName      => '�����: URL ��� �������� ���������� �����, ���������� �� HTTP'
  , stringValue     => coalesce( '&TestHttpTextUrl', 'http://ya.ru')
  );
  addString(
    optionShortName => pkg_FileTest.TestHttpTextPatter_OptionSName
  , optionName      => '�����: ������ � ��������� �����, ��������� �� HTTP'
  , stringValue     => coalesce( '&TestHttpTextPattern', '%�����%')
  );
  addString(
    optionShortName => pkg_FileTest.TestHttpAbsentFile_OptionSName
  , optionName      => '�����: ������������� ���� �� ��������� �����'
  , stringValue     => coalesce( '&TestHttpAbsentFile', 'http://intranet/jjj-not-exists.html')
  );
  addString(
    optionShortName => pkg_FileTest.testHttpAbsentHost_OptionSName
  , optionName      => '���� �� �������������� ����� ( � ���������)'
  , stringValue     => coalesce( '&TestHttpAbsentHost', 'http://badhost.intranet/region.png')
  );
end;
/
