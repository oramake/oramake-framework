-- script: Install/Grant/Last/sys-privs.sql
-- ������ ����� �� ����������� �� ����� 465 (��������� ��� SSL-�����������
-- �� SMTP-�������).
--
-- ���������:
-- userName                   - ��� ������������, �������� �������� �����
--                              ( �� ��������� �������)
--

define userName = "&1"


declare

  userName varchar2(30) := upper( '&userName');

begin

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
