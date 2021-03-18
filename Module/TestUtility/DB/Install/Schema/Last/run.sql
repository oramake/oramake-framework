-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.


-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql


-- Последовательности

@oms-run tsu_job_seq.sqs
@oms-run tsu_process_seq.sqs
@oms-run tsu_test_run_seq.sqs


-- Таблицы

@oms-run tsu_job.tab
@oms-run tsu_process.tab
@oms-run tsu_test_run.tab


-- Outline-ограничения целостности

@oms-run tsu_job.con
@oms-run tsu_test_run.con
