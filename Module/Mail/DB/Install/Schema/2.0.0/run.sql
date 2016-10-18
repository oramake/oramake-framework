-- script: Install/Schema/2.0.0/run.sql
-- Обновление объектов схемы до версии 2.0.0.
--
-- Основные изменения:
--  - удалены устаревшие настроечные параметры с выделенными
--    SMTP-серверами;
--  - в таблицу <ml_message> добавлены поля incoming_flag,
--    mailbox_delete_date, mailbox_for_delete_flag;
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run opt_option.sql

@oms-run ml_message.sql
