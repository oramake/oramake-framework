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


undefine userName
