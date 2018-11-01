-- add-logger-info-cols.sql
alter table
  lg_log
drop constraint
  lg_log_fk_module_id
/



-- add-context-cols.sql
drop index
  lg_log_ix_context_change
/
drop index
  lg_log_ix_log_time
/

create index
  lg_log_ix_date_ins
on
  lg_log (
    date_ins
  )
tablespace &indexTablespace
/

alter table
  lg_log
drop constraint
  lg_log_ck_context_type_level
/

alter table
  lg_log
drop constraint
  lg_log_ck_context_change
/



-- add-sessionid.sql
drop index
  lg_log_ix_sessionid_logid
/



-- drop new columns
alter table
  lg_log
drop (
  sessionid
  , level_code
  , message_label
  , context_level
  , context_type_id
  , context_value_id
  , open_context_log_id
  , open_context_log_time
  , open_context_flag
  , context_type_level
  , log_time
  , module_name
  , object_name
  , module_id
)
/


-- restore comments
comment on table lg_log is
  'Лог работы программных модулей [ SVN root: Oracle/Module/Logging]'
/
comment on column lg_log.log_id is
  'Id записи лога'
/
comment on column lg_log.parent_log_id is
  'Id родительской записи лога'
/
comment on column lg_log.message_type_code is
  'Код типа сообщения'
/
comment on column lg_log.message_value is
  'Целочисленное значение, связанное с сообщением'
/
comment on column lg_log.message_text is
  'Текст сообщения'
/
comment on column lg_log.date_ins is
  'Дата добавления записи'
/
comment on column lg_log.operator_id is
  'Id оператора ( из модуля AccessOperator)'
/
