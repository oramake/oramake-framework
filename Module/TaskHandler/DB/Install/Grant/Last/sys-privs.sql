--script: Install/Grant/Last/sys-privs.sql
--
--������ ������������ �������������� �����, ����������� ��� ��������� ������.
--
--���������:
--toUserName                  - ��� ������������, �������� �������� �����
--
--���������:
--  - ������ ������ ����������� ��� ����������������� �������������;
--

define toUserName = "&1"



grant select on sys.v_$db_pipes to &toUserName with grant option
/

grant select on sys.v_$session to &toUserName with grant option
/

grant execute on dbms_lock to &toUserName
/

grant execute on dbms_pipe to &toUserName
/



undefine toUserName
