-- script: Test/Grant/run.sql
-- ������ ���� �� �������� �����.
--

define toUserName = &1

grant execute on pkg_AccessOperatorTest to &toUserName
/
create or replace synonym &toUserName..pkg_AccessOperatorTest for pkg_AccessOperatorTest
/

undefine toUserName


