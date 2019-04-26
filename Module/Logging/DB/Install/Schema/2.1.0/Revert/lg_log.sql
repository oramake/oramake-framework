alter table
  lg_log
modify (
  sessionid  null
  , level_code null
  , log_time null
)
/

alter table
  lg_log
modify (
  sessionid  not null
      enable novalidate
  , level_code not null
      enable novalidate
  , log_time not null
      enable novalidate
)
/

alter table
  lg_log
add (
  parent_log_id                 integer
  , message_type_code             varchar2(10)
)
/

update
  lg_log t
set
  t.message_type_code =
    case t.level_code
      when 'FATAL' then
        'ERROR'
      when 'ERROR' then
        'ERROR'
      when 'WARN' then
        'WARNING'
      when 'INFO' then
        'INFO'
      when 'DEBUG' then
        'DEBUG'
      when 'TRACE' then
        'DEBUG'
    end
where
  t.message_type_code is null
/

commit
/

alter table
  lg_log
modify (
  message_type_code not null
      enable novalidate
)
/

create index
  lg_log_ix_parent_log_id
on
  lg_log (
    parent_log_id
  )
tablespace &indexTablespace
/


alter table
  lg_log
add constraint
  lg_log_fk_parent_log_id
foreign key
  ( parent_log_id)
references
  lg_log (
    log_id
  )
/

alter table
  lg_log
add constraint
  lg_log_fk_message_type_code
foreign key
  ( message_type_code)
references
  lg_message_type (
    message_type_code
  )
/
