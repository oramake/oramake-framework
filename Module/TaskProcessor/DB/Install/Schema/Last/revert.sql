--script: Install/Schema/Last/revert.sql
--ќтмен€ет установку модул€, удал€€ созданные объекты схемы.
--


drop package pkg_TaskProcessor
/
drop package pkg_TaskProcessorBase
/
drop package pkg_TaskProcessorHandler
/
drop package pkg_TaskProcessorUtility
/



drop view v_tp_task_type
/
drop view v_tp_task
/
drop view v_tp_active_task
/



drop table tp_task_log
/
drop table tp_file
/
drop table tp_file_status
/
drop table tp_task
/
drop table tp_task_type
/
drop table tp_task_status
/
drop table tp_result
/



drop sequence tp_task_seq
/
drop sequence tp_task_log_seq
/
drop sequence tp_task_type_seq
/
