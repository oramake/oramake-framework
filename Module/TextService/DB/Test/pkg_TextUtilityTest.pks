create or replace package pkg_TextUtilityTest is
/* package: pkg_TextUtilityTest
  ����� ������������������� ������������ ������ pkg_TextUtility ������ TextService.

  SVN root: Oracle/Module/TextService
*/



/* group: ������� */



/* group: Unit-����� ������� */

/* pproc: testLevenshteinDistance
   ��������� �������� ���������� ���������� �������������� (��������� �����������).


  ( <body::testLevenshteinDistance>)
*/
procedure testLevenshteinDistance;

/* pproc: testNormalizeWordList
  �������� ������ ������� ������������ ������ �����.

  ���������:
  sourceString                - �������� ������
  expectedString              - ��������� ������
  addonDelimiterList         - ������ ������������ ( ��-��������� ������ ������)

  ( <body::testNormalizeWordList>)
*/
procedure testNormalizeWordList(
  sourceString varchar2
  , expectedString varchar2
  , addonDelimiterList varchar2 := null
);

/* pfunc: normalizeAndLevenstein
  ���������� ������� ����������� ��� ���������������� �������� ����.

  ���������:
  source                      - �������� ������
  target                      - ������, ������� ���������� ��������

  ���������:
  - ������������ ������������� ����������� "/-,";

  ( <body::normalizeAndLevenstein>)
*/
function normalizeAndLevenstein(
  source varchar2
  , target varchar2
)
return integer;

/* pfunc: wordListCloseness
  ���������� �������� ����� �������� ���� ( ��� ������ �������� �������,
  ��� ������ �������� - �������� �� 0 �� 1).

  ���������:
  wordList1                   - ����� ���� 1
  wordList2                   - ����� ���� 2
  addonDelimiterList          - ������ �������������� ������������ (
                                ��-��������� ������ ������)

  ����������:
  - ������� ����������� �������� ������ � ��������� �� �� �����, ����� �����
    ���������� ������ ���� ���� �������� ����������� � ������ ���������� ����
    � ������ � � ������ ���������� ����� � ������ ( ����� ������� � �����
    ����� ����� ������� ���);

  ( <body::wordListCloseness>)
*/
function wordListCloseness(
  wordList1 varchar2
  , wordList2 varchar2
  , addonDelimiterList varchar2 := null
)
return number;

/* pproc: testWordListCloseness
  ������������ ������� �������� ���� ������� ����.

  ���������:
  wordList1                   - ����� ���� 1
  wordList2                   - ����� ���� 2
  expectedCloseness           - ��������� �������� ��������

  ( <body::testWordListCloseness>)
*/
procedure testWordListCloseness(
  wordList1 varchar2
  , wordList2 varchar2
  , expectedCloseness number
);



/* group: ������� ��� ������ � ���������� ������� */

/* pproc: testNormalizeSearchPhrase
  ������������ ������������ ������� ������������ ������.

  ���������:
  searchPhrase                - �������� ������
  expectedPhrase              - ��������� ������

  ( <body::testNormalizeSearchPhrase>)
*/
procedure testNormalizeSearchPhrase(
  searchPhrase varchar2
, expectedPhrase varchar2
);

end pkg_TextUtilityTest;
/
