-- script: Do/deactivate-all.sql
-- Деактивирует все активные батчи и записывает сообщение об остановке в лог.
--
-- (см. <pkg_Scheduler::deactivateBatchAll>)

begin
  pkg_Scheduler.deactivateBatchAll();
end;
/
