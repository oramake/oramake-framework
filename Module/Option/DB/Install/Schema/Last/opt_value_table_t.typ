/* db type: opt_value_table_t
  Значения настроечного параметра
  ( таблица объектов типа <opt_value_t>).
*/
create or replace type
  opt_value_table_t
as table of
  opt_value_t
/
