-- script: Install/Config/after-action.sql
-- � ������ STOP_JOB=1 ��������������� ����� ����������� ������ ������� � ��
-- � ������� ������� <Install/Config/resume-batches.sql>.
--
-- ���������:
--  - ��� �������������� ��������� ( INSTALL_VERSION=Last) ������ ��
--    �����������;
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'resume-batches.sql' end || '"

@oms-run "&runScript" "v_wbu_save_job_queue"
