-- script: Install/Grant/Last/run.sql
-- ������ ����� �� ������������� ������ ���� �������������.
-- ����������� � ������� ������ ���� ������������ public � �������� ���������
-- ���������.
--
-- ���������:
--  - ��� ��������� ���������� ������� ��������� ����� �� ��������
--    ��������� ���������;



grant execute on dyn_cursor_cache_t to public
/
create or replace public synonym dyn_cursor_cache_t for dyn_cursor_cache_t
/

grant execute on dyn_dynamic_sql_t to public
/
create or replace public synonym dyn_dynamic_sql_t for dyn_dynamic_sql_t
/
