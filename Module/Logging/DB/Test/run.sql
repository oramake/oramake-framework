-- script: Test/run.sql
-- ¬ыполн€ет все тесты.
--
-- »спользуемые макропеременные:
-- loggingLevelCode           - ”ровень логировани€ дл€ модул€
--                              (по-умолчанию из rootLoggingLevelCode либо WARN)
-- estackLoggingLevelCode     - ”ровень логировани€ пакета pkg_LoggingErrorStack
--                              (по-умолчанию WARN)
-- utilityLoggingLevelCode    - ”ровень логировани€ пакета pkg_LoggingUtility
--                              (по-умолчанию не устанавливаетс€)
-- rootLoggingLevelCode       - ”ровень логировани€ корневого логера
--                              (по-умолчанию WARN)
-- testCaseNumber             - Ќомер провер€емого тестового случа€
--                              (по умолчанию без ограничений)
--

@oms-default loggingLevelCode WARN
@oms-default estackLoggingLevelCode WARN
@oms-default utilityLoggingLevelCode WARN
@oms-default rootLoggingLevelCode ""
@oms-default testCaseNumber ""

set feedback off

declare
  loggingLevelCode varchar2(10) := '&loggingLevelCode';
  estackLoggingLevelCode varchar2(10) := '&estackLoggingLevelCode';
  utilityLoggingLevelCode varchar2(10) := '&utilityLoggingLevelCode';
  rootLoggingLevelCode varchar2(10) := '&rootLoggingLevelCode';
begin
  lg_logger_t.getRootLogger().setLevel(
    coalesce(
      rootLoggingLevelCode
      , pkg_Logging.Warn_LevelCode
    )
  );
  lg_logger_t.getLogger( 'Logging').setLevel(
    coalesce(
      loggingLevelCode
      , rootLoggingLevelCode
      , pkg_Logging.Warn_LevelCode
    )
  );
  lg_logger_t.getLogger( 'Logging', 'pkg_LoggingErrorStack').setLevel(
    coalesce( estackLoggingLevelCode, pkg_Logging.Warn_LevelCode)
  );
  if utilityLoggingLevelCode is not null then
    lg_logger_t.getLogger( 'Logging', 'pkg_LoggingUtility').setLevel(
      utilityLoggingLevelCode
    );
  end if;
end;
/

set feedback on

@oms-run Test/AutoTest/logger.sql
@oms-run Test/AutoTest/utility.sql
