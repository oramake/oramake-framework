-- script: Install/Grant/Last/run.sql
-- ������ ���� �� ������������� ������.
--
-- 1                          - ������������ ��� ������ ����
--

define toUserName=&1

grant execute on pkg_Mail to &toUserName
/
create or replace synonym &toUserName..pkg_Mail for pkg_Mail
/


undefine toUserName
