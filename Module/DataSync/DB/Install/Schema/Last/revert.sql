-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- ������

drop package pkg_DataSync
/


-- ����

@oms-drop-type dsn_data_sync_source_t
@oms-drop-type dsn_data_sync_t
