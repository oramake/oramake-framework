-- script: Test/run.sql
-- ��������� ��� �����.
--
-- ������������ ���������������:
-- loggingLevelCode           - ������� �����������
--                              (��-��������� WARN)
-- estackLoggingLevelCode     - ������� ����������� ������ pkg_LoggingErrorStack
--                              (��-��������� WARN)
-- testCaseNumber             - ����� ������������ ��������� ������
--                              (�� ��������� ��� �����������)
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
