-- script: Test/Example/nested-context.sql
-- Использование вложенного контекста (пример).
--
-- Предварительные требования:
-- - установка пакета pkg_ModuleInfoTest (тестовый пакет модуля ModuleInfo) в
--  связи с использованием функции getTestModuleId для добавления тестового
--  модуля в таблицу mod_module модуля ModuleInfo;
--
-- Пример выполнения скрипта:
-- (code)
-- Calculate statistics #1 ...
--
-- Calculate statistics #2 (with error) ...
-- declare
-- *
-- ERROR at line 1:
-- ORA-20150: Ошибка при расчете статистики.
-- ORA-06512: at line 101
-- ORA-20150: Ошибка при обработке запроса (requestId=33).
-- ORA-06512: at line 63
-- ORA-20185: Некорректный запрос
-- ORA-06512: at line 41
-- ORA-06512: at line 85
-- ORA-06512: at line 85
--
--
-- Rows in v_lg_context_change:
--
-- OPEN_LOG_ID CLOSE_LOG_ID CLOSE_LEVE CLOSE_MESSAGE_VALUE
-- ----------- ------------ ---------- -------------------
--   337082332    337082338 INFO                         5
--   337082339    337082344 ERROR                        2
--
-- Rows in lg_log (last calculation):
--
--     LOG_ID LEVEL_CODE MESSAGE_TEXT                                             ...  MESSAGE_VALUE CONTEXT_LEVEL CONTEXT_VALUE_ID
-- ---------- ---------- --------------------------------------------------------      ------------- ------------- ----------------
--  337082339 INFO       Расчет статистики по запросам                                                           1
--  337082342 TRACE      Обработка запроса: requestId=33                                                         2               33
--  337082343 ERROR      Ошибка при обработке запроса:                                                           2               33
--                       ORA-20185: Некорректный запрос
--
--  337082344 ERROR      Ошибка при расчете (обработано запросов: 2):                              2             1
--                       ORA-20150: Ошибка при обработке запроса (requestId=33).
--                       ORA-06512: at line 63
--                       ORA-20185: Некорректный запрос
--                       ORA-06512: at line 41
--                       ORA-06512: at line 85
-- (end)
--

var testModuleName varchar2(100)

set feedback off



-- Create module for test...

declare
  testModuleId integer;
begin
  testModuleId := pkg_ModuleInfoTest.getTestModuleId(
    baseName => 'Module1'
  );
  select
    t.module_name
  into :testModuleName
  from
    v_mod_module t
  where
    t.module_id = testModuleId
  ;
  -- Фиксируем, т.к. если модуль был создан, то он будет невиден в
  -- при логировании (выполняемом в автономной транзакции)
  commit;
end;
/



-- Create context type (lg_context_type) ...

var CalcStats_CtxTpSName varchar2(50)
var RequestId_CtxTpSName varchar2(50)

declare

  CalcStats_CtxTpSName constant varchar2(50) := 'calcStats';
  RequestId_CtxTpSName constant varchar2(50) := 'request_id';

  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => :testModuleName
    , objectName  => 'Install/Data/Last/lg_context_type.sql'
  );

  nChanged integer := 0;

begin
  nChanged :=
    logger.mergeContextType(
        contextTypeShortName      => CalcStats_CtxTpSName
        , contextTypeName         => 'Расчет статистики по запросам'
        , nestedFlag              => 1
        , contextTypeDescription  =>
'Расчет статистики по запросам. При закрытии контекста в message_value указывается число успешно обработанных запросов'
      )
    + logger.mergeContextType(
        contextTypeShortName      => RequestId_CtxTpSName
        , contextTypeName         => 'Обработка запроса'
        , nestedFlag              => 1
        , contextTypeDescription  =>
'Обработка запроса, в context_value_id указывается Id запроса (значение поля request_id из таблицы tst_request)'
      )
  ;
  commit;

  :CalcStats_CtxTpSName := CalcStats_CtxTpSName;
  :RequestId_CtxTpSName := RequestId_CtxTpSName;
end;
/


-- Вывод только в таблицу лога
exec pkg_Logging.setDestination( pkg_Logging.Table_DestinationCode);


prompt
prompt Calculate statistics #1 ...
define isError = 0
define logLevel = ""

declare

  -- Признак генерации ошибки при обработке
  isError integer := '&isError';

  -- Логирование указанного уровня
  logLevel varchar2(100) := trim( '&logLevel');

  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => :testModuleName
    , objectName  => 'Do/calc-stats.sql'
  );

  processedCount integer := 0;

  cursor requestCur is
    select
      t.column_value as request_id
    from
      table( pkg_Common.split('15,21,33,45,54')) t
  ;



  procedure processRequest(
    requestId integer
  )
  is
  begin
    logger.trace(
      'Обработка запроса: requestId='  || requestId
      , contextTypeShortName => :RequestId_CtxTpSName
      , contextValueId => requestId
      , openContextFlag => 1
    );

    -- Обработка запроса...

    -- При обработке одного из запросов возникает ошибка
    if isError = 1 and requestId = 33 then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Некорректный запрос'
      );
    end if;

    processedCount := processedCount + 1;

    logger.trace(
      'Обработка запроса завершена'
      , contextTypeShortName => :RequestId_CtxTpSName
      , contextValueId => requestId
      , openContextFlag => 0
    );
  exception when others then
    logger.error(
      'Ошибка при обработке запроса:'
        || chr(10) || logger.getErrorStack( isStackPreserved => 1)
      , contextTypeShortName => :RequestId_CtxTpSName
      , contextValueId => requestId
      , openContextFlag => 0
    );
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при обработке запроса ('
          || 'requestId=' || requestId
          || ').'
        )
      , true
    );
  end processRequest;



-- main
begin
  logger.setLevel( logLevel);
  logger.info(
    'Расчет статистики по запросам'
    , contextTypeShortName => :CalcStats_CtxTpSName
    , openContextFlag => 1
  );
  for rec in requestCur loop
    processRequest( requestId => rec.request_id);
  end loop;
  logger.info(
    'Расчет завершен, обработано запросов: ' || processedCount
    , contextTypeShortName => :CalcStats_CtxTpSName
    , openContextFlag => 0
    , messageValue => processedCount
  );
exception when others then
  logger.error(
    'Ошибка при расчете (обработано запросов: ' || processedCount || '):'
      || chr(10) || logger.getErrorStack( isStackPreserved => 1)
    , contextTypeShortName => :CalcStats_CtxTpSName
    , openContextFlag => 0
    , messageValue => processedCount
  );
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при расчете статистики.'
      )
    , true
  );
end;
/

prompt
prompt Calculate statistics #2 (with error) ...
define isError = 1

/

-- Восстанавливаем настройки вывода по умолчанию
exec pkg_Logging.setDestination( null);


prompt Rows in v_lg_context_change:


select
  a.*
from
  (
  select
    cc.open_log_id
    , cc.close_log_id
    , cc.close_level_code
    , cc.close_message_value
  from
    lg_context_type ct
    inner join v_mod_module md
      on md.module_id = ct.module_id
    inner join v_lg_context_change cc
      on cc.context_type_id = ct.context_type_id
  where
    md.module_name = :testModuleName
    and ct.context_type_short_name = :CalcStats_CtxTpSName
  order by
    cc.open_log_id desc
  ) a
where
  rownum <= 2
order by
  open_log_id
/


prompt
prompt Rows in lg_log (last calculation):

column message_text format A60

select
  lg.log_id
  , lg.level_code
  , lg.message_text
  , lg.message_value
  , lg.context_level
  , lg.context_value_id
from
  v_lg_context_change_log ccl
  inner join lg_log lg
    on lg.sessionid = ccl.sessionid
      and lg.log_id >= ccl.open_log_id
      and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
where
  ccl.log_id =
    (
    select
      max( cc.open_log_id)
    from
      lg_context_type ct
      inner join v_mod_module md
        on md.module_id = ct.module_id
      inner join v_lg_context_change cc
        on cc.context_type_id = ct.context_type_id
    where
      md.module_name = :testModuleName
      and ct.context_type_short_name = :CalcStats_CtxTpSName
    )
order by
  1
/

column message_text clear

set feedback on
