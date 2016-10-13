-- trigger: ml_message_state_bi_define
-- Инициализация полей таблицы <ml_message_state> при вставке записи.
create or replace trigger ml_message_state_bi_define
  before insert
  on ml_message_state
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
