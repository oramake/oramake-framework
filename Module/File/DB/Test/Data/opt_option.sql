-- script: Test/Data/opt_option.sql
-- Создает или меняет значения параметров тестирования, перечисленных в
-- <pkg_FileTest::Параметры тестирования>.
--
-- Замечания:
-- - устанавливаемые значения берутся из одноименных переменных SQL*Plus,
--   которые могут быть заданы с помощью <SQL_DEFINE>.
--
-- Используемые макропеременные.
@oms-default TestDirectoryPath ""

declare

  opt opt_plsql_object_option_t :=
    opt_plsql_object_option_t(
      moduleName    => pkg_File.Module_Name
    , objectName    => 'pkg_FileTest'
    )
  ;

  /*
    Добавляет или устанавливает значение параметра.
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
    Добавляет или устанавливает значение параметра.
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
  , optionName      => 'Тесты: Директория для тестирования'
  , stringValue     => '&TestDirectoryPath'
  );
  addString(
    optionShortName => pkg_FileTest.TestHttpBinaryUrl_OptionSName
  , optionName      => 'Тесты: URL для загрузки бинарного файла, доступного по HTTP'
  , stringValue     => coalesce( '&TestHttpBinaryUrl', 'http://yastatic.net/morda-logo/i/arrow2/logo_simple.svg')
  );
  addNumber(
    optionShortName => pkg_FileTest.TestHttpBinarySize_OptionSName
  , optionName      => 'Тесты: размер бинарного файла, доступного по HTTP'
  , numberValue     => coalesce( '&TestHttpBinarySize', 2240)
  );
  addString(
    optionShortName => pkg_FileTest.TestHttpTextUrl_OptionSName
  , optionName      => 'Тесты: URL для загрузки текстового файла, доступного по HTTP'
  , stringValue     => coalesce( '&TestHttpTextUrl', 'http://ya.ru')
  );
  addString(
    optionShortName => pkg_FileTest.TestHttpTextPatter_OptionSName
  , optionName      => 'Тесты: шаблон в текстовом файле, доступном по HTTP'
  , stringValue     => coalesce( '&TestHttpTextPattern', '%Найти%')
  );
  addString(
    optionShortName => pkg_FileTest.TestHttpAbsentFile_OptionSName
  , optionName      => 'Тесты: отсутствующий файл на доступном хосте'
  , stringValue     => coalesce( '&TestHttpAbsentFile', 'http://intranet/jjj-not-exists.html')
  );
  addString(
    optionShortName => pkg_FileTest.testHttpAbsentHost_OptionSName
  , optionName      => 'Файл на несуществующем хосте ( в интранете)'
  , stringValue     => coalesce( '&TestHttpAbsentHost', 'http://badhost.intranet/region.png')
  );
end;
/
