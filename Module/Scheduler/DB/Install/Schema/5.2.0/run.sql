-- script: Install/Schema/5.2.0/run.sql
-- ���������� �������� ����� �� ������ 5.2.0.
--
-- �������� ���������:
--  - ������ oracle_job_id �� active_flag � ������� <sch_batch>;
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run sch_batch.sql
