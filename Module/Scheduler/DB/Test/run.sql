-- script: Test/run.sql
-- ¬ыполн€ет все тесты
--
-- »спользуемые макромеременные:
-- loggingLevelCode           - ”ровень логировани€ дл€ модул€
--                              (по умолчанию из rootLoggingLevelCode либо WARN)
-- rootLoggingLevelCode       - ”ровень логировани€ дл€ других модулей
--                              (по умолчанию WARN)
-- testCaseNumber             - Ќомер провер€емого тестового случа€
--                              (по умолчанию без ограничений)
-- saveDataFlag               - ‘лаг сохранени€ тестовых данных
--                              (1 да, 0 нет (по умолчанию))
--

@oms-default loggingLevelCode ""
@oms-default rootLoggingLevelCode ""
@oms-default testCaseNumber ""
@oms-default saveDataFlag ""

set feedback off

declare
  loggingLevelCode varchar2(10) := '&loggingLevelCode';
  rootLoggingLevelCode varchar2(10) := '&rootLoggingLevelCode';
begin
  lg_logger_t.getRootLogger().setLevel(
    coalesce( rootLoggingLevelCode, pkg_Logging.Warning_LevelCode)
  );
  lg_logger_t.getLogger( 'Scheduler').setLevel(
    coalesce(
      loggingLevelCode
      , rootLoggingLevelCode
      , pkg_Logging.Warning_LevelCode
    )
  );
end;
/

set feedback on

@oms-run Test/AutoTest/load-batch.sql
@oms-run Test/AutoTest/web-api.sql
@oms-run Test/AutoTest/batch-option.sql

prompt Long tests...
@oms-run Test/AutoTest/batch-operation.sql
