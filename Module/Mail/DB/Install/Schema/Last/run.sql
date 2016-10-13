-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.


-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql


-- Таблицы

@oms-run ml_attachment.tab
@oms-run ml_fetch_request.tab
@oms-run ml_message.tab
@oms-run ml_message_state.tab
@oms-run ml_request_state.tab


-- Outline-ограничения целостности

@oms-run ml_attachment.con
@oms-run ml_fetch_request.con
@oms-run ml_message.con
@oms-run ml_message_state.con
@oms-run ml_request_state.con


-- Последовательности

@oms-run ml_attachment_seq.sqs
@oms-run ml_fetch_request_seq.sqs
@oms-run ml_message_seq.sqs
