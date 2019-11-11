-- trigger: op_operator_group_bi_define
-- Триггер для инициализаии значений перед добавлением записи в таблицу <op_operator_group>

create or replace trigger op_operator_group_bi_define
  before insert
  on op_operator_group
  for each row
-- op_operator_group_bi_define
begin
  -- Тип действия
  if :new.action_type_code is null then
    :new.action_type_code := pkg_AccessOperator.CreateOperatorGroup_ActTpCd;
  end if;  
  
  -- Id оператора, добавившего запись
  if :new.operator_id_ins is null then
    :new.operator_id_ins :=
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
end op_operator_group_bi_define;
/