-- trigger: op_action_type_bi_define
-- Триггер на заполенние служебных полей в табллице <op_action_type>

create or replace trigger op_action_type_bi_define
before insert on op_action_type
for each row  
-- op_action_type_bi_define
begin
  -- Определяем время создания строки
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
  
  -- Id оператора, добавившего запись
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId();
  end if;  
end op_action_type_bi_define;
/