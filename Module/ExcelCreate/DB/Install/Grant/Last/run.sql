-- script: Install/Grant/Last/run.sql
-- ������ ����� �� ������������� ������ ���� �������������.
-- ����������� � ������� ������ ���� ������������ public � �������� ���������
-- ���������.
--
-- ���������:
--  - ��� ��������� ���������� ������� ��������� ����� �� ��������
--    ��������� ���������;



grant execute on pkg_ExcelCreate to public
/
create or replace public synonym pkg_ExcelCreate for pkg_ExcelCreate
/
grant execute on pkg_ExcelCreateUtility to public
/
create or replace public synonym pkg_ExcelCreateUtility for pkg_ExcelCreateUtility
/
