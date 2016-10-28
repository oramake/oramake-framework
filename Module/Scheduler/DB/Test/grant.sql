define toUserName=&1

grant execute on pkg_SchedulerTest to &toUserName
/
create or replace synonym &toUserName..pkg_SchedulerTest for pkg_SchedulerTest
/

undefine toUserName

