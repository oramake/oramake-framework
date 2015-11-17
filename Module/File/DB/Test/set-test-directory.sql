-- script: Test/set-test-directory.sql
-- Устанавливает директорию для тестирования файлов.
--
-- Например, можно установить директорию для ftp и прогнать
-- unit-test_megabyte.sql;
--
begin
  pkg_FileTest.setTestDirectory( '&1');
end;
/

