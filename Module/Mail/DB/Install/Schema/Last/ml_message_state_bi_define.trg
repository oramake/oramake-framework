--trigger: ml_message_state_bi_define
--Стандартный триггер инициализации записи
create or replace trigger ml_message_state_bi_define
 before insert
 on ml_message_state
 for each row
begin
                                        --Оператор, создавший строку.
if :new.Operator_ID is null then
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;
                                        --Определяем дату создания строки.
if :new.Date_Ins is null then
  :new.Date_Ins := SysDate;
end if;
      
end;--trigger;
/
