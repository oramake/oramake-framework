-- script: Test/test-unit.sql
-- ��������� unit-������������ �������.

begin
  pkg_TextUtilityTest.testLevenshteinDistance();
  rollback;
end;
/
