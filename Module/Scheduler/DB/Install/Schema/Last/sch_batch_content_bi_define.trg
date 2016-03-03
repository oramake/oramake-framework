create or replace trigger sch_batch_content_bi_define
 before insert
 on sch_batch_content
 for each row
begin

if :new.Batch_Content_ID is null then   --Определяем значение первичного ключа.
  select SCH_Batch_Content_Seq.nextval into :new.Batch_Content_ID from dual;
end if;

if :new.Operator_ID is null then        --Оператор, создавший строку.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --Определяем дату создания строки.
  :new.Date_Ins := SysDate;
end if;

end;--trigger;
/
