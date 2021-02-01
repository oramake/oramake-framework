-- script: Install/Grant/Last/sys-privs.sql
-- ������ �����, ����������� ��� ���������/�������� ����� ����� Java
-- � ������� ���������� <JavaMail>.
--
-- ���������:
-- userName                   - ��� ������������, �������� �������� �����
--                              ( �� ��������� �������)
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

  -- ����������� �� POP3
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:110'
    , 'connect'
  );

  -- ����������� �� IMAP
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:143'
    , 'connect'
  );

  -- ����������� �� SMTP
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:25'
    , 'connect'
  );

  -- ����������� �� SMTP � ������������ �� SSL
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:465'
    , 'connect'
  );
end;
/



undefine userName
