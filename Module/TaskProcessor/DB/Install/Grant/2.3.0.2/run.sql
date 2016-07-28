-- script: Install/Grant/2.3.0.2/run.sql
-- Уточняет права на использование модуля согласно изменениям в версии 2.3.0.2.
--
-- Параметры:
-- toUserName                  - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт запускается под пользователем, которому принадлежат объекты модуля
--   ;
--

define toUserName = "&1"



grant execute on pkg_TaskProcessorBase to &toUserName
/
create or replace synonym &toUserName..pkg_TaskProcessorBase for pkg_TaskProcessorBase
/

grant merge view on v_tp_active_task to &toUserName
/

grant merge view on v_tp_task to &toUserName
/

grant merge view on v_tp_task_type to &toUserName
/



undefine toUserName
