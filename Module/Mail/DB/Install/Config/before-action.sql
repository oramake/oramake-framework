-- script: Install/Config/before-action.sql
-- ��������, ����������� ����� ���������� ���������� ������.
--
-- ����������� ��������:
--  - � ������ STOP_JOB=1 ������������� ���������� ���� ������� ��;
--    ( �������� <Install/Config/stop-batches.sql>);
--  - � ��������� ������ ������������ �������� ������� ������;
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'stop-batches.sql' else 'deactivate-batch.sql' end || '"

@@&runScript "v_ml_save_job_queue"
