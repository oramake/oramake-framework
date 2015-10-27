-- trigger: prm_registered_session_bi
-- Стандартный триггер инициализации записи
create or replace trigger prm_registered_session_bi
 before insert
 on prm_registered_session
 for each row
 when ( 
   new.operator_id is null 
   or new.date_ins is null 
   or new.registered_session_id is null
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
if :new.registered_session_id is null then
  select
    prm_registered_session_seq.nextval 
  into    
    :new.registered_session_id
  from
    dual;  
end if;

end;--trigger;
/
