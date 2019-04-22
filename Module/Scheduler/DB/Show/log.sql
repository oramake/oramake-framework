-- script: Show/log.sql
-- Показывает ветку лога выполнения операции над пакетным заданием.
--
-- Параметры:
-- startLogId                 - Id записи лога выполнения операции
--                              (по умолчанию лог выполнения последнего
--                              запускавшегося пакетного задания)
-- batchPattern               - Маска краткого имени пакетного задания
--                              (like по полю batch_short_name), при этом
--                              показывается лог последнего запуска пакетного
--                              задания
--
-- Замечания:
-- - если значение параметра (без учета пробелов) состоит из цифр, то
--  оно рассматривается как startLogId, иначе как batchPattern;
-- - в случае, если под batchPattern подходит несколько пакетных заданий,
--  то выбирается задание с минимальным batch_id;
--

var startLogId number

set feedback off

declare
  paramStr varchar2(255) := trim( '&1');
  paramNum integer;
begin
  if paramStr is not null and ltrim( paramStr, '0123456789') is null then
    paramNum := to_number( paramStr);
    select
      min( ccl.log_id)
    into :startLogId
    from
      v_lg_context_change_log ccl
    where
      ccl.log_id = paramNum
      and ccl.context_type_id =
        (
        select
          ct.context_type_id
        from
          v_mod_module md
          inner join lg_context_type ct
            on ct.module_id = md.module_id
        where
          -- pkg_SchedulerMain.Module_SvnRoot
          md.svn_root = 'Oracle/Module/Scheduler'
          -- pkg_SchedulerMain.Batch_CtxTpSName
          and ct.context_type_short_name = 'BATCH'
        )
      and ccl.context_type_level = 1
    ;
    if :startLogId is null then
      select
        min( bo.start_log_id)
      into :startLogId
      from
        v_sch_batch_operation bo
      where
        paramNum >= bo.start_log_id
        and paramNum <= coalesce( bo.finish_log_id, paramNum)
        and bo.sessionid =
          (
          select
            lg.sessionid
          from
            lg_log lg
          where
            lg.log_id = paramNum
          )
      ;
    end if;

    -- Возможно это Id старого лога sch_log
    if :startLogId is null then
      :startLogId := paramNum;
    end if;
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
          min( b.batch_id)
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
  , lg.level_code
  , lg.message_value
  , lg.context_value_id
  , lg.date_ins
  , lg.operator_id
from
  (
  select
    lg.*
    , 1 + ( lg.context_level - ccl.open_context_level)
      + case when lg.open_context_flag in ( 1, -1) then 0 else 1 end
      as message_level
  from
    v_lg_context_change_log ccl
    inner join lg_log lg
      on lg.sessionid = ccl.sessionid
        and lg.log_id >= ccl.open_log_id
        and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
  where
    ccl.log_id = :startLogId
  ) lg
order by
  lg.log_id
/

column message_text_ clear
