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



-- ��������� ��� ������� pkg_Common.getSessionId
grant select on sys.v_$session to &userName
/
grant select on sys.v_$mystat to &userName
/



undefine userName
