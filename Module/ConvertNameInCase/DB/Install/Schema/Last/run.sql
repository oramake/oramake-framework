-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.


-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql


-- �������

@oms-run ccs_case_exception.tab
@oms-run ccs_type_exception.tab


-- Outline-����������� �����������

@oms-run ccs_case_exception.con
@oms-run ccs_type_exception.con


-- ������������������

@oms-run ccs_case_exception_seq.sqs
