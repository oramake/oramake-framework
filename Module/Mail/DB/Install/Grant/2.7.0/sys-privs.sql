-- script: Install/Grant/2.7.0/sys-privs.sql
-- ������ �������������� ����� ���� "SYS:java.lang.RuntimePermission".
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
    , 'accessClassInPackage.sun.security.x509'
    , ''
  );
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
end;
/



undefine userName
