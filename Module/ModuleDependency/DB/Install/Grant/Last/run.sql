-- script: Install/Grant/Last/run.sql
-- ������ ���� �� ������� ������
--
-- ���������:
--   - toUserName - ������������, �������� ����� ���� ����� � ������� ��������
--                  �� ������� ������� �����

define toUserName = "&1"


grant select, insert, update, delete on md_object_dependency to &toUserName
/
create or replace synonym &toUserName..md_object_dependency for md_object_dependency 
/

undefine toUserName
