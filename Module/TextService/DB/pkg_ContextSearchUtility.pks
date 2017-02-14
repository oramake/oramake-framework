create or replace package pkg_ContextSearchUtility is
/* package: pkg_ContextSearchUtility
  �����, ���������� ������� �� ������ � ����������� �������.

  SVN root: Oracle/Module/TextService
*/



/* group: ������� */

/* pfunc: normalizeSearchPhrase
  ������������ ������ ������������ ������.

  ���������:
  searchPhrase                - ������ ������������ ������

  �������:
  - ��������������� ������;

  ����������:
  - ���� ������ ��������� � ������� ( ��������� ��� �������), ��
    ������� � ������ � � ����� ��������� � ������������ ���������� ������
    ��� ����;
  - ����� ��� ����������� ������� ( ��� �������, ����� �������, �������, ����
    � ����) ���������� �� �������; ��������� ������� ������ ��� ���������
    �������� ������ ���������� �� ��������������� ���� ������;

  ���������:
  - �������� � ������� ���������� � �������
    <Test/normalize-search-phrase.sql>;

  ( <body::normalizeSearchPhrase>)
*/
function normalizeSearchPhrase(
  searchPhrase varchar2
)
return varchar2;

end pkg_ContextSearchUtility;
/
