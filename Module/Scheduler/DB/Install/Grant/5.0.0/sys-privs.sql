-- script: Install/Grant/5.0.0/sys-privs.sql
-- Выдает дополнительные системные привилегии для версии 5.0.0.
--
-- Параметры:
-- userName                   - имя пользователя, в схему которого
--                              будет установлен модуль
--

define userName = "&1"



grant create job to &userName
/



undefine userName
