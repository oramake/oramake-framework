--script: Install/Grant/Last/revoke-sys.sql
--Забирает права, необходимые для получения/отправки почты через Java
--с помощью библиотеки <JavaMail>.
--
--Параметры:
--userName                    - имя пользователя, у которого забираются права
--                              ( по умолчанию текущий)
--
define userName = "&1"



declare

  userName varchar2( 30)
    := upper( coalesce( nullif( '&userName', 'null'), user));

begin
  dbms_java.revoke_permision(
    userName
    , 'SYS:java.util.PropertyPermission'
    , '*'
    , 'read,write'
  );
  dbms_java.revoke_permision(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*'
    , 'resolve' 
  );
                                        --Подключение по POP3
  dbms_java.revoke_permision(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:110'
    , 'connect' 
  );
                                        --Подключение по IMAP
  dbms_java.revoke_permision(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:143'
    , 'connect' 
  );
                                        --Подключение по SMTP
  dbms_java.revoke_permision(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:25'
    , 'connect' 
  );
end;
/



undefine userName
