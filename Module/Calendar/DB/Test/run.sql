-- script: Test/run.sql
-- Выполняет все тесты
--
-- Используемые макромеременные:
-- loggingLevelCode           - Уровень логирования ( по-умолчанию WARN)
--

@oms-default loggingLevelCode WARN

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

@oms-run Test/AutoTest/web-api.sql
