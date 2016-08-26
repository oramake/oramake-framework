-- script: Test/Schema/revert.sql
-- Удаление тестовых объектов схемы.
--

drop table dsn_test_source
/

drop table dsn_test_compare
/
drop table dsn_test_compare_ext
/
drop view v_dsn_test_compare
/

drop table dsn_test_cmptemp
/
drop table dsn_test_cmptemp_tmp
/
drop table dsn_test_cmptemp_ext
/
drop view v_dsn_test_cmptemp
/

drop materialized view dsn_test_mview preserve table
/
drop table dsn_test_mview
/
drop materialized view dsn_test_mview_ext preserve table
/
drop table dsn_test_mview_ext
/
drop view v_dsn_test_mview
/
