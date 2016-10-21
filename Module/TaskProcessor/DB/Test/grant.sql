define toUserName=&1

grant execute on pkg_TaskProcessorTest to &toUserName
/
create or replace synonym &toUserName..pkg_TaskProcessorTest for pkg_TaskProcessorTest
/

undefine toUserName


