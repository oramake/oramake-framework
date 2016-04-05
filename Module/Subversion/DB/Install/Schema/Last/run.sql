-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.


-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql


-- Таблицы

@oms-run svn_file_tmp.tab


-- Последовательности

@oms-run svn_file_tmp_seq.sqs
