-- script: Install/Grant/Last/run.sql
-- Выдает права на использование модуля.
--
-- Параметры:
-- toUserName                  - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт запускается под пользователем, которому принадлежат объекты модуля
--   ;
--

define toUserName = "&1"


grant execute on pkg_TaskProcessor to &toUserName
/
create or replace synonym &toUserName..pkg_TaskProcessor for pkg_TaskProcessor
/



grant select, update on tp_file to &toUserName
/
create or replace synonym &toUserName..tp_file for tp_file
/

grant select on tp_file_status to &toUserName
/
create or replace synonym &toUserName..tp_file_status for tp_file_status
/

grant select on tp_result to &toUserName
/
create or replace synonym &toUserName..tp_result for tp_result
/

grant select, references on tp_task to &toUserName
/
create or replace synonym &toUserName..tp_task for tp_task
/

grant select on tp_task_log to &toUserName
/
create or replace synonym &toUserName..tp_task_log for tp_task_log
/

grant select on tp_task_status to &toUserName
/
create or replace synonym &toUserName..tp_task_status for tp_task_status
/

grant select, references on tp_task_type to &toUserName
/
create or replace synonym &toUserName..tp_task_type for tp_task_type
/

grant select on v_tp_active_task to &toUserName
/
create or replace synonym &toUserName..v_tp_active_task for v_tp_active_task
/

grant select on v_tp_task to &toUserName
/
create or replace synonym &toUserName..v_tp_task for v_tp_task
/

grant select on v_tp_task_type to &toUserName
/
create or replace synonym &toUserName..v_tp_task_type for v_tp_task_type
/


undefine toUserName
