-- script: DB\Install\Grant\Last\run.sql
-- ������ ����� �� ������������� ������.
--
-- ���������:
-- toUserName                  - ��� ������������, �������� �������� �����
--
-- ���������:
--  - ������ ����������� ��� �������������, �������� ����������� ������� ������
--    ;
--

define toUserName = "&1"



grant
  select, delete
on
  svn_file_tmp
to
  &toUserName
/

create or replace synonym
  &toUserName..svn_file_tmp
for
  svn_file_tmp
/


grant
  execute
on
  pkg_Subversion
to
  &toUserName
/
create or replace synonym
  &toUserName..pkg_Subversion
for
  pkg_Subversion
/



undefine toUserName
