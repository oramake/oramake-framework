-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.


-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql


-- �������

@oms-run prm_batch_config.tab
@oms-run prm_registered_session.tab
@oms-run prm_session_action.tab


-- Outline-����������� �����������

@oms-run prm_session_action.con
