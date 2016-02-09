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



-- требуется для успешного выполнения функции pkg_Common.getSessionSerial
grant select on sys.v_$session to &userName
/



undefine userName
