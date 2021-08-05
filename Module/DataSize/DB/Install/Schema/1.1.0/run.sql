-- script: Install/Schema/1.1.0/run.sql
-- Обновление объектов схемы до версии 1.1.0.
--
-- Основные изменения:
--  - расширение полей segment_name, partition_name
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run dsz_segment.sql
