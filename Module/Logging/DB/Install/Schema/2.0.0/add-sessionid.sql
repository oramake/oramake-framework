alter table
  lg_log
add (
  sessionid                     number
)
/

create index
  lg_log_ix_sessionid_logid
on
  lg_log (
    sessionid
    , log_id
  )
tablespace &indexTablespace
/

alter table
  lg_log
modify (
  sessionid  not null
      enable novalidate
)
/
