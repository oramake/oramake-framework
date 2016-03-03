--trigger: dsz_header_bi_define
--Стандартный триггер инициализации записи
create or replace trigger dsz_header_bi_define
 before insert
 on dsz_header
 for each row
 when ( 
   new.operator_id is null 
   or new.date_ins is null 
   or new.header_id is null
 )
begin
                                        -- Оператор, создавший строку.
if :new.operator_id is null then
  :new.operator_id := pkg_Operator.GetCurrentUserID;
end if;
                                        -- Определяем время создания строки.
if :new.date_ins is null then
  :new.date_ins := sysdate;
end if;
					          -- Инициализируем первичный ключ
if :new.header_id is null then
  :new.header_id := pkg_DataSize.GetNextHeaderId;
end if;

end;--trigger;
/
