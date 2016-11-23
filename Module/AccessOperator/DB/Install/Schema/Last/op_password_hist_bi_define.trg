--trigger: OP_PASSWORD_HIST_BI_DEFINE
-- create trigger OP_PASSWORD_HIST_BI_DEFINE
CREATE OR REPLACE TRIGGER OP_PASSWORD_HIST_BI_DEFINE
 BEFORE
 INSERT
 ON OP_PASSWORD_HIST
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
begin
if :new.password_history_ID is null then         --Определяем значение первичного ключа.
  select op_password_hist_Seq.nextval into :new.password_history_ID from dual;
end if;

if :new.Operator_ID_ins is null then        --Оператор, создавший строку.
  :new.Operator_ID_ins := 1;--pkg_Operator.GetCurrentUserID;
end if;
end;
/
