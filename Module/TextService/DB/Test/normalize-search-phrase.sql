-- script: Test/normalize-search-phrase.sql
-- Автотест для функции <pkg_ContextSearchUtility::normalizeSearchPhrase>;
-- (code)
--
-- begin
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( '''test''', 'test');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( '"test$,,,test2"', 'test$,,,test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test,,test2', 'test,test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test-test2', 'test test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test,##test2', 'test,test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase(
--      ', Бухгалтерия, 7.7,'
--      , 'Бухгалтерия, 7 7'
--   );
--   pkg_TextUtilityTest.testNormalizeSearchPhrase(
--      'коплектовщики(ежедневные, мозг)'
--      , 'коплектовщики ежедневные, мозг'
--   );
--   pkg_TextUtilityTest.testNormalizeSearchPhrase(
--     'ударим автопробегом по бездорожью! в 10:00'
--     , 'ударим автопробегом по бездорожью в 10 00'
--   );
--  pkg_TextUtilityTest.testNormalizeSearchPhrase(
--   'ректор, студент, ,аспирант'
--    , 'ректор,студент,аспирант'
--  );
--  pkg_TextUtilityTest.testNormalizeSearchPhrase(
--    ',,, москва, челябинск, ,    ,, муром,  ,,набережные  челны'
--    , 'москва,челябинск,муром,набережные челны'
--  );
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
    ', Бухгалтерия, 7.7,'
    , 'Бухгалтерия, 7 7'
  );
  pkg_TextUtilityTest.testNormalizeSearchPhrase(
    'коплектовщики(ежедневные, мозг)'
    , 'коплектовщики ежедневные, мозг'
  );
  pkg_TextUtilityTest.testNormalizeSearchPhrase(
    'ударим автопробегом по бездорожью! в 10:00'
    , 'ударим автопробегом по бездорожью в 10 00'
  );
  pkg_TextUtilityTest.testNormalizeSearchPhrase(
    'ректор, студент, ,аспирант'
    , 'ректор,студент,аспирант'
  );
  pkg_TextUtilityTest.testNormalizeSearchPhrase(
    ',,, Москва, Челябинск, ,    ,, Муром,  ,,Набережные  Челны'
    , 'Москва,Челябинск,Муром,Набережные Челны'
  );
end;
/

