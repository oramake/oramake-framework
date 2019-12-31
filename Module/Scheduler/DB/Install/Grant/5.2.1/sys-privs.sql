-- script: Install/Grant/5.2.1/sys-privs.sql
-- Выдает дополнительные системные привилегии для версии 5.2.1.
--
-- Параметры:
-- userName                   - имя пользователя, в схему которого
--                              будет установлен модуль
--

define userName = "&1"



grant manage scheduler to &userName
/



undefine userName
