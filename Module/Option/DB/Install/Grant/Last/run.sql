-- script: Install/Grant/Last/run.sql
-- Скрипт для выдачи прав на использование модуля.
--

define toUserName=&1

grant execute on pkg_Option to &toUserName
/
create or replace synonym &toUserName..pkg_Option for pkg_Option
/

grant execute on opt_option_list_t to &toUserName
/
create or replace synonym &toUserName..opt_option_list_t for opt_option_list_t
/

grant execute on opt_option_value_t to &toUserName
/
create or replace synonym &toUserName..opt_option_value_t for opt_option_value_t
/
grant execute on opt_option_value_table_t to &toUserName
/
create or replace synonym &toUserName..opt_option_value_table_t for opt_option_value_table_t
/

grant execute on opt_value_t to &toUserName
/
create or replace synonym &toUserName..opt_value_t for opt_value_t
/
grant execute on opt_value_table_t to &toUserName
/
create or replace synonym &toUserName..opt_value_table_t for opt_value_table_t
/

grant execute on opt_plsql_object_option_t to &toUserName
/
create or replace synonym
  &toUserName..opt_plsql_object_option_t
for
  opt_plsql_object_option_t
/

grant select, merge view on v_opt_option to &toUserName
/
create or replace synonym &toUserName..v_opt_option for v_opt_option
/

grant select, merge view on v_opt_value to &toUserName
/
create or replace synonym &toUserName..v_opt_value for v_opt_value
/

grant select, merge view on v_opt_option_value to &toUserName
/
create or replace synonym &toUserName..v_opt_option_value for v_opt_option_value
/

undefine toUserName
