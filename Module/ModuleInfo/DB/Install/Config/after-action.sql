-- script: Install/Config/after-action.sql
-- � ������ ������� � �� ������ Scheduler ��������������� ����� �����������
-- ������ ������� � �� � ������� ������� <Install/Config/resume-batches.sql>.
--
-- ���������:
--  - ������� ������ Scheduler ����������� �� ����������� ������� ��
--    v_sch_batch �������� ������� batch_short_name;
--  - ��� �������������� ��������� ( INSTALL_VERSION=Last) ������ ��
--    �����������;
--

define runScript = ""
@oms-default runScript "' || ( select 'resume-batches.sql' from all_tab_columns where table_name='V_SCH_BATCH' and column_name = 'BATCH_SHORT_NAME') || '"

@oms-run "&runScript" "v_mod_save_job_queue"
