-- script: Test/test-batch.sql
-- Тестирование батчей. Активирует батчи, запускает, ожидает завершения
-- работы и деактивирует, затем показывает лог выполнения.
--
-- Параметры:
-- 1                          - список масок имён батчей через ","

define batchShortNameList=&1

begin
  pkg_SchedulerTest.testBatch(
    batchShortNameList => '&batchShortNameList'
  );
end;
/

undefine batchShortNameList
