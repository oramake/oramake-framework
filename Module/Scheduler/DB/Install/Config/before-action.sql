-- script: Install/Config/before-action.sql
-- ��������, ����������� ����� ���������� ���������� ������.
--
-- ����������� ��������:
--  - � ������ STOP_JOB=1 ������������� ���������� ���� ������� ��;
--    ( �������� <Install/Config/stop-job.sql>);
--  - � ��������� ������ ������������ �������� ������� ���� �������
--    ( � ��������� ��������� ������������);
--
-- ���������:
--  - ��� �������������� ��������� ������ ( INSTALL_VERSION=Last) ������ ��
--    �����������;
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'stop-job.sql' else 'stop-all-batch.sql' end || '"

@@&runScript "v_sch_save_job_queue"
