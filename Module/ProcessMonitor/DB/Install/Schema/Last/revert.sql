-- script: Install/Schema/Last/revert.sql
-- ƒеинстал€ци€ последней версии объектов схемы
drop view v_prm_execution_action
/
drop view v_prm_session_action
/
drop view v_prm_session_existence
/
drop view v_prm_registered_session
/

drop package pkg_ProcessMonitor
/
drop package pkg_ProcessMonitorUtility
/
drop package pkg_ProcessMonitorBase
/

@oms-set-indexTablespace

drop table prm_session_action
/
drop table prm_registered_session
/
drop table prm_batch_config
/


drop sequence prm_registered_session_seq
/
drop sequence prm_session_action_seq
/