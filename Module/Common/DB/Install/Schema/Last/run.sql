-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.

-- Устанавливаем табличное пространство для индексов
@oms-set-indexTablespace.sql

-- Таблицы

@oms-run cmn_database_config.tab
@oms-run cmn_sequence.tab
@oms-run cmn_string_uid_tmp.tab

@oms-run fill_cmn_sequence.sql

-- Реализация функции агрегирования
@oms-run str_concat.sql

@oms-run cmn_string_table_t.typ
