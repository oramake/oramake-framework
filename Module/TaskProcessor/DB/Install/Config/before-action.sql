-- script: Install/Config/before-action.sql
-- ������������� �������� ������� ������ ����� ����������.
--

@oms-stop-batch ClearOldTask,RestartTaskProcessing,TaskProcessorHandler%
