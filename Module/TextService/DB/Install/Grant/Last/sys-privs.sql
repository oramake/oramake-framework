--script: Install/Grant/Last/sys-privs.sql
--Выдает системные привилегии, необходимые для установки и работы модуля.
--
--Параметры:
--userName                    - имя пользователя, в схему которого
--                              будет установлен модуль
define userName = "&1"

grant create any synonym to &username
/

undefine userName
