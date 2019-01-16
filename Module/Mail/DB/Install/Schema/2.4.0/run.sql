-- script: Install/Schema/2.4.0/run.sql
-- Обновление объектов схемы до версии 2.4.0.
--
-- Основные изменения:
--  - переименование таблицы <ml_message>, <ml_attachment>;
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run ml_message-rename.sql
@oms-run Install/Schema/Last/ml_message.tab
@oms-run ml_attachment-rename.sql
@oms-run Install/Schema/Last/ml_attachment.tab
@oms-run Install/Schema/Last/ml_message.con
@oms-run Install/Schema/Last/ml_attachment.con
@oms-run Install/Schema/Last/ml_attachment_bi_define.trg
@oms-run Install/Schema/Last/ml_message_bi_define.trg
