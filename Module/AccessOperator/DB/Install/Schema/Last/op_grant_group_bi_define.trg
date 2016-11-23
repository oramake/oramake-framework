--trigger: OP_GRANT_GROUP_BI_DEFINE
-- create trigger OP_GRANT_GROUP_BI_DEFINE
CREATE OR REPLACE TRIGGER OP_GRANT_GROUP_BI_DEFINE
 BEFORE INSERT
 ON OP_GRANT_GROUP
 FOR EACH ROW
BEGIN
                                        --Оператор, создавший строку
if :new.Operator_ID is null then
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;
                                        --Определяем дату создания строки
if :new.Date_Ins is null then
  :new.Date_Ins := SysDate;
end if;
                                        --Определяем значение флага
if :new.check_is_grant_only is null then
  :new.check_is_grant_only := 1;
end if;

END;--trigger;
/
