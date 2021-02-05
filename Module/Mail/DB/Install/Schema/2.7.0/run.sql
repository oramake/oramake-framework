-- script: Install/Schema/2.7.0/run.sql
-- Обновление объектов схемы до версии 2.7.0.
--
-- Основные изменения:
--  - в уникальном индексе <ml_message_ux> вместо полей sender и recipient
--    стали использоваться sender_address и recipient_address;
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run ml_message.sql
