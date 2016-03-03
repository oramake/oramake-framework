create or replace trigger opt_option_bi_define
 before insert
 on opt_option
 for each row
begin
if :new.Option_ID is null then          --Определяем значение первичного ключа.
  select opt_Option_Seq.nextval into :new.Option_ID from dual;
end if;

if :new.Operator_ID is null then        --Оператор, создавший строку.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --Определяем дату создания строки.
  :new.Date_Ins := SysDate;
end if;
  
end;--trigger;
/
