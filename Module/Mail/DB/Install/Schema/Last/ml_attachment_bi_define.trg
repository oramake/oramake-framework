-- trigger: ml_attachment_bi_define
-- Инициализация полей таблицы <ml_attachment> при вставке записи.
create or replace trigger ml_attachment_bi_define
  before insert
  on ml_attachment
  for each row
begin

  -- Определяем значение первичного ключа
  if :new.attachment_id is null then
    :new.attachment_id := ml_attachment_seq.nextval;
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
