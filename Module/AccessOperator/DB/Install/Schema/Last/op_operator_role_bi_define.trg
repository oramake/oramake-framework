-- trigger: op_operator_role_bi_define
-- Инициализация полей таблицы <op_operator_role> при вставке записи.
create or replace trigger op_operator_role_bi_define
  before insert
  on op_operator_role
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
