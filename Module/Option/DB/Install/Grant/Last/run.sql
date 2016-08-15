-- script: Install/Grant/Last/run.sql
-- ������ ��� ������ ���� �� ������������� ������.
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

grant execute on opt_plsql_object_option_t to &toUserName
/
create or replace synonym
  &toUserName..opt_plsql_object_option_t
for
  opt_plsql_object_option_t
/

grant select on v_opt_option_value to &toUserName
/
create or replace synonym &toUserName..v_opt_option_value for v_opt_option_value
/

undefine toUserName

