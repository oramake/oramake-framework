-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.


-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql


-- Таблицы

@oms-run lg_context_type.tab
@oms-run lg_destination.tab
@oms-run lg_level.tab
@oms-run lg_log.tab
@oms-run lg_message_type.tab


-- Outline-ограничения целостности

@oms-run lg_context_type.con
@oms-run lg_log.con


-- Последовательности

@oms-run lg_context_type_seq.sqs
@oms-run lg_log_seq.sqs
