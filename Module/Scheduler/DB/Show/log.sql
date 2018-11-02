-- script: Show/log.sql
-- Показывает ветку лога выполнения операции над пакетным заданием.
--
-- Параметры:
-- startLogId                 - Id начальной записи лога выполнения операции
--                              (по умолчанию лог выполнения последнего
--                              запускавшегося пакетного задания)
-- batchPattern               - Маска краткого имени пакетного задания
--                              (like по полю batch_short_name), при этом
--                              показывается лог последнего запуска пакетного
--                              задания
--
-- Замечания:
-- - если значение параметра (без учета пробелов) начинается с цифры, то
--  оно рассматривается как startLogId, иначе как batchPattern;
-- - в случае, если под batchPattern подходит несколько пакетных заданий,
--  то выбирается задание с максимальным batch_id;
--

var startLogId number

set feedback off

declare
  paramStr varchar2(255) := trim( '&1');
begin
  if substr( paramStr, 1, 1) between '0' and '9' then
    :startLogId := to_number( paramStr);
  elsif paramStr is not null then
    select
      max( bo.start_log_id)
    into :startLogId
    from
      v_sch_batch_operation bo
    where
      -- pkg_SchedulerMain.Exec_BatchMsgLabel
      bo.batch_operation_label = 'EXEC'
      and bo.batch_id =
        (
        select
          max( b.batch_id)
        from
          sch_batch b
        where
          b.batch_short_name like paramStr escape '\'
        )
    ;
  else
    select
      max( bo.start_log_id)
    into :startLogId
    from
      v_sch_batch_operation bo
    where
      -- pkg_SchedulerMain.Exec_BatchMsgLabel
      bo.batch_operation_label = 'EXEC'
    ;
  end if;
end;
/

set feedback on


column message_text_ format A200 head MESSAGE_TEXT

select
  lg.log_id
  , decode( lg.message_level
      , 1, ''
      , lpad( '  ', (lg.message_level - 1) * 2, ' ')
    )
    -- исключаем ошибку из-за строки длиной больше 4000 символов
    || substr( lg.message_text, 1, 4000 - (lg.message_level - 1) * 2)
    as message_text_
  , lg.message_code
  , lg.message_value
  , lg.context_value_id
  , lg.date_ins
  , lg.operator_id
from
  (
  select
    lg.*
    , 1 + ( lg.context_level - ccl.open_context_level)
      + case when lg.open_context_flag = 1 then 0 else 1 end
      as message_level
    , lg.level_code as message_code
  from
    v_lg_context_change_log ccl
    inner join lg_log lg
      on lg.sessionid = ccl.sessionid
        and lg.log_id >= ccl.open_log_id
        and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
  where
    ccl.log_id = :startLogId
  union all
  select
    lg.*
    , LEVEL as message_level
    , lg.message_type_code as message_code
  from
    lg_log lg
  start with
    lg.log_id = :startLogId
    and lg.message_type_code in ( 'BSTART', 'BMANAGE')
  connect by
    prior lg.log_id = lg.parent_log_id
  ) lg
order by
  lg.log_id
/

column message_text_ clear



undefine startLogId
