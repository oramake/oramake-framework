-- trigger: ml_message_bi_define
-- Инициализация полей таблицы <ml_message> при вставке записи.
create or replace trigger ml_message_bi_define
  before insert
  on ml_message
  for each row
begin

  -- Определяем значение первичного ключа
  if :new.message_id is null then
    :new.message_id := ml_message_seq.nextval;
  end if;

  -- Id оператора, добавившего запись
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- Определяем дату добавления записи
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;

  -- Нормализуем адрес отправителя
  :new.sender_address := lower( trim( :new.sender_address));

  -- Нормализуем адрес получателя
  :new.recipient_address := lower( trim( :new.recipient_address));
end;
/
