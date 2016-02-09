-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.

-- ������������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

-- �������

@oms-run cmn_database_config.tab
@oms-run cmn_sequence.tab
@oms-run cmn_string_uid_tmp.tab

@oms-run fill_cmn_sequence.sql

-- ���������� ������� �������������
@oms-run str_concat.sql

@oms-run cmn_string_table_t.typ
