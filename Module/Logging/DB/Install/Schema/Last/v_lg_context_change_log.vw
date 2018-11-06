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
  , coalesce( cc1.open_log_id, cc2.open_log_id) as open_log_id
  , coalesce( cc1.close_log_id, cc2.close_log_id) as close_log_id
  , coalesce( cc1.open_log_time_utc, cc2.open_log_time_utc)
    as open_log_time_utc
  , coalesce( cc1.close_log_time_utc, cc2.close_log_time_utc)
    as close_log_time_utc
  , coalesce( cc1.open_context_level, cc2.open_context_level)
    as open_context_level
  , coalesce( cc1.close_context_level, cc2.close_context_level)
    as close_context_level
  , coalesce( cc1.open_level_code, cc2.open_level_code)
    as open_level_code
  , coalesce( cc1.open_message_value, cc2.open_message_value)
    as open_message_value
  , coalesce( cc1.open_message_label, cc2.open_message_label)
    as open_message_label
  , coalesce( cc1.close_level_code, cc2.close_level_code)
    as close_level_code
  , coalesce( cc1.close_message_value, cc2.close_message_value)
    as close_message_value
  , coalesce( cc1.close_message_label    , cc2.close_message_label)
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
  left join v_lg_context_change cc1
    on cc1.context_type_id = lg.context_type_id
      and cc1.context_value_id = lg.context_value_id
      and cc1.open_log_time_utc = sys_extract_utc( lg.open_context_log_time)
      and cc1.open_log_id = lg.open_context_log_id
  left join v_lg_context_change cc2
    on cc2.context_type_id = lg.context_type_id
      and cc2.context_value_id is null
        and lg.context_value_id is null
      and cc2.open_log_time_utc = sys_extract_utc( lg.open_context_log_time)
      and cc2.open_log_id = lg.open_context_log_id
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
  'Идентификатор сессии (значение v$session.audsid либо уникальное отрицательное значение если v$session.audsid равно 0)'
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
