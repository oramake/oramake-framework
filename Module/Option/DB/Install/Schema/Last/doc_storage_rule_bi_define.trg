create or replace trigger doc_storage_rule_bi_define
 before insert
 on doc_storage_rule
 for each row
begin
                                        
if :new.Storage_Rule_ID is null then    --Определяем значение первичного ключа.
  select Doc_Storage_Rule_Seq.nextval into :new.Storage_Rule_ID from dual;
end if;

if :new.Operator_ID is null then        --Оператор, создавший строку.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --Определяем дату создания строки.
  :new.Date_Ins := SysDate;
end if;
      
end;--trigger;
/
