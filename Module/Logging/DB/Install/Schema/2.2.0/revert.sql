-- script: Install/Schema/2.2.0/revert.sql
-- Отменяет изменения в объектах схемы, внесенные при установке версии 2.2.0.
--
-- Замечания:
-- - добавленые при установке в таблицу <lg_level> записи с кодами TRACE2 и
--  TRACE3 не удаляются при отмене установки;
--


drop view v_lg_log
/

drop table lg_log_data
/

alter table
  lg_log
drop constraint
  lg_log_ck_long_message_text_fl
/

alter table
  lg_log
drop constraint
  lg_log_ck_text_data_flag
/

alter table
  lg_log
set unused (
  long_message_text_flag
  , text_data_flag
)
/
