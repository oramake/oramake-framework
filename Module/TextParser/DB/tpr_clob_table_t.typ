-- ���� �������, ����� �� ���� ������ ��� �������� ��-�� ������������
@oms-drop-type tpr_clob_table_t

-- dbtype: tpr_clob_table_t
-- ������� CLOB ��� ������������� � ������� <tpr_csv_iterator_t>.
create or replace type tpr_clob_table_t
as table of clob
/
