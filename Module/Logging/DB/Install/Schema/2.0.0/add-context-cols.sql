alter table
  lg_log
add (
  context_level                 integer
  , context_type_id               integer
  , context_value_id              integer
  , open_context_log_id           integer
  , open_context_log_time         timestamp with time zone
  , open_context_flag             number(1)
  , context_type_level            integer
  , log_time                      timestamp with time zone
  , constraint lg_log_ck_context_level check
    (context_level >= 0)
    enable novalidate
  , constraint lg_log_ck_open_context_flag check
    (open_context_flag in (-1,0,1))
    enable novalidate
  , constraint lg_log_ck_context_type_level check
    (context_type_level is null or context_type_level is not null and context_type_level >= 1 and context_level is not null and context_level >= context_type_level)
    enable novalidate
  , constraint lg_log_ck_context_change check
(context_type_id is null
  and context_value_id is null
  and open_context_log_id is null
  and open_context_log_time is null
  and open_context_flag is null
  and context_type_level is null
or context_type_id is not null
  and open_context_log_id is not null
  and open_context_log_time is not null
  and open_context_flag is not null)
    enable novalidate
)
/

alter table
  lg_log
modify (
  log_time not null
      enable novalidate
)
/

alter table
  lg_log
modify (
  log_time default current_timestamp
)
/

drop index lg_log_ix_date_ins
/

create index
  lg_log_ix_context_change
on
  lg_log (
    context_type_id
    , context_value_id
    , sys_extract_utc( open_context_log_time)
    , open_context_log_id
    , open_context_flag desc
    , context_type_level
    , case when context_type_id is not null then
        sessionid
      end
    , case when context_type_id is not null then
        level_code
      end
    , case when context_type_id is not null then
        message_value
      end
    , case when context_type_id is not null then
        message_label
      end
    , case when context_type_id is not null then
        context_level
      end
    , case when open_context_flag = 0 then
        log_id
      end
    , sys_extract_utc(
        case when open_context_flag = 0 then
          log_time
        end
      )
  )
tablespace &indexTablespace
/

create index
  lg_log_ix_log_time
on
  lg_log (
    log_time
  )
tablespace &indexTablespace
/




var jobText varchar2(1000)

set feedback off

begin
  :jobText := '
execute immediate
''alter table lg_log
  enable validate constraint lg_log_ck_context_level
  enable validate constraint lg_log_ck_open_context_flag
  enable validate constraint lg_log_ck_context_type_level
  enable validate constraint lg_log_ck_context_change
''
;
'
  ;
end;
/

set feedback on

@oms-run Install/Schema/add-install-job.sql "validate-context-check" "15" "' || :jobText || '"
