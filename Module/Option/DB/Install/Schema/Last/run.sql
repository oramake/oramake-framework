-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.
--

-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql

-- SQL-типы
@oms-run opt_option_value_t.typ
@oms-run opt_option_value_table_t.typ
@oms-run opt_value_t.typ
@oms-run opt_value_table_t.typ

-- Таблицы
@oms-run opt_access_level.tab
@oms-run opt_object_type.tab
@oms-run opt_option_new.tab
@oms-run opt_option_history.tab
@oms-run opt_value.tab
@oms-run opt_value_history.tab
@oms-run opt_value_type.tab

-- Outline-ограничения целостности
@oms-run opt_access_level.con
@oms-run opt_object_type.con
@oms-run opt_option_new.con
@oms-run opt_option_history.con
@oms-run opt_value.con
@oms-run opt_value_history.con
@oms-run opt_value_type.con

-- Последовательности
@oms-run opt_object_type_seq.sqs
@oms-run opt_option_seq.sqs
@oms-run opt_option_history_seq.sqs
-- необходимо будет пересоздать с именем opt_value_seq
@oms-run opt_option_value_seq.sqs
@oms-run opt_value_history_seq.sqs

-- Функции
@oms-run opt_getLocalCryptoKey.prc



-- Устаревшие объекты

-- Таблицы
@oms-run doc_mask.tab
@oms-run doc_storage_rule.tab
@oms-run opt_option.tab
@oms-run opt_option_value.tab

-- Outline-ограничения целостности
@oms-run doc_mask.con
@oms-run doc_storage_rule.con
@oms-run opt_option.con
@oms-run opt_option_value.con

-- Последовательности
@oms-run doc_mask_seq.sqs
@oms-run doc_storage_rule_seq.sqs
