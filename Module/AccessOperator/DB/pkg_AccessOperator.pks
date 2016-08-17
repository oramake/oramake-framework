create or replace package pkg_AccessOperator is
/* package: pkg_AccessOperator
  ����� ��� ��������� ������ ������.

  SVN root: Oracle/Module/AccessOperator
*/



/* group: ������� */

/* pfunc: mergeRole
  ���������� ��� ���������� ����.

  ���������:
  roleShortName               - �������� ������������ ����
  roleName                    - ������������ ����
  roleNameEn                  - ������������ ���� �� ����������
  description                 - �������� ����

  �������:
  - ���� �� ���� �������� ( ��������� ��� ���������);

  ( <body::mergeRole>)
*/
function mergeRole(
  roleShortName varchar2
  , roleName varchar2
  , roleNameEn varchar2
  , description varchar2
)
return integer;

end pkg_AccessOperator;
/
