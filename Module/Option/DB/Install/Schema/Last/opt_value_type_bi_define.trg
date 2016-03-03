-- trigger: opt_value_type_bi_define
-- Инициализация полей таблицы <opt_value_type> при вставке записи.
create or replace trigger opt_value_type_bi_define
  before insert
  on opt_value_type
  for each row
begin

  -- Id оператора, добавившего запись
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- Определяем дату добавления записи
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
