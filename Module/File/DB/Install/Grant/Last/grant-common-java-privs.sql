-- script: Install/Grant/Last/grant-common-java-privs.sql
-- ������ ������������ �������������� ����� �� ������ Java, �� ���������
-- � ���������� ������������� ������������.
--
-- ���������:
-- userName                    - ��� ������������, �������� �������� �����
--
define userName = "&1"



declare

  userName varchar2( 30) := upper( '&userName');

begin
  dbms_output.put_line(
    'Grant common Java privs to ' || userName || '...'
  );

  -- ��������� �������� ������ �����������
  dbms_java.grant_permission(
    userName
    , 'SYS:java.util.logging.LoggingPermission'
    , 'control'
    , ''
  );
end;
/



undefine userName
