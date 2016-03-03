--script: Install/Schema/Last/sys-privs.sql
--Выдает системные привилегии, необходимые для установки и работы модуля.
--
--Параметры:
--userName                    - имя пользователя, в схему которого
--                              будет установлен модуль
define userName = "&1"


-- необходимо для создания и выдачи прав на view V_SCH_BATCH
grant select on dba_jobs to &userName with grant option
/

grant select on dba_jobs_running to &userName with grant option
/

grant select on sys.v_$session to &userName with grant option
/

-- необходимо для работы пакета pkg_Scheduler
grant select on sys.v_$db_pipes to &userName
/

grant alter system to &userName
/

grant execute on dbms_pipe to &userName
/



undefine userName
