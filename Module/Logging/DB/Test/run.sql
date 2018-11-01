-- script: Test/run.sql
-- ��������� ��� �����.
--
-- ������������ ���������������:
-- loggingLevelCode           - ������� �����������
--                              (��-��������� WARN)
-- testCaseNumber             - ����� ������������ ��������� ������
--                              (�� ��������� ��� �����������)
--

@oms-default loggingLevelCode WARN
@oms-default testCaseNumber ""

set feedback off

declare
  loggingLevelCode varchar2(10) := '&loggingLevelCode';
begin
  lg_logger_t.getRootLogger().setLevel(
    coalesce( loggingLevelCode, pkg_Logging.Warn_LevelCode)
  );
  lg_logger_t.getLogger( 'Logging').setLevel(
    coalesce( loggingLevelCode, pkg_Logging.Warn_LevelCode)
  );
end;
/

set feedback on

@oms-run Test/AutoTest/logger.sql
