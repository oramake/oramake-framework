-- script: Install/Schema/2.2.0/run.sql
-- Обновление объектов схемы до версии 2.2.0.
--
-- Основные изменения:
--  - создана таблица <lg_log_data>, в таблицу <lg_log> добавлены поля
--    long_message_text_flag, text_data_flag;
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run lg_log.sql
@oms-run lg_log_data.sql
