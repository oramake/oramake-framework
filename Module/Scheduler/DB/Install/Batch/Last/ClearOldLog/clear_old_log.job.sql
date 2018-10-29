-- ќчистка старых логов выполнени€ пакетов
-- ”дал€ет старые логи выполнени€ пакетов.
--
-- SaveDayCount                  - число дней, за которые сохран€ютс€ данные
--
declare

  -- „исло дней дл€ сохранени€ данных
  saveDayCount number := pkg_Scheduler.getContextNumber(
    'SaveDayCount', riseException => 1
  );

  -- „исло удаленных записей
  nDelete integer;

begin
  nDelete := pkg_Scheduler.clearLog( trunc( sysdate) - saveDayCount);
  jobResultMessage := '”далено ' || to_char( nDelete) || ' записей.';
end;
