-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.

-- Устанавливаем табличное пространство для индексов
@oms-set-indexTablespace.sql

-- Таблицы

@oms-run Install/Schema/Last/md_object_dependency_tmp.tab
