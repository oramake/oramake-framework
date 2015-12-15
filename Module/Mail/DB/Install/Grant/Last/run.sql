-- script: Install/Grant/Last/run.sql
-- Выдача прав на использование модуля.
--
-- 1                          - пользователь для выдачи прав
--

define toUserName=&1

grant execute on pkg_Mail to &toUserName
/
create or replace synonym &toUserName..pkg_Mail for pkg_Mail
/


undefine toUserName
