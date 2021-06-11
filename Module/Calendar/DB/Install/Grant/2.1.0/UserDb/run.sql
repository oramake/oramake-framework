-- script: Install/Grant/2.1.0/UserDb/run.sql
-- Обновляет права на использование модуля в пользовательской БД.
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

-- Не создаем синоним, т.к. будет ошибка из-за наличия пакета pkg_Calendar
-- в основной схеме
--create or replace synonym &toUserName..pkg_Calendar for pkg_Calendar
--/


grant select, merge view on v_cdr_day to &toUserName with grant option
/
create or replace synonym &toUserName..v_cdr_day for v_cdr_day
/


grant select, merge view on v_cdr_day_type to &toUserName with grant option
/
create or replace synonym &toUserName..v_cdr_day_type for v_cdr_day_type
/

grant select on mv_cdr_day to &toUserName with grant option
/

grant select on mv_cdr_day_type to &toUserName with grant option
/


undefine toUserName
