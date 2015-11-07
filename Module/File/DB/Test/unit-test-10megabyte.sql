-- script: Test/unit-test-10megabyte.sql
-- Тестирование работы модуля file с файлов размером 10 млн. байт.
begin
  pkg_FileTest.unitTest( fileSize => 10000000);
end;
/
