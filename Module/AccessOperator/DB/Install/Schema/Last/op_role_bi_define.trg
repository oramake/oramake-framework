--trigger: OP_ROLE_BI_DEFINE
-- create trigger OP_ROLE_BI_DEFINE
CREATE OR REPLACE TRIGGER OP_ROLE_BI_DEFINE
 BEFORE INSERT
 ON OP_ROLE
 FOR EACH ROW
BEGIN

 if :new.ROLE_ID is null
  then
 
    select op_role_seq.nextval
     into :new.ROLE_ID
    from dual;

  end if;

if :new.Operator_ID is null then        --Оператор, создавший строку.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --Определяем дату создания строки.
  :new.Date_Ins := SysDate;
end if;

END;--trigger;
/
