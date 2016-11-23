--trigger: OP_ROLE_AI_GRANT_TO_ADMIN
-- create trigger OP_ROLE_AI_GRANT_TO_ADMIN
CREATE OR REPLACE TRIGGER OP_ROLE_AI_GRANT_TO_ADMIN
 AFTER INSERT
 ON OP_ROLE
 FOR EACH ROW
--Выдает роль группе полного доступа.
begin
  pkg_OperatorInternal.GrantRoleToAdmin(
    roleID => :new.role_id
    , operatorID => :new.operator_id
  );
end; --trigger
/
