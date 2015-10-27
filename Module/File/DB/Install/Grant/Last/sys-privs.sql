-- script: Install/Grant/Last/sys-privs.sql
--
-- ������ ������������ �������������� �����, ����������� ��� ��������� �
-- ������������� ������.
--
-- ���������:
-- toUserName                 - ��� ������������, �������� �������� �����
--
-- ���������:
--  - ������ ������ ����������� ��� ����������������� �������������;
--

define toUserName = "&1"



@oms-run grant-common-java-privs.sql "&toUserName"

@oms-run grant-BouncyCastle.sql "&toUserName"
@oms-run grant-edtFTPj.sql "&toUserName"
@oms-run grant-HttpClient.sql "&toUserName"



begin
  execute immediate
    'grant javasyspriv to &toUserName';
exception when others then
  dbms_output.put_line( SQLERRM || ': ok');
end;
/

grant javauserpriv to &toUserName
/
grant alter system to &toUserName
/



undefine toUserName
