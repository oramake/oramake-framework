-- trigger: op_group_role_bi_define
-- Триггер для инициализации значений перед добавлением записи в таблицу <op_group_role>

create or replace trigger op_group_role_bi_define
  before insert
  on op_group_role
  for each row
-- op_group_role_bi_define
begin
  -- Тип действия
  if :new.action_type_code is null then
    :new.action_type_code := pkg_AccessOperator.CreateGroupRole_ActTpCd;
  end if; 
  
  -- Id оператора, добавившего запись
  if :new.operator_id is null then
    :new.operator_id :=
      coalesce( :new.change_operator_id, pkg_Operator.getCurrentUserId())
    ;
  end if;

  -- Определяем дату добавления записи
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;

  -- Определяем номер изменения
  if :new.change_number is null then
    :new.change_number := 1;
  end if;

  -- Определяем время изменения строки
  if :new.change_date is null then
    :new.change_date := :new.date_ins;
  end if;

  -- Оператор, изменивший строку
  if :new.change_operator_id is null then
    :new.change_operator_id := :new.operator_id;
  end if;
end op_group_role_bi_define;
/