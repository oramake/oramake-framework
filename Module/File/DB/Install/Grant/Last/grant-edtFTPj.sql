-- script: Install/Grant/Last/grant-edtFTPj.sql
-- Выдает пользователю права, необходимые для использования
-- библиотеки <edtFTPj> для подключения по SFTP.
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
                                        --Права для установки библиотеки
  dbms_java.grant_permission(
    userName
    , 'SYS:java.security.SecurityPermission'
    , 'putProviderProperty.CryptixEDT'
    , ''
  );
  dbms_java.grant_permission(
    userName
    , 'SYS:java.security.SecurityPermission'
    , 'removeProvider.CryptixEDT', ''
  );
  dbms_java.grant_permission(
    userName
    , 'SYS:java.security.SecurityPermission'
    , 'insertProvider.CryptixEDT'
    , ''
  );
                                        --Resolve ( FTP, SFTP)
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
                                        --Подключение по SFTP ( SSH)
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:22'
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
