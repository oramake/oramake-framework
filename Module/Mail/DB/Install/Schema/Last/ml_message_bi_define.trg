--trigger: ml_message_bi_define
--Стандартный триггер инициализации записи
create or replace trigger ml_message_bi_define
 before insert
 on ml_message
 for each row
begin
                                        --Определяем значение первичного ключа.     
if :new.Message_ID is null then
  select ml_Message_Seq.nextval into :new.Message_ID from dual;
end if;
                                        --Оператор, создавший строку.
if :new.Operator_ID is null then
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;
                                        --Определяем время создания строки.
if :new.Date_Ins is null then
  :new.Date_Ins := sysdate;
end if;
                                        --Нормализуем адрес отправителя
:new.Sender_Address := lower( trim( :new.Sender_Address));
                                        --Нормализуем адрес получателя
:new.Recipient_Address := lower( trim( :new.Recipient_Address));

end;--trigger;
/
