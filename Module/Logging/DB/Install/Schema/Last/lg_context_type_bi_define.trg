-- trigger: lg_context_type_bi_define
-- Инициализация полей таблицы <lg_context_type> при вставке записи.
create or replace trigger lg_context_type_bi_define
  before insert
  on lg_context_type
  for each row
begin

  -- Определяем значение первичного ключа
  if :new.context_type_id is null then
    :new.context_type_id := lg_context_type_seq.nextval;
  end if;

  -- Запись действующая по умолчанию
  if :new.deleted is null then
    :new.deleted := 0;
  end if;

  -- Определяем дату добавления записи
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
