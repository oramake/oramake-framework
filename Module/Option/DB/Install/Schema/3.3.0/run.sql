-- script: Install/Schema/3.3.0/run.sql
-- Обновление объектов схемы до версии 3.3.0.
--
-- Основные изменения:
--  - удалены устаревшие таблицы opt_option_value, opt_option, doc_mask,
--    doc_storage_rule;
--  - таблица opt_option_new переименована в opt_option;
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

@oms-run drop-old-object.sql
@oms-run drop-old-column.sql
@oms-run rename-object.sql
