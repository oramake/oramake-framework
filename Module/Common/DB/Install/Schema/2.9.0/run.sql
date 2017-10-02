-- script: Install/Schema/2.9.0/run.sql
-- Обновление объектов схемы до версии 2.9.0.
--
-- Основные изменения:
--  - добавлены поля в таблицу <cmn_database_config>
--


@oms-run cmn_database_config.sql
