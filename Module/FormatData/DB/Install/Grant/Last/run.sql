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



grant
  execute
on
  pkg_FormatData
to
  &toUserName
/

create or replace synonym
  &toUserName..pkg_FormatData
for
  pkg_FormatData
/



undefine toUserName
