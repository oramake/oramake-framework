-- script: Install/Schema/2.3.0/revert.sql
-- Удаляет обновления объектов схемы до версии 2.3.0.
--
-- Основные изменения:
--  - из таблицы <ml_message> удалено поле retry_send_count
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

alter table 
  ml_message
drop column
  retry_send_count
;

