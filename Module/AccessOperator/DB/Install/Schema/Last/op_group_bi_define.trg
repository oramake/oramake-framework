--trigger: OP_GROUP_BI_DEFINE
-- create trigger OP_GROUP_BI_DEFINE
CREATE OR REPLACE TRIGGER OP_GROUP_BI_DEFINE
 BEFORE INSERT
 ON OP_GROUP
 FOR EACH ROW
BEGIN
if :new.Operator_ID is null then        --Оператор, создавший строку.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --Определяем дату создания строки.
  :new.Date_Ins := SysDate;
end if;

if :new.Group_ID is null then           --Определяем значение первичного ключа.
  select op_Group_Seq.nextval into :new.Group_ID from dual;
end if;

END;--trigger;
/
