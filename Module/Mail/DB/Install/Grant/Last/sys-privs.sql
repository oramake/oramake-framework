-- script: Install/Grant/Last/sys-privs.sql
-- Выдает права, необходимые для получения/отправки почты через Java
-- с помощью библиотеки <JavaMail>.
--
-- Параметры:
-- userName                   - имя пользователя, которому выдаются права
--                              ( по умолчанию текущий)
--

define userName = "&1"



declare

  userName varchar2(30) := upper( '&userName');

begin
  dbms_java.grant_permission(
    userName
    , 'SYS:java.lang.RuntimePermission'
    , 'getClassLoader'
    , ''
  );
  dbms_java.grant_permission(
    userName
    , 'SYS:java.lang.RuntimePermission'
    , 'setFactory'
    , ''
  );
  dbms_java.grant_permission(
    userName
    , 'SYS:java.util.PropertyPermission'
    , '*'
    , 'read,write'
  );
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*'
    , 'resolve'
  );

  -- Подключение по POP3
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:110'
    , 'connect'
  );

  -- Подключение по IMAP
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:143'
    , 'connect'
  );

  -- Подключение по SMTP
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:25'
    , 'connect'
  );

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
