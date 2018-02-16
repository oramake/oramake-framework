-- script: Install/Config/after-action.sql
-- Запускает пакетные задания модуля, остановленные перед установкой.
--

@oms-resume-batch ClearOldTask,RestartTaskProcessing,TaskProcessorHandler%
