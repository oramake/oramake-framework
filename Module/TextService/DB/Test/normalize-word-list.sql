declare
  addonDelimiterList varchar2(100) := '/-,';
begin
  pkg_TextUtilityTest.testNormalizeWordList(
    sourceString => '/ Туризм / Гостинично-ресторанный бизнес / Туризм'
    , expectedString => 'бизнес гостинично ресторанный туризм'
    , addonDelimiterList => addonDelimiterList
  );
  pkg_TextUtilityTest.testNormalizeWordList(
    sourceString => '/ Продажи / Закупки / Оборудование'
    , expectedString => 'закупки оборудование продажи'
    , addonDelimiterList => addonDelimiterList
  );
  pkg_TextUtilityTest.testNormalizeWordList(
    sourceString => 'Туризм, гостиницы / Размещение, обслуживание гостей'
    , expectedString => 'гостей гостиницы обслуживание размещение туризм'
    , addonDelimiterList => addonDelimiterList
  );
  pkg_TextUtilityTest.testNormalizeWordList(
    sourceString => ''
    , expectedString => ''
    , addonDelimiterList => addonDelimiterList
  );
  pkg_TextUtilityTest.testNormalizeWordList(
    sourceString => 'A'
    , expectedString => 'a'
    , addonDelimiterList => addonDelimiterList
  );
end;
/
