-- script: Test/run.sql
-- ¬ыполн€ет все тесты
--
-- »спользуемые макромеременные:
-- loggingLevelCode           - ”ровень логировани€ ( по-умолчанию WARN)
-- testCaseNumber             - Ќомер провер€емого тестового случа€
--                              ( по умолчанию без ограничений)
--

@oms-default loggingLevelCode WARN
@oms-default testCaseNumber ""

set feedback off

declare
  loggingLevelCode varchar2(10) := '&loggingLevelCode';
begin
  lg_logger_t.getRootLogger().setLevel(
    coalesce( loggingLevelCode, pkg_Logging.Warning_LevelCode)
  );
end;
/

set feedback on

@oms-run Test/AutoTest/load-batch.sql
@oms-run Test/AutoTest/web-api.sql
@oms-run Test/AutoTest/batch-option.sql
