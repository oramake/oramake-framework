-- script: Install/Grant/Last/run.sql
-- Выдает необходимые права на использование модуля.
--
-- Параметры:
-- toUserName                  - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт запускается под пользователем, которому принадлежат объекты модуля
--   ;
--

define toUserName = "&1"



grant execute on pkg_Calendar to &toUserName
/
create or replace synonym &toUserName..pkg_Calendar for pkg_Calendar
/


grant select on cdr_day to &toUserName
/
create or replace synonym &toUserName..cdr_day for cdr_day
/



undefine toUserName
