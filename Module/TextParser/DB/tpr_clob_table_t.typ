-- явно удал€ем, чтобы не было ошибки при создании из-за зависимостей
@oms-drop-type tpr_clob_table_t

-- dbtype: tpr_clob_table_t
-- “аблица CLOB дл€ использовани€ в объекте <tpr_csv_iterator_t>.
create or replace type tpr_clob_table_t
as table of clob
/
