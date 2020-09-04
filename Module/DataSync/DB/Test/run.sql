-- script: Test/run.sql
-- Выполняет все тесты.
--
-- Используемые макромеременные:
-- refreshMethod              - Метод обновления ( "d" сравнением данных,
--                              "m" с помощью материализованного
--                              представления, "t" сравнением с использованием
--                              временной таблицы)
--                              ( по умолчанию без ограничений)
-- loggingLevelCode           - Уровень логирования модуля
--                              (по умолчанию из rootLoggingLevelCode или
--                              "WARN")
-- rootLoggingLevelCode       - Уровень логирования всех модулей
--                              (по умолчанию "WARN")
-- testCaseNumber             - Номер проверяемого тестового случая
--                              (по умолчанию без ограничений)

@oms-default refreshMethod ""
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
  lg_logger_t.getLogger( pkg_DataSync.Module_Name).setLevel(
    coalesce(
      loggingLevelCode
      , rootLoggingLevelCode
      , pkg_Logging.Warning_LevelCode
    )
  );
end;
/

set feedback on

@oms-run Test/AutoTest/api.sql
@oms-run Test/AutoTest/refresh.sql
@oms-run Test/AutoTest/append-data.sql
