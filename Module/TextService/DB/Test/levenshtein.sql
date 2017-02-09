-- script: Test/test-unit.sql
-- Выполняет unit-тестирование методов.

begin
  pkg_TextUtilityTest.testLevenshteinDistance();
  rollback;
end;
/
