-- script: Install/Schema/1.2.1/run.sql
-- Обновление объектов схемы до версии 1.2.1.
--
-- Основные изменения:
--  - из таблицы <mod_install_type> удалено поле operator_id, а также
--    удален триггер mod_install_type_bi_define;
--

drop trigger
  mod_install_type_bi_define
/

alter table
  mod_install_type
drop column
  operator_id
/
