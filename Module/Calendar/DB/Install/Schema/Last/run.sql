-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.


-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql


-- �������

@oms-run cdr_day.tab
@oms-run cdr_day_type.tab


-- Outline-����������� �����������

@oms-run cdr_day.con
@oms-run cdr_day_type.con
