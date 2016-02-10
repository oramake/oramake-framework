-- trigger: lg_log_bi_define
-- Инициализация полей таблицы <lg_log> при вставке записи.
create or replace trigger lg_log_bi_define
  before insert
  on lg_log
  for each row
begin

  -- Определяем значение первичного ключа
  if :new.log_id is null then
    :new.log_id := lg_log_seq.nextval;
  end if;

  -- Id оператора, добавившего запись
  if :new.operator_id is null then
    :new.operator_id := pkg_LoggingInternal.getCurrentOperatorId();
  end if;

  -- Определяем дату добавления записи
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
