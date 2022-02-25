-- script: oms-drop-batch
-- Удаляет пакетные задания, реализованные с помощью модуля Scheduler.
--
-- Параметры:
-- batchShortName              - короткое наименование батча
-- activatedFlag               - флаг удаления активированных батчей ( 1 удалить
--                               активированный батч, 0 удалять только если батч
--                               не активирован, по-умолчанию 0)
--
--Примеры:
--
--  - удаление неактивированного батча ClearOldLog
--
-- (code)
--
-- @oms-drop-batch.sql BatchName 0
--
-- (end)
--
--  - удаление активированного батча ClearOldLog
--
-- (code)
--
-- @oms-drop-batch.sql BatchName 1
--
-- (end)
--

define batchShortName = "&1"

define activatedFlag = "&2"

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
end;
/

undefine batchShortName
                                 