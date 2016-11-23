--trigger: OP_OPERATOR_BU_DEFINE
-- create trigger OP_OPERATOR_BU_DEFINE
CREATE OR REPLACE TRIGGER OP_OPERATOR_BU_DEFINE
 BEFORE
 UPDATE
 ON OP_OPERATOR
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
BEGIN
if :new.password<>:old.password then
  insert into op_password_hist (operator_id, password)
  values (:new.OPERATOR_ID, :old.PASSWORD);
end if;

END;
/
