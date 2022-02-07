-- script: oms-drop-batch.sql
-- Удаляет пакетные задания, реализованные с помощью модуля Scheduler.
--
-- Параметры:
-- batchShortName                - маска для имени пакетов ( batch_short_name)
-- activatedFlag                 - флаг удаления активированных батчей
--                                 ( 1 - удалить активированный батч
--                                   0 - удалять неактивированный батч)
--
--Примеры:
--
--  - удаление неактивированного батча ClearOldLog
--
-- (code)
--
-- @oms-dкщз-batch.sql ClearOldLog 0
--
-- (end)
--
--  - удаление активированного батча ClearOldLog
--
-- (code)
--
-- @oms-dкщз-batch.sql ClearOldLog 1
--
-- (end)
--

define batchShortName = &1

define activatedFlag = &2

prompt Dropping batches by module name &batchShortName ...

declare
  -- Название пкетного названия
  batchShortName varchar2(100):= '&batchShortName';
  -- Флаг удаления активированного пакетного задания
  activatedFlag integer := '&activatedFlag';
  -- Id оператора, выполняющего удаление
  operatorId constant integer := pkg_Operator.GetCurrentUserId();
begin
  pkg_SchedulerLoad.deleteBatch(
    batchShortName  => batchShortName
	, activatedFlag => activatedFlag
  );
  dbms_output.put_line(
    rpad( batchShortName, 30)
    || ' - removed');
exception
  when others
    then
      dbms_output.put_line( 'Exception: [' || sqlerrm || ']' );

end;
/

undefine batchShortName
                                 