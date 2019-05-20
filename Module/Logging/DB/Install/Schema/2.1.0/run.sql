-- script: Install/Schema/2.1.0/run.sql
-- Обновление объектов схемы до версии 2.1.0.
--
-- Основные изменения:
--  - в таблице <lg_log> удалены поля parent_log_id и message_type_code, а
--    поля sessionid, level_code, log_time сделаны обязательными (таблица
--    при этом пересоздается);
--  - удалена таблица lg_message_type;
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run lg_level.sql
@oms-run lg_log.sql
@oms-run drop-lg_message_type.sql
