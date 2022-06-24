-- script: Install/Schema/1.2.0/run.sql
-- Обновление объектов схемы до версии 1.2.0.
--
-- Основные изменения:
--  - расширение полей segment_type в таблицах <dsz_segment> и <dsz_segment_group_tmp>
--

@oms-run dsz_segment.sql
@oms-run dsz_segment_group_tmp.sql
