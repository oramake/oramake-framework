-- Индекс для отбора записей по изменению контекста выполнения указанного типа
-- (должен соответствовать выборке в представлении <v_lg_context_change>).
create index
  lg_log_ix_context_change
on
  lg_log (
    context_type_id
    , context_value_id
    , sys_extract_utc( open_context_log_time)
    , open_context_log_id
    , open_context_flag
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
