-- trigger: opt_access_level_bi_define
-- Инициализация полей таблицы <opt_access_level> при вставке записи.
create or replace trigger opt_access_level_bi_define
  before insert
  on opt_access_level
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
