create or replace package pkg_TextUtility is
/* package: pkg_TextUtility
  ������������ ����� ����������� TextUtility.

  SVN root: Oracle/Module/TextService
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'TextService';



/* group: ������� */



/* group: ��������� ����� */

/* pfunc: levenshteinDistance
  ���������� ���������� �������������� (��������� �����������).

  ���������:
    source                            - �������� ������
    target                            - ������, ������� ���������� ��������

  ������������ �������� ��������:
    - ���������� �������������� (��������� �����������)


  ( <body::levenshteinDistance>)
*/
function levenshteinDistance(
  source varchar2
  , target varchar2
)
return integer;

/* pproc: normalizeWordList
  ������������ ������ ��� ������ ����.

  ���������:
  sourceString                - �������� ������
  addonDelimiterList          - ������ �������������� ������������ (
                                ��-��������� ������ ������)

  �������� ��� �������� �������:
  - ������ ��������� �������� ������������ �� �������;
  - ���������� � ������� ��������;
  - ������ ������������� �������� �� ���� ������;
  - ����������������� ���������� ����;
  - �������� ������������� ����;

  ( <body::normalizeWordList>)
*/
function normalizeWordList(
  sourceString varchar2
  , addonDelimiterList varchar2 := null
)
return varchar2;

/* pfunc: wordListCloseness
  ���������� �������� ����� �������� ���� ( ��� ������ �������� �������,
  ��� ������ �������� - �������� �� 0 �� 1).

  ���������:
  wordList1                   - ����� ���� 1
  wordList2                   - ����� ���� 2
  addonDelimiterList          - ������ �������������� ������������ (
                                ��-��������� ������ ������)

  ( <body::wordListCloseness>)
*/
function wordListCloseness(
  wordList1 varchar2
  , wordList2 varchar2
  , addonDelimiterList varchar2 := null
)
return number;

end pkg_TextUtility;
/
