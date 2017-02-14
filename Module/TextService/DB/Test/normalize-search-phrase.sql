-- script: Test/normalize-search-phrase.sql
-- �������� ��� ������� <pkg_ContextSearchUtility::normalizeSearchPhrase>;
-- (code)
--
-- begin
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( '''test''', 'test');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( '"test"', 'test');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test,test2', 'test test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test-test2', 'test test2');
-- end;
--
-- (end)

begin
  pkg_TextUtilityTest.testNormalizeSearchPhrase( '''test''', 'test');
  pkg_TextUtilityTest.testNormalizeSearchPhrase( '"test"', 'test');
  pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test,test2', 'test test2');
  pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test-test2', 'test test2');
end;
/
