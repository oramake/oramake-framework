-- script: Install/Grant/Last/UserDb/run.sql
-- Выдает необходимые права на использование модуля в пользовательской БД.
--
-- Параметры:
-- toUserName                  - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт запускается под пользователем, которому принадлежат объекты модуля
--   ;
--

define toUserName = "&1"



@oms-run Install/Grant/Last/Common/run.sql



undefine toUserName
