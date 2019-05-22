-- script: Install/Schema/5.2.0/run.sql
-- Обновление объектов схемы до версии 5.2.0.
--
-- Основные изменения:
--  - замена oracle_job_id на activated_flag в таблице <sch_batch>;
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run sch_batch.sql
