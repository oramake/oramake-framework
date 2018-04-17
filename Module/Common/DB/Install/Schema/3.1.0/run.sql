-- script: Install/Schema/3.1.0/run.sql
-- Обновление объектов схемы до версии 3.1.0.
--
-- Основные изменения:
--  - в таблицу <cmn_database_config> добавлено поле main_instance_name;
--

alter table
  cmn_database_config
add (
  main_instance_name            varchar2(20)
)
/

comment on column cmn_database_config.main_instance_name is
  'Имя основного экземляра БД (если задано, то по умолчанию возвращается функцией pkg_Common.getInstanceName вместо instance_name; полезно для standby БД)'
/
