-- script: Install/Grant/Last/grant-HttpClient.sql
-- Выдает пользователю права, необходимые для использования
-- библиотеки <HttpClient> для подключения по HTTP.
--
-- Параметры:
-- userName                    - имя пользователя, которому выдаются права
--
define userName = "&1"



declare

  userName varchar2( 30) := upper( '&userName');

begin
  dbms_output.put_line(
    'Grant privs for HttpClient to ' || userName || '...'
  );

  -- resolve
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*'
    , 'resolve'
  );

  -- Подключение по HTTP
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:80'
    , 'connect'
  );
end;
/



undefine userName
