-- view: v_lg_log
-- Лог работы программных модулей (с полным текстом сообщений и текстовыми
-- данными).
--
create or replace force view
  v_lg_log
as
select
  -- SVN root: Oracle/Module/Logging
  t.log_id
  , t.sessionid
  , t.level_code
  , t.message_value
  , t.message_label
  , t.message_text
  , t.long_message_text_flag
  , t.text_data_flag
  , t.context_level
  , t.context_type_id
  , t.context_value_id
  , t.open_context_log_id
  , t.open_context_log_time
  , t.open_context_flag
  , t.context_type_level
  , t.module_name
  , t.object_name
  , t.module_id
  , t.log_time
  , t.date_ins
  , t.operator_id
  , t.long_message_text
  , case when t.long_message_text_flag = 1 then
      t.long_message_text
    else
      to_clob( t.message_text)
    end
    as full_message_text
  , t.text_data
from
  (
  select
    lg.*
    , case when lg.long_message_text_flag = 1 then
        (
        select
          ld.long_message_text
        from
          lg_log_data ld
        where
          ld.log_id = lg.log_id
        )
      end
      as long_message_text
    , case when lg.text_data_flag = 1 then
        (
        select
          ld.text_data
        from
          lg_log_data ld
        where
          ld.log_id = lg.log_id
        )
      end
      as text_data
  from
    lg_log lg
  ) t
/



comment on table v_lg_log is
  'Лог работы программных модулей (с полным текстом сообщений и текстовыми данными) [ SVN root: Oracle/Module/Logging]'
/
comment on column v_lg_log.long_message_text is
  'Текст длинного сообщения (длиной от 4001 до 32767 символов)'
/
comment on column v_lg_log.full_message_text is
  'Полный текст сообщения'
/
comment on column v_lg_log.text_data is
  'Текстовые данные, связанные с сообщением'
/
-- Устанавливает комментарии к полям
@oms-run Install/Schema/Last/set-log-comment.sql v_lg_log
