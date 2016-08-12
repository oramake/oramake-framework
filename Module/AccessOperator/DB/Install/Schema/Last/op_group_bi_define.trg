-- trigger: op_group_bi_define
-- Инициализация полей таблицы <op_group> при вставке записи.
create or replace trigger op_group_bi_define
  before insert
  on op_group
  for each row
begin

  -- Определяем значение первичного ключа
  if :new.group_id is null then
    :new.group_id := op_group_seq.nextval;
  end if;

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
