-- Проверка использования памяти процессами Oracle
declare

  osMemoryThreshold number := pkg_Scheduler.getContextInteger(
    'OsMemoryThreshold'
  );

  pgaMemoryThreshold number := pkg_Scheduler.getContextInteger(
    'PgaMemoryThreshold'
  );

  emailRecipient varchar2(1000):= pkg_Scheduler.getContextString(
    'EmailRecipient'
  );

begin
  pkg_ProcessMonitor.checkMemory(
    osMemoryThreshold => osMemoryThreshold
    , pgaMemoryThreshold => pgaMemoryThreshold
    , emailRecipient => emailRecipient
  );
end;
