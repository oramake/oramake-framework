-- script: create-user.sql
-- —крипт дл€ создани€ пользовател
--
-- ѕараметры:
-- 1                          - им€ пользовател€
-- dataTablespace             - им€ табличного пространства дл€ данных
-- indexTablespace            - им€ табличного пространства дл€ индексов
--

define userName = &1

create user &userName identified by &userName
/
alter user &userName default tablespace &dataTablespace
/
alter user &userName quota unlimited on &dataTablespace
/
alter user &userName quota unlimited on &indexTablespace
/
grant alter session to &userName
/
grant create materialized view to &userName
/
grant create procedure to &userName
/
grant create sequence to &userName
/
grant create session to &userName
/
grant create synonym to &userName
/
grant create table to &userName
/
grant create trigger to &userName
/
grant create type to &userName
/
grant create view to &userName
/
grant query rewrite to &userName
/


-- OMS
grant select on dba_ddl_locks to &userName
/
grant select on dba_dml_locks to &userName
/
grant select on sys.v_$lock to &userName
/
grant select on sys.v_$session to &userName
/
grant select on dba_objects to &userName
/
grant select on dba_jobs_running to &userName
/

-- Use autotrace in SQL*Plus ( privs from plustrace role, script
-- $ORACLE_HOME/sqlplus/admin/plustrce.sql)
grant select on sys.v_$sesstat to &userName
/
grant select on sys.v_$statname to &userName
/
grant select on sys.v_$mystat to &userName
/
