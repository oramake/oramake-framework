-- type: cmn_string_table_t
/*
 * dbtype: cmn_string_table_t
 * Тип таблица строк. Применяется для функции pkg_Common.split.
 */
create or replace type cmn_string_table_t as table of varchar2(32767)
/
