-- trigger: op_operator_group_bi_define
-- Инициализация полей таблицы <op_operator_group> при вставке записи.
create or replace trigger op_operator_group_bi_define
  before insert
  on op_operator_group
  for each row
begin

  -- Id оператора, добавившего запись
  if :new.operator_id_ins is null then
    :new.operator_id_ins := pkg_Operator.getCurrentUserId();
  end if;

  -- Определяем дату добавления записи
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
