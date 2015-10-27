-- script: Install/Grant/Last/grant-edtFTPj.sql
-- ������ ������������ �����, ����������� ��� �������������
-- ���������� <edtFTPj> ��� ����������� �� SFTP.
--
-- ���������:
-- userName                    - ��� ������������, �������� �������� �����
--
define userName = "&1"



declare

  userName varchar2( 30) := upper( '&userName');

begin
  dbms_output.put_line(
    'Grant privs for edtFTPj to ' || userName || '...'
  );
                                        --����� ��� ��������� ����������
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
                                        --����������� �� FTP
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:21'
    , 'connect'
  );
                                        --����������� �� SFTP ( SSH)
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:22'
    , 'connect'
  );
                                        --�������� ������ �� FTP � PASV ������
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:1024-'
    , 'connect'
  );
end;
/



undefine userName
