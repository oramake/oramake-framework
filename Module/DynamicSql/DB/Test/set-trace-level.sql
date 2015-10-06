-- script: Test/set-trace-level.sql
-- ”станавливает в сессии логировани€ уровн€ TRACE дл€ модул€ с выводом
-- только через dbms_output.
--

set feedback off

begin
  -- ¬ывод только через dbms_output ( чтобы минимально вли€ло на врем€)
  pkg_Logging.setDestination(
    pkg_Logging.DbmsOutput_DestinationCode
  );

  -- ¬ключаем трассировку модул€
  lg_logger_t.getLogger( 'DynamicSql').setLevel( pkg_Logging.Trace_LevelCode);
end;
/

set feedback on
