-- script: Test/run.sql
-- Performs all tests.
--
-- Used substitution variables:
-- loggingLevelCode           - Logging level for module
--                              (default from rootLoggingLevelCode or
--                                "WARN")
-- rootLoggingLevelCode       - Logging level for root logger
--                              (default "WARN")
-- testCaseNumber             - Number of test case to be tested
--                              (default unlimited)
--

@oms-default loggingLevelCode ""
@oms-default rootLoggingLevelCode ""
@oms-default testCaseNumber ""

set feedback off

declare
  loggingLevelCode varchar2(10) := '&loggingLevelCode';
  rootLoggingLevelCode varchar2(10) := '&rootLoggingLevelCode';
begin
  lg_logger_t.getRootLogger().setLevel(
    coalesce( rootLoggingLevelCode, pkg_Logging.Warning_LevelCode)
  );
  lg_logger_t.getLogger( pkg_WebUtility.Module_Name).setLevel(
    coalesce(
      loggingLevelCode
      , rootLoggingLevelCode
      , pkg_Logging.Warning_LevelCode
    )
  );
end;
/

set feedback on

@oms-run Test/AutoTest/get-http-response.sql
