begin
  execute immediate
'
insert /*+ append */ into
  lg_log
(
  log_id
  , sessionid
  , level_code
  , message_value
  , message_label
  , message_text
  , context_level
  , context_type_id
  , context_value_id
  , open_context_log_id
  , open_context_log_time
  , open_context_flag
  , context_type_level
  , module_name
  , object_name
  , module_id
  , log_time
  , date_ins
  , operator_id
)
select
  log_id
  , sessionid
  , level_code
  , message_value
  , message_label
  , message_text
  , context_level
  , context_type_id
  , context_value_id
  , open_context_log_id
  , open_context_log_time
  , open_context_flag
  , context_type_level
  , module_name
  , object_name
  , module_id
  , log_time
  , date_ins
  , operator_id
from
  lg_log_old
where
  -- ignore old log records
  sessionid is not null
'
  ;
  dbms_output.put_line( 'inserted rows: ' || sql%rowcount);
  execute immediate
    'drop table lg_log_old'
  ;
end;
/
