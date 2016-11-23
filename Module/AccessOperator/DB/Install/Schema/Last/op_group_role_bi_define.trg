--trigger: OP_GROUP_ROLE_BI_DEFINE
-- create trigger OP_GROUP_ROLE_BI_DEFINE
CREATE OR REPLACE TRIGGER OP_GROUP_ROLE_BI_DEFINE

 BEFORE INSERT
 ON OP_GROUP_ROLE
 FOR EACH ROW
BEGIN
if :new.Operator_ID is null then        --Оператор, создавший строку.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --Определяем дату создания строки.
  :new.Date_Ins := SysDate;
end if;

END;--trigger;
/
