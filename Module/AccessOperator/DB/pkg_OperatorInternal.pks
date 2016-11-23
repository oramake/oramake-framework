create or replace package pkg_OperatorInternal is
/* package: pkg_OperatorInternal
  ���������� ����� ������ Operator.

  SVN root: RusFinanceInfo/Module/AccessOperator
*/

/* const: FullAccess_GroupID
  ID ������ "������ ������"
*/
FullAccess_GroupID constant integer := 1;

/* pproc: GrantRoleToAdmin
  ������ ���� ������ ������� �������
  ( <body::GrantRoleToAdmin>).
*/
procedure GrantRoleToAdmin(
  roleId integer
  , operatorId integer
);

end pkg_OperatorInternal;
/