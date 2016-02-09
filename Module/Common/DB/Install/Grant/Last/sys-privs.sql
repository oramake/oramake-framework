-- script: Install/Grant/Last/sys-privs.sql
-- Выдает пользователю дополнительные права, необходимые для установки и
-- использования модуля.
--
-- Параметры:
-- toUserName                 - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт должен выполняться под привилегированным пользователем;
--

define userName = &1



-- требуется для функции pkg_Common.getSessionId
grant select on sys.v_$session to &userName
/
grant select on sys.v_$mystat to &userName
/



undefine userName
