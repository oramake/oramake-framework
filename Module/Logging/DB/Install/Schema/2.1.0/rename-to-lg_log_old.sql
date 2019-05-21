alter table
  lg_log
rename to
  lg_log_old
/

alter table lg_log_old drop constraint lg_log_fk_level_code
/
alter table lg_log_old drop constraint lg_log_fk_module_id
/
alter table lg_log_old drop constraint lg_log_fk_parent_log_id
/
alter table lg_log_old drop constraint lg_log_fk_message_type_code
/
alter table lg_log_old drop constraint lg_log_ck_context_level
/
alter table lg_log_old drop constraint lg_log_ck_open_context_flag
/
alter table lg_log_old drop constraint lg_log_ck_context_type_level
/
alter table lg_log_old drop constraint lg_log_ck_context_change
/
alter table lg_log_old drop constraint lg_log_ck_level_code
/
alter table lg_log_old drop constraint lg_log_pk drop index
/

@oms-run Install/Schema/2.1.0/AccessOperatorAddon/drop-lg_log-fk-op.sql

drop index lg_log_ix_context_change
/
drop index lg_log_ix_log_time
/
drop index lg_log_ix_parent_log_id
/
drop index lg_log_ix_sessionid_logid
/

drop trigger lg_log_bi_define
/
