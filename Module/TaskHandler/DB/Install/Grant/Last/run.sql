-- script: Install/Grant/Last/run.sql
-- Выдача прав на использование модуля

define toUserName=&1

grant execute on pkg_TaskHandler to &toUserName
/
create or replace synonym &toUserName..pkg_TaskHandler for pkg_TaskHandler
/

grant select on v_th_command_pipe to &toUserName
/

create or replace synonym &toUserName..v_th_command_pipe for v_th_command_pipe
/

grant select on v_th_session to &toUserName
/
create or replace synonym &toUserName..v_th_session for v_th_session
/

undefine toUserName
