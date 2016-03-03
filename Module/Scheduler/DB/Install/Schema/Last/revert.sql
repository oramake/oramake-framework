-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- ������

drop package pkg_Scheduler
/
drop package pkg_SchedulerLoad
/


-- ����

@oms-drop-type sch_log_t
@oms-drop-type sch_log_table_t
@oms-drop-type sch_batch_log_info_t


-- �������������

drop view sch_message_type
/

drop view v_sch_batch
/
drop view v_sch_batch_result
/
drop view v_sch_role_privilege
/
drop view v_sch_batch_root_log
/
drop view v_sch_operator_batch
/



-- ������� � ������ ( �� sch_log.sql)

drop index sch_log_ix_root_batch_date_log
/
drop synonym sch_log
/


-- ������� �����

@oms-drop-foreign-key sch_batch
@oms-drop-foreign-key sch_batch_content
@oms-drop-foreign-key sch_batch_role
@oms-drop-foreign-key sch_batch_type
@oms-drop-foreign-key sch_condition
@oms-drop-foreign-key sch_interval
@oms-drop-foreign-key sch_interval_type
@oms-drop-foreign-key sch_job
@oms-drop-foreign-key sch_load_condition_tmp
@oms-drop-foreign-key sch_load_interval_tmp
@oms-drop-foreign-key sch_load_schedule_tmp
@oms-drop-foreign-key sch_log
@oms-drop-foreign-key sch_message_type
@oms-drop-foreign-key sch_module_role_privilege
@oms-drop-foreign-key sch_privilege
@oms-drop-foreign-key sch_result
@oms-drop-foreign-key sch_schedule


-- �������

drop table sch_batch
/
drop table sch_batch_content
/
drop table sch_batch_role
/
drop table sch_batch_type
/
drop table sch_condition
/
drop table sch_interval
/
drop table sch_interval_type
/
drop table sch_job
/
drop table sch_load_condition_tmp
/
drop table sch_load_interval_tmp
/
drop table sch_load_schedule_tmp
/
drop table sch_log
/
drop table sch_message_type
/
drop table sch_module_role_privilege
/
drop table sch_privilege
/
drop table sch_result
/
drop table sch_schedule
/


-- ������������������

drop sequence sch_batch_content_seq
/
drop sequence sch_batch_role_seq
/
drop sequence sch_batch_seq
/
drop sequence sch_batch_type_seq
/
drop sequence sch_condition_seq
/
drop sequence sch_interval_seq
/
drop sequence sch_job_seq
/
drop sequence sch_log_seq
/
drop sequence sch_module_role_privilege_seq
/
drop sequence sch_result_seq
/
drop sequence sch_schedule_seq
/