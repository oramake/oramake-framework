--script: Install/Grant/Last/sys-privs.sql
--
--������ ������������ �������������� �����, ����������� ��� ��������� �
--������������� ������.
--
--���������:
--toUserName                  - ��� ������������, �������� �������� �����
--
--���������:
--  - ������ ������ ����������� ��� ����������������� �������������;
--

define toUserName = "&1"

grant alter system to &toUserName
/

undefine toUserName
