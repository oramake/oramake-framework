--trigger: ml_attachment_bi_define
--Стандартный триггер инициализации записи
create or replace trigger ml_attachment_bi_define
 before insert
 on ml_attachment
 for each row
begin
                                        --Определяем значение первичного ключа.     
if :new.Attachment_ID is null then
  select ml_Attachment_Seq.nextval into :new.Attachment_ID from dual;
end if;
                                        --Оператор, создавший строку.
if :new.Operator_ID is null then
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;
                                        --Определяем время создания строки.
if :new.Date_Ins is null then
  :new.Date_Ins := sysdate;
end if;

end;--trigger;
/
