-- script: Test/unit-test-megabyte.sql
-- Тестирование работы модуля file с файлов размером 1 млн байт.
begin
  pkg_FileTest.unitTest( fileSize => 1000000);
end;
/
