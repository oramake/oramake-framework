-- script: Install/Config/after-action.sql
-- ��������, ����������� ����� ��������� ���������� ������.
--
-- ����������� ��������:
--  - ��������������� ����� ����������� ������ ������� ����� dbms_job
--    ( �������� <Install/Config/resume-batches.sql>);
--
-- ���������:
--  - ��� �������������� ��������� ������ ( INSTALL_VERSION=Last) ������ ��
--    �����������;
--

@oms-run resume-batches.sql "v_opt_save_job_queue"
