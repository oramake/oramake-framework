/* db type: opt_option_value_table_t
  Настроечные параметры с текущими используемыми значениями
  ( таблица объектов типа <opt_option_value_t>).
*/
create or replace type
  opt_option_value_table_t
as table of
  opt_option_value_t
/
