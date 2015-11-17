-- script: Install/Grant/Last/run.sql
-- Выдаёт права на использование модуля

define toUserName=&1

grant execute on pkg_FileOrigin to &toUserName
/
create or replace synonym &toUserName..pkg_File for pkg_File
/

grant select, delete on tmp_file_name to &toUserName
/
create or replace synonym &toUserName..tmp_file_name for tmp_file_name
/

undefine toUserName
