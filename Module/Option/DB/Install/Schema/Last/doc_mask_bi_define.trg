create or replace trigger doc_mask_bi_define
 before insert
 on doc_mask
 for each row
begin
                                        
if :new.Mask_ID is null then            --Определяем значение первичного ключа.
  select Doc_Mask_Seq.nextval into :new.Mask_ID from dual;
end if;

if :new.Operator_ID is null then        --Оператор, создавший строку.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --Определяем дату создания строки.
  :new.Date_Ins := SysDate;
end if;
      
end;--trigger;
/
