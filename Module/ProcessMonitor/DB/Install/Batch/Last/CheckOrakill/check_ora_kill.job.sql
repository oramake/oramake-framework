-- Прерывание сессий с помощью Orakill
-- Проверяет сессии на наличие запросов на выполнение orakill
begin
  pkg_ProcessMonitor.checkOrakill();
end;