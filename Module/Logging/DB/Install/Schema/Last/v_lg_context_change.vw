-- view: v_lg_context_change
-- Изменение контекста выполнения по данным лога.
--
create or replace force view
  v_lg_context_change
as
select
  -- SVN root: Oracle/Module/Logging
  a.context_type_id
  , a.context_value_id
  , a.open_context_log_time_utc as open_log_time_utc
  , max(
      case a.open_context_flag
        when  0 then a.close_log_time_utc
        when -1 then a.open_context_log_time_utc
      end
    )
    as close_log_time_utc
  , max( a.context_type_level) as context_type_level
  , max( a.sessionid) as sessionid
  , a.open_context_log_id as open_log_id
  , max(
      case a.open_context_flag
        when  0 then a.close_log_id
        when -1 then a.open_context_log_id
      end
    )
    as close_log_id
  , max( case when a.open_context_flag in (1,-1) then a.context_level end)
    as open_context_level
  , max( case when a.open_context_flag in (0,-1) then a.context_level end)
    as close_context_level
  , max(case when a.open_context_flag in (1,-1) then a.level_code end)
    as open_level_code
  , max(case when a.open_context_flag in (1,-1) then a.message_value end)
    as open_message_value
  , max(case when a.open_context_flag in (1,-1) then a.message_label end)
    as open_message_label
  , max(case when a.open_context_flag in (0,-1) then a.level_code end)
    as close_level_code
  , max(case when a.open_context_flag in (0,-1) then a.message_value end)
    as close_message_value
  , max(case when a.open_context_flag in (0,-1) then a.message_label end)
    as close_message_label
from
  (
  select /*+ index( t lg_log_ix_context_change) */
    t.context_type_id
    , t.context_value_id
    , sys_extract_utc( t.open_context_log_time) as open_context_log_time_utc
    , t.open_context_log_id
    , t.open_context_flag
    , t.context_type_level
    , case when t.context_type_id is not null then
        t.sessionid
      end
      as sessionid
    , case when t.context_type_id is not null then
        t.level_code
      end
      as level_code
    , case when t.context_type_id is not null then
        t.message_value
      end
      as message_value
    , case when t.context_type_id is not null then
        t.message_label
      end
      as message_label
    , case when t.context_type_id is not null then
        t.context_level
      end
      as context_level
    , case when t.open_context_flag = 0 then
        t.log_id
      end
      as close_log_id
    , sys_extract_utc(
        case when t.open_context_flag = 0 then
          t.log_time
        end
      )
      as close_log_time_utc
  from
    lg_log t
  where
    t.context_type_id is not null
  ) a
group by
  a.context_type_id
  , a.context_value_id
  , a.open_context_log_time_utc
  , a.open_context_log_id
/



comment on table v_lg_context_change is
  'Изменение контекста выполнения по данным лога [SVN root: Oracle/Module/Logging]'
/
comment on column v_lg_context_change.context_type_id is
  'Id типа контекста выполнения'
/
comment on column v_lg_context_change.context_value_id is
  'Идентификатор, связанный с контекстом выполнения'
/
comment on column v_lg_context_change.open_log_time_utc is
  'Время открытия контекста (по UTC)'
/
comment on column v_lg_context_change.close_log_time_utc is
  'Время закрытия контекста (по UTC, null если контекст не был закрыт)'
/
comment on column v_lg_context_change.context_type_level is
  'Уровень самовложенности типа контекста выполнения (начиная с 1, null для ассоциативного контекста)'
/
comment on column v_lg_context_change.sessionid is
  'Идентификатор сессии (значение v$session.audsid)'
/
comment on column v_lg_context_change.open_log_id is
  'Id записи лога открытия контекста'
/
comment on column v_lg_context_change.close_log_id is
  'Id записи лога закрытия контекста (null если контекст не был закрыт)'
/
comment on column v_lg_context_change.open_context_level is
  'Уровень вложенного контекста выполнения при открытии (0 при отсутствии вложенного контекста)'
/
comment on column v_lg_context_change.close_context_level is
  'Уровень вложенного контекста выполнения при закрытии (0 при отсутствии вложенного контекста)'
/
comment on column v_lg_context_change.open_level_code is
  'Код уровня логирования сообщения по открытию контекста'
/
comment on column v_lg_context_change.open_message_value is
  'Целочисленное значение, связанное с сообщением по открытию контекста'
/
comment on column v_lg_context_change.open_message_label is
  'Строковое значение, связанное с сообщением по открытию контекста'
/
comment on column v_lg_context_change.close_level_code is
  'Код уровня логирования сообщения по закрытию контекста'
/
comment on column v_lg_context_change.close_message_value is
  'Целочисленное значение, связанное с сообщением по закрытию контекста'
/
comment on column v_lg_context_change.close_message_label is
  'Строковое значение, связанное с сообщением по закрытию контекста'
/
