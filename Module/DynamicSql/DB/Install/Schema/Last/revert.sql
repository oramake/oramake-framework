-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- ������

drop package pkg_DynamicSqlCache
/


-- ����

@oms-drop-type dyn_cursor_cache_t
@oms-drop-type dyn_dynamic_sql_t
