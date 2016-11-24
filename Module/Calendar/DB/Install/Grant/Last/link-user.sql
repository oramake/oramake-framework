-- script: Install/Grant/Last/link-user.sql
-- Выдает права для пользователя, под которым работает линк из
-- пользовательской БД.
--
-- Параметры:
-- toUserName                 - пользователь для выдачи прав
--

define toUserName = &1



@oms-run Install/Grant/Last/master-table.sql cdr_day
@oms-run Install/Grant/Last/master-table.sql cdr_day_type



undefine toUserName
