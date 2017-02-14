-- script: Install/Grant/Last/run.sql
-- Выдает права на использование модуля.
--
-- Параметры:
-- toUserName                  - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт запускается под пользователем, которому принадлежат объекты модуля
--   ;
--

define toUserName = "&1"



grant execute on pkg_TextUtility to &toUserName
/
create or replace synonym &toUserName..pkg_TextUtility for pkg_TextUtility
/

grant select on pkg_ContextSearchUtility to &toUserName
/
create or replace synonym &toUserName..pkg_ContextSearchUtility for pkg_ContextSearchUtility
/



undefine toUserName
