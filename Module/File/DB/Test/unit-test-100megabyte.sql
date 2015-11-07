-- script: Test/unit-test-100megabyte.sql
-- Тестирование работы модуля file с файлов размером 100 млн. байт.
begin
  pkg_FileTest.unitTest( fileSize => 100000000);
end;
/
