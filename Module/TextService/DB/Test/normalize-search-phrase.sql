-- script: Test/normalize-search-phrase.sql
-- �������� ��� ������� <pkg_ContextSearchUtility::normalizeSearchPhrase>;
-- (code)
--
-- begin
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( '''test''', 'test');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( '"test$,,,test2"', 'test$,,,test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test,,test2', 'test,test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test-test2', 'test test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test,##test2', 'test,test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase(
--      ', �����������, 7.7,'
--      , '�����������, 7 7'
--   );
--   pkg_TextUtilityTest.testNormalizeSearchPhrase(
--      '�������������(����������, ����)'
--      , '������������� ����������, ����'
--   );
--   pkg_TextUtilityTest.testNormalizeSearchPhrase(
--     '������ ������������ �� ����������! � 10:00'
--     , '������ ������������ �� ���������� � 10 00'
--   );
-- end;
--
-- (end)

begin
  pkg_TextUtilityTest.testNormalizeSearchPhrase( '''test''', 'test');
  pkg_TextUtilityTest.testNormalizeSearchPhrase( '"test$,,,test2"', 'test$,,,test2');
  pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test,,test2', 'test,test2');
  pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test-test2', 'test test2');
  pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test,##test2', 'test,test2');
  pkg_TextUtilityTest.testNormalizeSearchPhrase(
    ', �����������, 7.7,'
    , '�����������, 7 7'
  );
  pkg_TextUtilityTest.testNormalizeSearchPhrase(
    '�������������(����������, ����)'
    , '������������� ����������, ����'
  );
  pkg_TextUtilityTest.testNormalizeSearchPhrase(
    '������ ������������ �� ����������! � 10:00'
    , '������ ������������ �� ���������� � 10 00'
  );
  pkg_TextUtilityTest.testNormalizeSearchPhrase(
    '������, �������, ,��������'
    , '������,�������,��������'
  );
  pkg_TextUtilityTest.testNormalizeSearchPhrase(
    ',,, ������, ���������, ,    ,, �����,  ,,���������� �����'
    , '������,���������,�����,���������� �����'
  );
end;
/

