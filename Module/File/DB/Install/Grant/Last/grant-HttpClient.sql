-- script: Install/Grant/Last/grant-HttpClient.sql
-- ������ ������������ �����, ����������� ��� �������������
-- ���������� <HttpClient> ��� ����������� �� HTTP.
--
-- ���������:
-- userName                    - ��� ������������, �������� �������� �����
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

  -- ����������� �� HTTP
  dbms_java.grant_permission(
    userName
    , 'SYS:java.net.SocketPermission'
    , '*:80'
    , 'connect'
  );
end;
/



undefine userName
