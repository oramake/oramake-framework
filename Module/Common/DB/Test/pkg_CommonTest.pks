create or replace package pkg_CommonTest is
/* package: pkg_CommonTest
  �������� ����� ��� ������������ ������.

  SVN root: Oracle/Module/Common
*/



/* group: ������� */

/* pproc: testNumberToWord
  ������������ ������� <pkg_Common::numberToWord>;

  ���������:
  sourceNumber                - �������� �����
  expectedString              - ��������� ������

  ( <body::testNumberToWord>)
*/
procedure testNumberToWord(
  sourceNumber number
  , expectedString varchar2
);

end pkg_CommonTest;
/
