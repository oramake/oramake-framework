-- script: Test/run.sql
-- Выполняет все тесты.
--
-- Используемые макромеременные:
-- refreshMethod              - метод обновления ( "d" сравнением данных,
--                              "m" с помощью материализованного
--                              представления, "t" сравнением с использованием
--                              временной таблицы)
--                              ( по умолчанию без ограничений)
-- loggingLevelCode           - уровень логирования ( по-умолчанию WARN)

@oms-default refreshMethod ""
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

@oms-run Test/AutoTest/api.sql
@oms-run Test/AutoTest/refresh.sql
