-- удаление внешних ограничений
@oms-drop-foreign-key ml_attachment
-- триггеры
drop trigger ml_attachment_bi_define
;


-- Переименование таблицы
alter table
  ml_attachment
rename to
  ml_attachment_2_4_0
;

alter table
  ml_attachment_2_4_0
drop constraint ml_attachment_pk
;

-- Индексы
drop index
  ml_attachment_ix_message_id
;

-- Создание дополнительного индекса по дате вставки записи
create index ml_attachment_2_4_0_date_ins on ml_attachment_2_4_0 (
   date_ins
) tablespace &indexTablespace
;

create index ml_attachment_2_4_0_ix_mess_id on ml_attachment_2_4_0 (
   message_id
) tablespace &indexTablespace
;
