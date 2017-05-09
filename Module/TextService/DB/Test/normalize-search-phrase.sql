-- script: Test/normalize-search-phrase.sql
-- јвтотест дл€ функции <pkg_ContextSearchUtility::normalizeSearchPhrase>;
-- (code)
--
-- begin
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( '''test''', 'test');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( '"test$,,,test2"', 'test$,,,test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test,,test2', 'test,test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test-test2', 'test test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase( 'test,##test2', 'test,test2');
--   pkg_TextUtilityTest.testNormalizeSearchPhrase(
--      ', Ѕухгалтери€, 7.7,'
--      , 'Ѕухгалтери€, 7 7'
--   );
--   pkg_TextUtilityTest.testNormalizeSearchPhrase(
--      'коплектовщики(ежедневные, мозг)'
--      , 'коплектовщики ежедневные, мозг'
--   );
--   pkg_TextUtilityTest.testNormalizeSearchPhrase(
--     'ударим автопробегом по бездорожью! в 10:00'
--     , 'ударим автопробегом по бездорожью в 10 00'
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
    ', Ѕухгалтери€, 7.7,'
    , 'Ѕухгалтери€, 7 7'
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
    ',,, москва, чел€бинск, ,    ,, муром,  ,,набережные челны'
    , 'москва,чел€бинск,муром,набережные челны'
  );
end;
/

