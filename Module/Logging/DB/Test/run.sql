-- script: Test/run.sql
-- ¬ыполн€ет все тесты.
--
-- »спользуемые макропеременные:
-- loggingLevelCode           - ”ровень логировани€
--                              (по-умолчанию WARN)
-- estackLoggingLevelCode     - ”ровень логировани€ пакета pkg_LoggingErrorStack
--                              (по-умолчанию WARN)
-- testCaseNumber             - Ќомер провер€емого тестового случа€
--                              (по умолчанию без ограничений)
--

@oms-default loggingLevelCode WARN
@oms-default estackLoggingLevelCode WARN
@oms-default testCaseNumber ""

set feedback off

declare
  loggingLevelCode varchar2(10) := '&loggingLevelCode';
  estackLoggingLevelCode varchar2(10) := '&estackLoggingLevelCode';
begin
  lg_logger_t.getRootLogger().setLevel(
    coalesce( loggingLevelCode, pkg_Logging.Warn_LevelCode)
  );
  lg_logger_t.getLogger( 'Logging').setLevel(
    coalesce( loggingLevelCode, pkg_Logging.Warn_LevelCode)
  );
  lg_logger_t.getLogger( 'Logging', 'pkg_LoggingErrorStack').setLevel(
    coalesce( estackLoggingLevelCode, pkg_Logging.Warn_LevelCode)
  );
end;
/

set feedback on

@oms-run Test/AutoTest/logger.sql
