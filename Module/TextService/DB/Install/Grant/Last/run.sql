-- script: Install/Grant/Last/run.sql
-- ������ ����� �� ������������� ������.
--
-- ���������:
-- toUserName                  - ��� ������������, �������� �������� �����
--
-- ���������:
--  - ������ ����������� ��� �������������, �������� ����������� ������� ������
--   ;
--

define toUserName = "&1"



grant execute on pkg_TextUtility to &toUserName
/
create or replace synonym &toUserName..pkg_TextUtility for pkg_TextUtility
/

grant select on pkg_ContextSearchUtility to &toUserName
/
create or replace synonym &toUserName..pkg_ContextSearchUtility for pkg_ContextSearchUtility
/



undefine toUserName
