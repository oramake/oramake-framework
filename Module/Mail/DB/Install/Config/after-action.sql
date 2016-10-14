-- script: Install/Config/after-action.sql
-- ��������, ����������� ����� ��������� ���������� ������.
--
-- ����������� ��������:
--  - � ������ STOP_JOB=1 ��������������� ����� ����������� ������ �������
--    ����� dbms_job ( �������� <Install/Config/resume-batches.sql>);
--  - � ��������� ������ �������� ���������� �������� ������� ������;
--
-- ���������:
--  - ��� �������������� ��������� ������ ( INSTALL_VERSION=Last) ������ ��
--    �����������;
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'resume-batches.sql' else 'reactivate-batch.sql' end || '"

@@&runScript "v_ml_save_job_queue"
