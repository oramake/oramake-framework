-- script: Install/Grant/Last/grant-edtFTPj.sql
-- ������ ������������ �����, ����������� ��� �������������
-- ���������� <edtFTPj> ��� ����������� �� FTP.
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
                                        --Resolve ( FTP)
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
