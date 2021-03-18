-- script: Install/Schema/1.2.0/run.sql
-- Обновление объектов схемы до версии 1.2.0.
--
-- Основные изменения:
--  - создание таблиц <tsu_job>, <tsu_job_header>, <tsu_test_run>.
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run Install/Schema/Last/run.sql
