-- script: Install/Config/before-action.sql
-- Останавливает пакетные задания модуля перед установкой.
--

@oms-stop-batch ClearOldTask,RestartTaskProcessing,TaskProcessorHandler%
