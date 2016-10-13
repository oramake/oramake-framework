-- trigger: ml_fetch_request_bi_define
-- Инициализация полей таблицы <ml_fetch_request> при вставке записи.
create or replace trigger ml_fetch_request_bi_define
  before insert
  on ml_fetch_request
  for each row
begin

  -- Определяем значение первичного ключа
  if :new.fetch_request_id is null then
    :new.fetch_request_id := ml_fetch_request_seq.nextval;
  end if;

  -- Определяем дату добавления записи
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
