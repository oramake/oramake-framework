-- script: Install/Config/before-action.sql
-- ��������, ����������� ����� ���������� ���������� ������.
--
-- ����������� ��������:
--  - � ������ STOP_JOB=1 ������������� ���������� ���� ������� ��;
--    ( �������� <Install/Config/stop-job.sql>);
--  - � ��������� ������ ������������ �������� ������� ������
--    ( � ��������� ��������� ������������);
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'stop-job.sql' else 'stop-batch.sql' end || '"

@@&runScript "v_ml_save_job_queue"
