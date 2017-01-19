-- script: create-user-admin.sql
-- —крипт дл€ создани€ вспомогательного пользовател€ с расширенными
-- привилеги€ми. ƒанный пользователь затем может использоватьс€ дл€ создани€
-- новых пользователей, в схему которых будут устанавливатьс€ модули, а также
-- дл€ выдачи дополнительных привилегий при установке модулей.
--
-- ѕараметры:
-- 1                          - им€ пользовател€
-- dataTablespace             - им€ табличного пространства дл€ данных
-- indexTablespace            - им€ табличного пространства дл€ индексов
--
-- “акже выдаЄт права:
--  - дл€ выборки из любой таблицы или системного справочника
--  - дл€ создани€ линков
--  - дл€ создани€ мат. логов на таблицы других схем
--  - дл€ выдачи прав на выборку из любой таблицы
--


define userName = &1

create user &userName identified by &userName
/
alter user &userName quota unlimited on &dataTablespace
/
alter user &userName quota unlimited on &indexTablespace
/

grant create user to &userName
/
grant alter user to &userName
/
grant drop user to &userName
/
grant alter any materialized view to &userName with admin option
/
grant alter session to &userName with admin option
/
grant alter system to &userName with admin option
/
grant create any synonym to &userName with admin option
/
grant create materialized view to &userName with admin option
/
grant create procedure to &userName with admin option
/
grant create public synonym to &userName with admin option
/
grant create sequence to &userName with admin option
/
grant create session to &userName with admin option
/
grant create synonym to &userName with admin option
/
grant create table to &userName with admin option
/
grant create trigger to &userName with admin option
/
grant create type to &userName with admin option
/
grant create view to &userName with admin option
/
grant connect to &userName with admin option
/
grant query rewrite to &userName with admin option
/
-- administration
grant select any dictionary to &userName
/
grant select any table to &userName
/
-- create materialized view log
grant create any table to &userName
/
-- links
grant create database link to &userName with admin option
/

-- Module: OraMakeSystem( recommended)
grant select on dba_ddl_locks to &userName with grant option
/
grant select on dba_dml_locks to &userName with grant option
/
grant select on sys.v_$lock to &userName with grant option
/
grant select on sys.v_$session to &userName with grant option
/
grant select on dba_objects to &userName with grant option
/
grant select on dba_jobs_running to &userName with grant option
/
-- Module: Common
grant select on sys.v_$mystat to &userName with grant option
/
begin
  execute immediate
    'grant execute on dbms_network_acl_admin to &userName';
exception when others then
  dbms_output.put_line( 'Could not grant dbms_network_acl_admin');
  dbms_output.put_line( 'sqlerrm=' || sqlerrm);
end;
/
-- Module: DataSize
grant select on dba_segments to &userName with grant option
/
grant select on dba_extents to &userName with grant option
/
-- Module: File, Mail
grant java_admin to &userName
/
grant javauserpriv to &userName with admin option
/
grant javasyspriv to &userName with admin option
/
-- Module: Option
grant execute on sys.dbms_crypto to &userName with grant option
/
-- Module: TaskHandler
grant select on sys.v_$db_pipes to &userName with grant option
/
grant execute on dbms_lock to &userName with grant option
/
grant execute on dbms_pipe to &userName with grant option
/
-- Module: Scheduler
grant select on dba_jobs to &userName with grant option
/
-- Module: ProcessMonitor
grant select on sys.v_$process to &userName with grant option
/
grant select on sys.v_$parameter to &userName with grant option
/
grant execute on sys.dbms_system to &userName with grant option
/
grant select on sys.v_$sqltext to &userName with grant option
/
grant select on sys.v_$sql_plan to &userName with grant option
/
grant select on sys.v_$sesstat to &userName with grant option
/
grant select on sys.v_$statname to &userName with grant option
/
