-- Script: Install/Grant/Last/run.sql
-- Выдача прав и создание синонимов на объекты модуля
-- схеме с именем, определяемым параметром destUser
--
-- Параметры:
-- 	destUser - имя пользователя для выдачи прав и создания синонимов
define destUserInternal = &1

grant all on pkg_Calendar to &destUserInternal;
grant select on cdr_day to &destUserInternal;

create or replace synonym &destUserInternal..pkg_Calendar for pkg_Calendar;
create or replace synonym &destUserInternal..cdr_day for cdr_day;
