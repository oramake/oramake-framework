--script: Install/Grant/Last/sys-privs.sql
--
--Выдает пользователю дополнительные права, необходимые для установки и
--использования модуля.
--
--Параметры:
--toUserName                  - имя пользователя, которому выдаются права
--
--Замечания:
--  - скрипт должен выполняться под привилегированным пользователем;
--

define toUserName = "&1"

grant alter system to &toUserName
/

undefine toUserName
