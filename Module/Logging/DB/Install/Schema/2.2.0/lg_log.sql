alter table
  lg_log
add (
  long_message_text_flag        number(1)
  , text_data_flag                number(1)
  , constraint lg_log_ck_long_message_text_fl check
    (long_message_text_flag in (1))
    enable novalidate
  , constraint lg_log_ck_text_data_flag check
    (text_data_flag in (1))
    enable novalidate
)
/

@oms-run Install/Schema/Last/set-log-comment.sql lg_log

@oms-run Install/Schema/validate-constraint.sql lg_log 10 ""
