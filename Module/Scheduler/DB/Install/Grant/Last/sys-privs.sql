--script: Install/Schema/Last/sys-privs.sql
--Выдает системные привилегии, необходимые для установки и работы модуля.
--
--Параметры:
--userName                    - имя пользователя, в схему которого
--                              будет установлен модуль
define userName = "&1"



grant create job to &userName
/

grant manage scheduler to &userName
/


grant select on sys.v_$session to &userName with grant option
/

-- необходимо для работы пакета pkg_Scheduler
grant select on sys.v_$db_pipes to &userName
/

grant execute on dbms_pipe to &userName
/




undefine userName
