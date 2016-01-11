--script: Install/Grant/Last/revoke-sys.sql
--�������� �����, ����������� ��� ���������/�������� ����� ����� Java
--� ������� ���������� <JavaMail>.
--
--���������:
--userName                    - ��� ������������, � �������� ���������� �����
--                              ( �� ��������� �������)
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
                                        --����������� �� POP3
  dbms_java.revoke_permision(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:110'
    , 'connect' 
  );
                                        --����������� �� IMAP
  dbms_java.revoke_permision(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:143'
    , 'connect' 
  );
                                        --����������� �� SMTP
  dbms_java.revoke_permision(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:25'
    , 'connect' 
  );
end;
/



undefine userName
