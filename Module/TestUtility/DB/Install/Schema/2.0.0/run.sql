-- script: Install/Schema/1.2.0/run.sql
-- ���������� �������� ����� �� ������ 1.2.0.
--
-- �������� ���������:
--  - �������� ������ <tsu_job>, <tsu_job_header>, <tsu_test_run>.
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run Install/Schema/Last/run.sql
