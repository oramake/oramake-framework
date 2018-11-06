-- Очистка старых записей лога.
--
declare

  -- Число дней для сохранения данных
  saveDayCount number := pkg_Scheduler.getContextNumber(
    'SaveDayCount', riseException => 1
  );

  -- Число удаленных записей
  nDelete integer;

begin
  nDelete := pkg_Scheduler.clearLog( trunc( sysdate) - saveDayCount);
  jobResultMessage := 'Удалено ' || to_char( nDelete) || ' записей.';
end;
