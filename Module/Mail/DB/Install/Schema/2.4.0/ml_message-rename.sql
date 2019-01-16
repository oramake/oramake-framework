-- удаление внешних ограничений
@oms-drop-foreign-key stg_email
@oms-drop-foreign-key emt_report_message
@oms-drop-foreign-key ml_attachment
@oms-drop-foreign-key ml_message

-- триггеры
drop trigger ml_message_bi_define
;


-- Переименование таблицы
alter table
  ml_message
rename to
  ml_message_2_4_0
;

-- удаление ограничений и индексов
alter table
  ml_message_2_4_0
drop constraint ml_message_ck_incoming_flag
;

alter table
  ml_message_2_4_0
drop constraint ml_message_chk_recipient_addr
;

alter table
  ml_message_2_4_0
drop constraint ml_message_chk_parent_message
;

alter table
  ml_message_2_4_0
drop constraint ml_message_ck_is_html
;

alter table
  ml_message_2_4_0
drop constraint ml_message_ck_mandatory
;

alter table
  ml_message_2_4_0
drop constraint ml_message_ck_mb_delete_date
;

alter table
  ml_message_2_4_0
drop constraint ml_message_ck_mb_for_del_flg
;

alter table
  ml_message_2_4_0
drop constraint ml_message_chk_sender_address
;

alter table
  ml_message_2_4_0
drop constraint ml_message_pk
;




drop index
  ml_message_ix_state_smtp
;

drop index
  ml_message_ix_expire_date
;

drop index
  ml_message_ix_fetch
;

drop index
  ml_message_ux
;

drop index
  ml_message_ux_rcadr_state_id
;

drop index
  ml_message_ix_source_message
;

drop index
  ml_message_ix_parent_message
;

-- Создание дополнительных индексов для ускорения переноса данных
-- в новые таблицы
create index ml_message_2_4_0_date_ins on ml_message_2_4_0 (
   date_ins
) tablespace &indexTablespace
;

create index ml_message_2_4_0_expire_date on ml_message_2_4_0 (
   expire_date
) tablespace &indexTablespace
;

