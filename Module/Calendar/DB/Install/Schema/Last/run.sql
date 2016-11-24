-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.


-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql


-- Таблицы

@oms-run cdr_day.tab
@oms-run cdr_day_type.tab


-- Outline-ограничения целостности

@oms-run cdr_day.con
@oms-run cdr_day_type.con
