-- явно удал€ем, чтобы не было ошибки при создании из-за зависимостей
@oms-drop-type tpr_string_table_t

-- dbtype: tpr_string_table_t
-- “аблица строк дл€ использовани€ в объекте <tpr_csv_iterator_t>.
create or replace type tpr_string_table_t
as table of varchar2(32767)
/
