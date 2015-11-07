-- script: Install/Grant/Last/grant-edtFTPj.sql
-- Выдает пользователю права, необходимые для использования
-- библиотеки <edtFTPj> для подключения по FTP.
--
-- Параметры:
-- userName                    - имя пользователя, которому выдаются права
--
define userName = "&1"



declare

  userName varchar2( 30) := upper( '&userName');

begin
  dbms_output.put_line(
    'Grant privs for edtFTPj to ' || userName || '...'
  );
                                        --Resolve ( FTP)
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*'
    , 'resolve'
  );
                                        --Подключение по FTP
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:21'
    , 'connect'
  );
                                        --Передача данных по FTP в PASV режиме
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:1024-'
    , 'connect'
  );
end;
/



undefine userName
