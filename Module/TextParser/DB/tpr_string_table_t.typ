-- ���� �������, ����� �� ���� ������ ��� �������� ��-�� ������������
@oms-drop-type tpr_string_table_t

-- dbtype: tpr_string_table_t
-- ������� ����� ��� ������������� � ������� <tpr_csv_iterator_t>.
create or replace type tpr_string_table_t
as table of varchar2(32767)
/
