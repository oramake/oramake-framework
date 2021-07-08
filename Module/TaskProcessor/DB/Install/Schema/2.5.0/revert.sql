-- script: Install/Schema/2.5.0/revert.sql
-- Отменяет изменения в объектах схемы, внесенные при установке версии 2.5.0.
--

alter table
  tp_task
drop (
  exec_result_string
)
/
