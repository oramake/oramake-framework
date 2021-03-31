-- script: Show/context.sql
-- Показывает запись лога и контексты выполнения, открытые на момент ее
-- формирования.
--
-- Параметры:
-- logId                      - Id записи лога
--                              (по умолчанию Id последней записи лога)
--

var logId number

set feedback off

declare
  paramStr varchar2(255) := trim( '&1');
begin
  :logId := to_number( paramStr);
  if :logId is null then
    select
      max( t.log_id)
    into :logId
    from
      lg_log t
    ;
  end if;
end;
/

set feedback on

column full_message_text_ format A200 head MESSAGE_TEXT

select
  lg.log_id
  , lg.level_code
  , decode( lg.message_level
      , 1, ''
      , lpad( '  ', (lg.message_level - 1) * 2, ' ')
    )
    || lg.full_message_text
    as full_message_text_
  , lg.context_level
  , md.module_name as context_module_name
  , ct.context_type_short_name
  , lg.message_value
  , lg.message_label
  , lg.context_type_id
  , lg.context_type_level
  , lg.context_value_id
  , lg.open_context_flag
  , lg.close_log_id
  , lg.close_log_time_utc
  , lg.close_level_code
  , lg.close_message_value
  , lg.close_message_label
  , ct.module_id as context_module_id
  , lg.sessionid
  , lg.module_name
  , lg.object_name
  , lg.module_id
  , lg.log_time
  , lg.date_ins
  , lg.operator_id
  , lg.long_message_text_flag
  , lg.text_data_flag
  , lg.text_data
from
  (
  select
    a.*
    , greatest(
        a.context_level
          + case when a.open_context_flag in ( 1, -1) then 0 else 1 end
        , 0
      )
      as message_level
  from
    (
    select
      lg.*
      , ccl.close_log_id
      , ccl.close_log_time_utc
      , ccl.close_level_code
      , ccl.close_message_value
      , ccl.close_message_label
    from
      lg_log lg0
      inner join v_lg_context_change_log ccl
        on ccl.sessionid = lg0.sessionid
          and ccl.log_id <= lg0.log_id
          and ccl.open_context_flag != 0
      inner join v_lg_log lg
        on lg.log_id = ccl.log_id
    where
      lg0.log_id = :logId
      and lg0.log_id <= coalesce( ccl.close_log_id, lg0.log_id)
    union all
    select
      lg0.*
      , ccl.close_log_id
      , ccl.close_log_time_utc
      , ccl.close_level_code
      , ccl.close_message_value
      , ccl.close_message_label
    from
      v_lg_log lg0
      left join v_lg_context_change_log ccl
        on ccl.log_id = lg0.log_id
    where
      lg0.log_id = :logId
      and nullif( lg0.open_context_flag, 0) is null
    ) a
  ) lg
  left join lg_context_type ct
    on ct.context_type_id = lg.context_type_id
  left join v_mod_module md
    on md.module_id = ct.module_id
order by
  1
/

column full_message_text_ clear
