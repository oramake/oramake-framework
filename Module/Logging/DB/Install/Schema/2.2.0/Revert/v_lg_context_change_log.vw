-- view: v_lg_context_change_log
-- Лог изменения контекста выполнения.
--
create or replace force view
  v_lg_context_change_log
as
select
  -- SVN root: Oracle/Module/Logging
  lg.log_id
  , lg.sessionid
  , lg.log_time
  , lg.context_type_id
  , lg.context_value_id
  , lg.open_context_flag
  , lg.open_context_log_id as open_log_id
  , case when lg.open_context_flag in ( 0, -1) then
      lg.log_id
    else
      cc.close_log_id
    end
    as close_log_id
  , sys_extract_utc( lg.open_context_log_time) as open_log_time_utc
  , case when lg.open_context_flag in ( 0, -1) then
      sys_extract_utc( lg.log_time)
    else
      cc.close_log_time_utc
    end
    as close_log_time_utc
  , case when lg.open_context_flag in ( 1, -1) then
      lg.context_level
    else
      co.context_level
    end
    as open_context_level
  , case when lg.open_context_flag in ( 0, -1) then
      lg.context_level
    else
      cc.context_level
    end
    as close_context_level
  , case when lg.open_context_flag in ( 1, -1) then
      lg.level_code
    else
      co.level_code
    end
    as open_level_code
  , case when lg.open_context_flag in ( 1, -1) then
      lg.message_value
    else
      co.message_value
    end
    as open_message_value
  , case when lg.open_context_flag in ( 1, -1) then
      lg.message_label
    else
      co.message_label
    end
    as open_message_label
  , case when lg.open_context_flag in ( 0, -1) then
      lg.level_code
    else
      cc.level_code
    end
    as close_level_code
  , case when lg.open_context_flag in ( 0, -1) then
      lg.message_value
    else
      cc.message_value
    end
    as close_message_value
  , case when lg.open_context_flag in ( 0, -1) then
      lg.message_label
    else
      cc.message_label
    end
    as close_message_label
  , lg.level_code
  , lg.message_value
  , lg.message_label
  , lg.message_text
  , lg.context_level
  , lg.open_context_log_id
  , lg.open_context_log_time
  , lg.context_type_level
  , lg.module_name
  , lg.object_name
  , lg.module_id
  , lg.date_ins
  , lg.operator_id
from
  lg_log lg
  left join
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
    ) co
    on co.context_type_id = lg.context_type_id
      and (
        lg.context_value_id is not null
          and co.context_value_id = lg.context_value_id
        or lg.context_value_id is null
          and co.context_value_id is null
      )
      and co.open_context_log_time_utc
        = sys_extract_utc( lg.open_context_log_time)
      and co.open_context_log_id = lg.open_context_log_id
      and co.open_context_flag = 1
      and lg.open_context_flag = 0
  left join
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
    ) cc
    on cc.context_type_id = lg.context_type_id
      and (
        lg.context_value_id is not null
          and cc.context_value_id = lg.context_value_id
        or lg.context_value_id is null
          and cc.context_value_id is null
      )
      and cc.open_context_log_time_utc
        = sys_extract_utc( lg.open_context_log_time)
      and cc.open_context_log_id = lg.open_context_log_id
      and cc.open_context_flag = 0
      and lg.open_context_flag in ( 1, -1)
where
  lg.context_type_id is not null
/



comment on table v_lg_context_change_log is
  'Лог изменения контекста выполнения [SVN root: Oracle/Module/Logging]'
/
comment on column v_lg_context_change_log.log_id is
  'Id записи лога'
/
comment on column v_lg_context_change_log.sessionid is
  'Идентификатор сессии (значение v$session.audsid)'
/
comment on column v_lg_context_change_log.log_time is
  'Время формирования записи лога'
/
comment on column v_lg_context_change_log.context_type_id is
  'Id типа контекста выполнения'
/
comment on column v_lg_context_change_log.context_value_id is
  'Идентификатор, связанный с контекстом выполнения'
/
comment on column v_lg_context_change_log.open_context_flag is
  'Контекст выполнения: Флаг открытия контекста выполнения (1 - открытие контекста, 0 - закрытие контекста, -1 - открытие и немедленное закрытие контекста)'
/
comment on column v_lg_context_change_log.open_log_id is
  'Id записи лога открытия контекста'
/
comment on column v_lg_context_change_log.close_log_id is
  'Id записи лога закрытия контекста (null если контекст не был закрыт)'
/
comment on column v_lg_context_change_log.open_log_time_utc is
  'Время открытия контекста (по UTC)'
/
comment on column v_lg_context_change_log.close_log_time_utc is
  'Время закрытия контекста (по UTC, null если контекст не был закрыт)'
/
comment on column v_lg_context_change_log.open_context_level is
  'Уровень вложенного контекста выполнения при открытии (0 при отсутствии вложенного контекста)'
/
comment on column v_lg_context_change_log.close_context_level is
  'Уровень вложенного контекста выполнения при закрытии (0 при отсутствии вложенного контекста)'
/
comment on column v_lg_context_change_log.open_level_code is
  'Код уровня логирования сообщения по открытию контекста'
/
comment on column v_lg_context_change_log.open_message_value is
  'Целочисленное значение, связанное с сообщением по открытию контекста'
/
comment on column v_lg_context_change_log.open_message_label is
  'Строковое значение, связанное с сообщением по открытию контекста'
/
comment on column v_lg_context_change_log.close_level_code is
  'Код уровня логирования сообщения по закрытию контекста'
/
comment on column v_lg_context_change_log.close_message_value is
  'Целочисленное значение, связанное с сообщением по закрытию контекста'
/
comment on column v_lg_context_change_log.close_message_label is
  'Строковое значение, связанное с сообщением по закрытию контекста'
/
comment on column v_lg_context_change_log.level_code is
  'Код уровня логирования'
/
comment on column v_lg_context_change_log.message_value is
  'Целочисленное значение, связанное с сообщением'
/
comment on column v_lg_context_change_log.message_label is
  'Строковое значение, связанное с сообщением'
/
comment on column v_lg_context_change_log.message_text is
  'Текст сообщения'
/
comment on column v_lg_context_change_log.context_level is
  'Контекст выполнения: Уровень вложенного контекста выполнения (0 при отсутствии вложенного и наличии ассоциативного контекста)'
/
comment on column v_lg_context_change_log.open_context_log_id is
  'Контекст выполнения: Id записи лога открытия открываемого/закрываемого контекста (равен log_id при открытии контекста)'
/
comment on column v_lg_context_change_log.open_context_log_time is
  'Контекст выполнения: Время формирования записи лога открытия открываемого/закрываемого контекста (равен log_time при открытии контекста)'
/
comment on column v_lg_context_change_log.context_type_level is
  'Уровень самовложенности типа контекста выполнения (начиная с 1, null для ассоциативного контекста)'
/
comment on column v_lg_context_change_log.module_name is
  'Имя модуля, добавившего запись'
/
comment on column v_lg_context_change_log.object_name is
  'Имя объекта модуля (пакета, типа, скрипта), добавившего запись'
/
comment on column v_lg_context_change_log.module_id is
  'Id модуля, добавившего запись (если удалось определить)'
/
comment on column v_lg_context_change_log.date_ins is
  'Дата добавления записи в таблицу'
/
comment on column v_lg_context_change_log.operator_id is
  'Id оператора ( из модуля AccessOperator)'
/
