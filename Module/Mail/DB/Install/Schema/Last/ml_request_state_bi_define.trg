--trigger: ml_request_state_bi_define
--Стандартный триггер инициализации записи
create or replace trigger ml_request_state_bi_define
 before insert
 on ml_request_state
 for each row
begin
 						    -- Оператор, создавший запись		 	
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId;
  end if;
end;
/
