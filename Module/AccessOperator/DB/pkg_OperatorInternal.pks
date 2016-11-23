create or replace package pkg_OperatorInternal is
/* package: pkg_OperatorInternal
  Внутренний пакет модуля Operator.

  SVN root: RusFinanceInfo/Module/AccessOperator
*/

/* const: FullAccess_GroupID
  ID группы "Полный доступ"
*/
FullAccess_GroupID constant integer := 1;

/* pproc: GrantRoleToAdmin
  Выдает роль группе полного доступа
  ( <body::GrantRoleToAdmin>).
*/
procedure GrantRoleToAdmin(
  roleId integer
  , operatorId integer
);

end pkg_OperatorInternal;
/