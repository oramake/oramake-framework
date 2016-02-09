-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.


-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql


-- Таблицы

@oms-run ccs_case_exception.tab
@oms-run ccs_type_exception.tab


-- Outline-ограничения целостности

@oms-run ccs_case_exception.con
@oms-run ccs_type_exception.con


-- Последовательности

@oms-run ccs_case_exception_seq.sqs
