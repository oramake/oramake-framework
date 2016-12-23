-- developer-privs
-- Скрипт выдаёт пользователю developer привилегии для
-- создания нового основного пользователя базы,
-- для которого можно установить утилитарные модули.
--
--
-- Также выдаёт права:
--
--              - для выборки из любой таблицы или системного справочника
--              - для создания линков
--              - для создания мат. логов на таблицы других схем
--              - для выдачи прав на выборку из любой таблицы
--
grant create user to developer
/
grant alter user to developer
/
grant drop user to developer
/
grant alter any materialized view to developer with admin option
/
grant alter session to developer with admin option
/
grant alter system to developer with admin option
/
grant create any synonym to developer with admin option
/
grant create materialized view to developer with admin option
/
grant create procedure to developer with admin option
/
grant create public synonym to developer with admin option
/
grant create sequence to developer with admin option
/
grant create session to developer with admin option
/
grant create synonym to developer with admin option
/
grant create table to developer with admin option
/
grant create trigger to developer with admin option
/
grant create type to developer with admin option
/
grant create view to developer with admin option
/
grant connect to developer with admin option
/
grant query rewrite to developer with admin option
/
-- administration
grant select any dictionary to developer
/
grant select any table to developer
/
-- create materialized view log
grant create any table to developer
/
-- links
grant create database link to developer with admin option
/

-- Module: OraMakeSystem( recommended)
grant select on dba_ddl_locks to developer with grant option
/
grant select on dba_dml_locks to developer with grant option
/
grant select on sys.v_$lock to developer with grant option
/
grant select on sys.v_$session to developer with grant option
/
grant select on dba_objects to developer with grant option
/
grant select on dba_jobs_running to developer with grant option
/
-- Module: Common
grant select on sys.v_$mystat to developer with grant option
/
begin
  execute immediate
    'grant execute on dbms_network_acl_admin to developer';
exception when others then
  dbms_output.put_line( 'Could not grant dbms_network_acl_admin');
  dbms_output.put_line( 'sqlerrm=' || sqlerrm);
end;
/
-- Module: DataSize
grant select on dba_segments to developer with grant option
/
grant select on dba_extents to developer with grant option
/
-- Module: File, Mail
grant java_admin to developer
/
grant javauserpriv to developer with admin option
/
grant javasyspriv to developer with admin option
/
-- Module: Option
grant execute on sys.dbms_crypto to &userName with grant option
/
-- Module: TaskHandler
grant select on sys.v_$db_pipes to developer with grant option
/
grant execute on dbms_lock to developer with grant option
/
grant execute on dbms_pipe to developer with grant option
/
-- Module: Scheduler
grant select on dba_jobs to developer with grant option
/
-- Module: ProcessMonitor
grant select on sys.v_$process to developer with grant option
/
grant select on sys.v_$parameter to developer with grant option
/
grant execute on sys.dbms_system to developer with grant option
/
grant select on sys.v_$sqltext to developer with grant option
/
grant select on sys.v_$sql_plan to developer with grant option
/
grant select on sys.v_$sesstat to developer with grant option
/
grant select on sys.v_$statname to developer with grant option
/

