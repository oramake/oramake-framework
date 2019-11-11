-- script: Install/Config/after-action.sql
-- ��������, ����������� ����� ��������� ���������� ������.
--
-- ����������� ��������:
--  - � ������ STOP_JOB=1 ��������������� ����� ����������� ������ �������
--    ����� dbms_job ( �������� <Install/Config/resume-job.sql>);
--  - � ��������� ������ �������� ���������� �������� ������� ���� �������
--    ( � ��������� ������� ������������);
--
-- ���������:
--  - ��� �������������� ��������� ������ ( INSTALL_VERSION=Last) ������ ��
--    �����������;
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'resume-job.sql' else 'resume-all-batch.sql' end || '"

@@&runScript "v_sch_save_job_queue"


@@compile_all_invalid.sql