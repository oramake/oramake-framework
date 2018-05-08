-- script: Install/Schema/2.0.0/run.sql
-- Обновление объектов схемы до версии 2.0.0.
--
-- Основные изменения:
--  - в таблицу <lg_log> добавлено поле sessionid;
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run drop-lg_log_ai_save_parent.sql

@oms-run add-sessionid.sql

