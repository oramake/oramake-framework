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



-- Оставлено для совместимости, лучше использовать представление v_cdr_day
grant select on cdr_day to &toUserName
/
create or replace synonym &toUserName..cdr_day for cdr_day
/



@oms-run Install/Grant/Last/Common/run.sql



undefine toUserName
