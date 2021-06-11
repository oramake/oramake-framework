-- script: Test/test-converrsion.sql
-- Тест конвертации BLOB в CLOB, и обратно.
--
begin
  pkg_TextCreateTest.testConversion( 'Конвертация в clob');
end;
/
