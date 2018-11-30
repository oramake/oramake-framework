-- script: Show/context-change.sql
-- Показывает изменение контекста выполнения по данным лога.
--
-- Параметры:
--
-- [<modulePattern>.]<contextTypePattern>[:<contextValueId>[:<maxRowCount>]]
--
-- где:
--
-- modulePattern              - Маска названия модуля для типа контекста
--                              (like по полю module_name представления
--                              <v_mod_module>)
--                              (по умолчанию без ограничений)
-- contextTypePattern         - Маска краткого наименования типа контекста
--                              (like по полю context_type_short_name таблицы
--                              <lg_context_type>)
--                              (по умолчанию без ограничений)
-- contextValueId             - Идентификатор, связанный с контекстом
--                              выполнения
--                              (по умолчанию без ограничений)
-- maxRowCount                - Максимальное число выводимых записей
--                              (последних по start_log_id)
--                              (по умолчанию 30)
--
--

var modulePattern varchar2(255)
var contextTypePattern varchar2(255)
var contextValueId number
var maxRowCount number

set feedback off

declare
  paramStr varchar2(255) := trim( '&1');
  len integer := coalesce( length( paramStr), 0);
  d1 integer;
  d2 integer;
  d3 integer;
  n integer;
begin
  d1 := instr( paramStr, '.', 1);
  d2 := instr( paramStr || ':', ':', d1 + 1);
  d3 := instr( paramStr || '::', ':', d2 + 1);
  :modulePattern := coalesce( substr( paramStr, 1, d1 - 1), '%');
  :contextTypePattern := coalesce( substr( paramStr, d1 + 1, d2 - d1 - 1), '%');
  :contextValueId := to_number( substr( paramStr, d2 + 1, d3 - d2 - 1));
  :maxRowCount := coalesce( to_number( substr( paramStr, d3 + 1)), 30);
end;
/

set feedback on


select
  a.*
from
  (
  select
    cc.open_log_id
    , md.module_name
    , ct.context_type_short_name
    , cc.context_value_id
    , cc.open_log_time_utc
    , cc.close_log_time_utc
    , trim(
        rtrim( rtrim(
          ltrim( to_char( cc.close_log_time_utc - cc.open_log_time_utc), '+0')
          , '0123456789'), '.')
      )
      as exec_time
    , cc.context_type_level
    , cc.sessionid
    , cc.close_log_id
    , cc.open_context_level
    , cc.close_context_level
    , cc.open_level_code
    , cc.open_message_value
    , cc.open_message_label
    , cc.close_level_code
    , cc.close_message_value
    , cc.close_message_label
    , cc.context_type_id
    , ct.module_id
    , md.svn_root as module_svn_root
  from
    lg_context_type ct
    inner join v_mod_module md
      on md.module_id = ct.module_id
    inner join v_lg_context_change cc
      on cc.context_type_id = ct.context_type_id
  where
    ct.context_type_short_name like :contextTypePattern escape '\'
    and md.module_name like :modulePattern escape '\'
    and (
      :contextValueId is null
      or cc.context_value_id = :contextValueId
    )
  order by
    cc.open_log_id desc
  ) a
where
  rownum <= :maxRowCount
order by
  a.open_log_id
/
