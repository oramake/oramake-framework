-- script: Install/Schema/2.1.0/run.sql
-- Обновление объектов схемы до версии 2.1.0.
--
-- Основные изменения:
--  - создаются матлоги для таблиц <cdr_day> и <cdr_day_type> в случае
--    их отсутствия;
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run drop-old-objects.sql

@oms-run cdr_day_type.sql
@oms-run cdr_day.sql
