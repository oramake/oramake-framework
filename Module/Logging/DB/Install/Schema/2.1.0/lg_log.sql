@oms-run rename-to-lg_log_old.sql

create table
  lg_log
(
  log_id                          integer                             not null
  , sessionid                     number                              not null
  , level_code                    varchar2(10)                        not null
  , message_value                 integer
  , message_label                 varchar2(128)
  , message_text                  varchar2(4000)                      not null
  , context_level                 integer
  , context_type_id               integer
  , context_value_id              integer
  , open_context_log_id           integer
  , open_context_log_time         timestamp with time zone
  , open_context_flag             number(1)
  , context_type_level            integer
  , module_name                   varchar2(128)
  , object_name                   varchar2(128)
  , module_id                     integer
  , log_time                      timestamp with time zone
                                    default current_timestamp         not null
  , date_ins                      date                default sysdate not null
  , operator_id                   integer
  , constraint lg_log_pk primary key
    ( log_id)
    using index tablespace &indexTablespace
  , constraint lg_log_ck_level_code check
    (level_code not in ('ALL','OFF'))
  , constraint lg_log_ck_context_level check
    (context_level >= 0)
  , constraint lg_log_ck_open_context_flag check
    (open_context_flag in (-1,0,1))
  , constraint lg_log_ck_context_type_level check
    (context_type_level is null or context_type_level is not null and context_type_level >= 1 and context_level is not null and context_level >= context_type_level)
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
)
/

@oms-run Install/Schema/Last/lg_log.comment.sql

@oms-run copy-log.sql

@oms-run create-lg_log-index.sql
@oms-run create-lg_log-fk.sql
