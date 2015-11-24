--trigger: flh_request_operation_bi_def
--Стандартный триггер инициализации записи
create or replace trigger flh_request_operation_bi_def
 before insert
 on flh_request_operation
 for each row
begin
 						    -- Оператор, создавший запись		 	
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId;
  end if;
end;
/
