-- script: Install/Schema/2.3.0/run.sql
-- Обновление объектов схемы до версии 2.3.0.
--
-- Основные изменения:
--  - в таблицу <ml_message> добавлено поле retry_send_count
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run ml_message.sql
