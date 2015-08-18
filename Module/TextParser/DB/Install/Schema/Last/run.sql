-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

--@oms-run Install/Grant/Last/all-to-public.sql
