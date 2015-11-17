--script: Install/Grant/Last/sys-privs.sql
--
--Выдает пользователю дополнительные права, необходимые для установки модуля.
--
--Параметры:
--toUserName                  - имя пользователя, которому выдаются права
--
--Замечания:
--  - скрипт должен выполняться под привилегированным пользователем;
--

define toUserName = "&1"



grant select on sys.v_$db_pipes to &toUserName with grant option
/

grant select on sys.v_$session to &toUserName with grant option
/

grant execute on dbms_lock to &toUserName
/

grant execute on dbms_pipe to &toUserName
/



undefine toUserName
