-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- ������

drop package pkg_ProcessMonitor
/
drop package pkg_ProcessMonitorBase
/
drop package pkg_ProcessMonitorUtility
/


-- �������������

drop view v_prm_execution_action
/
drop view v_prm_registered_session
/
drop view v_prm_session_action
/
drop view v_prm_session_existence
/
drop view v_prm_session_memory
/


-- ������� �����

@oms-drop-foreign-key prm_batch_config
@oms-drop-foreign-key prm_registered_session
@oms-drop-foreign-key prm_session_action


-- �������

drop table prm_batch_config
/
drop table prm_registered_session
/
drop table prm_session_action
/
