-- script: Install/Grant/Last/create-batch.sql
-- ������ ���� �� �������� ������.

define toUserName="&1"

grant execute on pkg_SchedulerLoad to &toUserName
/
create or replace synonym &toUserName..pkg_SchedulerLoad for pkg_SchedulerLoad
/

undefine toUserName
