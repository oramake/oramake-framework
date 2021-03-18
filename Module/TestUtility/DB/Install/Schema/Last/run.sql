-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.


-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql


-- ������������������

@oms-run tsu_job_seq.sqs
@oms-run tsu_process_seq.sqs
@oms-run tsu_test_run_seq.sqs


-- �������

@oms-run tsu_job.tab
@oms-run tsu_process.tab
@oms-run tsu_test_run.tab


-- Outline-����������� �����������

@oms-run tsu_job.con
@oms-run tsu_test_run.con
