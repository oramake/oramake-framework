-- script: Show/log.sql
-- Показывает записи лога.
--
-- Параметры:
--
-- <logId>[:<maxRowCount>]
--
-- где:
--
-- logId                      - Id записи лога
--                              (по умолчанию выводятся последние по log_id
--                              записи лога согласно значению maxRowCount)
-- maxRowCount                - Максимальное число выводимых записей
--                              (по умолчанию 30)
--

var logId number
var maxRowCount number

set feedback off

declare
  paramStr varchar2(255) := trim( '&1');
  d1 integer;
begin
  d1 := instr( paramStr || ':', ':');
  :logId := to_number( substr( paramStr, 1, d1 - 1));
  :maxRowCount := coalesce( to_number( substr( paramStr, d1 + 1)), 30);
end;
/

set feedback on



select
  lg.log_id
  , lg.level_code
  , lg.message_text
  , lg.message_value
  , lg.message_label
  , lg.context_level
  , lg.context_type_id
  , lg.context_value_id
  , lg.open_context_log_id
  , lg.open_context_log_time
  , lg.open_context_flag
  , lg.context_type_level
  , lg.sessionid
  , lg.module_name
  , lg.object_name
  , lg.module_id
  , lg.log_time
  , lg.date_ins
  , lg.operator_id
from
  (
  select
    lg.*
  from
    lg_log lg
  where
    lg.log_id = :logId
  union all
  select
    a.*
  from
    (
    select
      lg.*
    from
      lg_log lg
    where
      :logId is null
    order by
      lg.log_id desc
    ) a
  where
    rownum <= :maxRowCount
  order by
    1
  ) lg
where
  rownum <= :maxRowCount
/
