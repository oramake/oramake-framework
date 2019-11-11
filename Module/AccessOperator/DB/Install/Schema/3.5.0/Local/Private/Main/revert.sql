-- script: Install/Schema/3.5.0/Local/Private/Main/revert.sql
-- Отмена установки объектов версии 3.5.0 модуля

-- Удаление таблиц
drop table
  op_load_lock_form_sources_tmp
/

-- Удаление последовательностей
drop sequence
  op_login_attempt_group_seq
/
