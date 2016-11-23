create or replace package body pkg_OperatorInternal is
/* package body: pkg_OperatorInternal::body */

/* proc: GrantRoleToAdmin
  Выдает роль группе полного доступа.

  Параметры:
  roleID                      - ID роли
  operatorID                  - ID оператора, выполняющего процедуру
*/
procedure GrantRoleToAdmin(
  roleId integer
  , operatorId integer
)
is

--GrantRoleToAdmin
begin
  insert into
    op_group_role
  (
    group_id
    , role_id
    , operator_id
  )
  values
  (
    FullAccess_GroupID
    , roleID
    , operatorID
  );
end GrantRoleToAdmin;

end pkg_OperatorInternal;
/