--script: Install/Config/after-action.sql
--��������, ����������� ����� ��������� ���������� ������.
--
--����������� ��������:
--  - ��������������� ����� ����������� ������ ������� ����� dbms_job
--    ( �������� <Install/Config/resume-batches.sql>);
--
--���������:
--  - ��� �������������� ��������� ������ ( INSTALL_VERSION=Last) ������ ��
--    �����������;
--

@@resume-batches.sql "v_dyn_save_job_queue"