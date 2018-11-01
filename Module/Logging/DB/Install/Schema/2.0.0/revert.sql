-- script: Install/Schema/2.0.0/revert.sql
-- Отменяет изменения в объектах схемы, внесенные при установке версии 2.0.0.
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run lg_log.revert.sql
@oms-run add-context.revert.sql
