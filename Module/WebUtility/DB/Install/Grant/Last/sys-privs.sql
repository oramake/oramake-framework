-- script: Install/Schema/Last/sys-privs.sql
-- Выдает системные привилегии, необходимые для работы модуля.
--
-- Параметры:
-- userName                   - имя пользователя, в схему которого
--                              будет установлен модуль
--
-- Замечания:
-- - при отсутствии прав на пакет dbms_crypto установка модуля может быть
--  выполнена, но при попытке шифрования/дешифрования значений параметров
--  будет возникать ошибка;
--



define userName = "&1"



grant execute on utl_http to &userName
/

grant execute on dbms_lob to &userName
/

grant execute on dbms_utility to &userName
/



create or replace synonym &userName..utl_http for utl_http
/

create or replace synonym &userName..dbms_lob for dbms_lob
/

create or replace synonym &userName..dbms_utility for dbms_utility
/

undefine userName
