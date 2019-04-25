-- Индекс для выборки по идентификатору сессии и Id лога.
create index
  lg_log_ix_sessionid_logid
on
  lg_log (
    sessionid
    , log_id
  )
tablespace &indexTablespace
/

-- Индекс для выборки по времени логирования.
create index
  lg_log_ix_log_time
on
  lg_log (
    log_time
  )
tablespace &indexTablespace
/
