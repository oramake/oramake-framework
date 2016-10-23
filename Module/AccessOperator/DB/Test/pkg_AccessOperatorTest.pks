create or replace package pkg_AccessOperatorTest is
/* package: pkg_AccessOperatorTest
  �������� ����� ������.

  SVN root: Oracle/Module/AccessOperator
*/

/* const: TestOperator_LoginPrefix
  ������� ������� �������� ����������, ����������� �������� <getTestOperatorId>.
*/
TestOperator_LoginPrefix constant varchar2(50) := 'TestOp-';



/* group: ������� */

/* pfunc: getTestOperatorId
  ���������� Id ��������� ���������.
  ���� ��������� ��������� �� ����������, �� ���������, ���� ����������, ��
  �������� ��� ���� �������������� �������� ������ ( ���� �� ������).

  ���������:
  login                       - ����� ��������� ( ��� ������� ������������
                                � �������� ������)
  baseName                    - ���������� ������� ��� ���������
                                ( ������������ ��� ������������ ������,
                                  �� �������� ����� ����������� �������
                                  ���������). ����� ���� ����� ����
                                login ���� baseName.
  roleSNameList               - ������ ������� ������������ �����, �������
                                ������ ���� ������ ���������
                                ( �� ��������� ���� �� �����������)

  �������:
  Id ���������

  ( <body::getTestOperatorId>)
*/
function getTestOperatorId(
  baseName        varchar2           := null
  , login         varchar2           := null
  , roleSNameList cmn_string_table_t := null
)
return integer;

end pkg_AccessOperatorTest;
/
