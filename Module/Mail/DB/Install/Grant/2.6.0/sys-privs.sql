-- script: Install/Grant/2.6.0/sys-privs.sql
-- Выдает права на подключение по порту 465 (требуется для SSL-авторизации
-- на SMTP-сервере).
--
-- Параметры:
-- userName                   - имя пользователя, которому выдаются права
--                              ( по умолчанию текущий)
--

define userName = "&1"


declare

  userName varchar2(30) := upper( '&userName');

begin

  -- Подключение по SMTP с авторизацией по SSL
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:465'
    , 'connect'
  );
end;
/



undefine userName
