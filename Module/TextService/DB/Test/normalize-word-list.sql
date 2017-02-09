declare
  addonDelimiterList varchar2(100) := '/-,';
begin
  pkg_TextUtilityTest.testNormalizeWordList(
    sourceString => '/ ������ / ����������-����������� ������ / ������'
    , expectedString => '������ ���������� ����������� ������'
    , addonDelimiterList => addonDelimiterList
  );
  pkg_TextUtilityTest.testNormalizeWordList(
    sourceString => '/ ������� / ������� / ������������'
    , expectedString => '������� ������������ �������'
    , addonDelimiterList => addonDelimiterList
  );
  pkg_TextUtilityTest.testNormalizeWordList(
    sourceString => '������, ��������� / ����������, ������������ ������'
    , expectedString => '������ ��������� ������������ ���������� ������'
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
