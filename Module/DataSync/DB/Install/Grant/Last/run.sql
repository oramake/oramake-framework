-- script: Install/Grant/Last/run.sql
-- ������ ����� �� ������������� ������ ���� �������������.
-- ����������� � ������� ������ ���� ������������ public � �������� ���������
-- ���������.
--
-- ���������:
--  - ��� ��������� ���������� ������� ��������� ����� �� ��������
--    ��������� ���������;



grant execute on pkg_DataSync to public
/
create or replace public synonym pkg_DataSync for pkg_DataSync
/

grant execute, under on dsn_data_sync_t to public
/
create or replace public synonym dsn_data_sync_t for dsn_data_sync_t
/

grant execute, under on dsn_data_sync_source_t to public
/
create or replace public synonym
  dsn_data_sync_source_t
for
  dsn_data_sync_source_t
/
