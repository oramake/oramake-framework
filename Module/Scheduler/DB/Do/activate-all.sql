-- script: Do/activate-all.sql
-- Активирует пакетные задания.
--
-- Параметры:
-- usedDayCount               - только пакеты, которые останавливались
--                              скриптом <pkg_Scheduler:deactivateBatchAll> в
--                              последние usedDayCount дней (0 текущий день,
--                              null без ограничения (по умолчанию))
--


declare

  usedDayCount number := to_number( '&1');

begin
  pkg_Scheduler.activateBatchAll(usedDayCount => usedDayCount);
end;
/
