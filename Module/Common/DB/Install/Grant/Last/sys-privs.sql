-- script: Install/Grant/Last/sys-privs.sql
-- ������ ������������ �������������� �����, ����������� ��� ��������� �
-- ������������� ������.
--
-- ���������:
-- toUserName                 - ��� ������������, �������� �������� �����
--
-- ���������:
--  - ������ ������ ����������� ��� ����������������� �������������;
--

define userName = &1



-- ��������� ��� ��������� ���������� ������� pkg_Common.getSessionSerial
grant select on sys.v_$session to &userName
/



undefine userName
