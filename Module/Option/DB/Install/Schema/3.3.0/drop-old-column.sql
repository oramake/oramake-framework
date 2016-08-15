alter table
  opt_option_new
drop constraint
  opt_option_uk_old_option_short
drop index
/

alter table
  opt_option_new
drop constraint
  opt_option_ck_osname_not_test
/

alter table
  opt_option_new
drop constraint
  opt_option_ck_old_mask_id
/

alter table
  opt_option_new
drop (
  old_option_short_name
  , old_mask_id
  , old_option_name_test
)
/



alter table
  opt_option_history
drop (
  old_option_short_name
  , old_mask_id
  , old_option_name_test
)
/



alter table
  opt_value
drop constraint
  opt_value_uk_old_opt_value_id
drop index
/

alter table
  opt_value
drop constraint
  opt_value_ck_old_option
/

alter table
  opt_value
drop constraint
  opt_value_ck_old_ov_del_dt
/

alter table
  opt_value
drop constraint
  opt_value_ck_old_op_del_dt
/

drop index
  opt_value_ix_old_option_id
/

alter table
  opt_value
drop (
  old_option_value_id
  , old_option_id
  , old_option_value_del_date
  , old_option_del_date
)
/



alter table
  opt_value_history
drop constraint
  opt_value_history_ck_old_opt
/

alter table
  opt_value_history
drop constraint
  opt_value_history_ck_o_ov_d_dt
/

alter table
  opt_value_history
drop constraint
  opt_value_history_ck_o_op_d_dt
/

drop index
  opt_value_history_ix_old_opt_v
/

drop index
  opt_value_history_ix_old_opt
/

alter table
  opt_value_history
drop (
  old_option_value_id
  , old_option_id
  , old_option_value_del_date
  , old_option_del_date
)
/
