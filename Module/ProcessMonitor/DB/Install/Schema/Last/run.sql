-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ������ �������� �����
@oms-set-indexTablespace

@oms-run prm_registered_session.tab
@oms-run prm_session_action.tab
@oms-run prm_batch_config.tab

@oms-run prm_session_action.con