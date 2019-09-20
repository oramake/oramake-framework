-- script: Test/repeat-task.sql
-- �������� ��������� ������� � ������� ������ � ���������� ������������.
--
-- ��������:
-- taskId                     - Id �������
--

define taskId = "&1"

timing start

declare

  taskId integer := '&taskId';

  nProcessedTask integer;

  tpr tp_task%rowtype;

begin
  select
    t.*
  into tpr
  from
    tp_task t
  where
    t.task_id = taskId
  ;

  -- �������� �����������
  lg_logger_t.getRootLogger().setLevel( lg_logger_t.getTraceLevelCode());

  -- ������ ������� �� ����������
  pkg_TaskProcessor.startTask( taskId => taskId);

  nProcessedTask := pkg_TaskProcessorHandler.taskHandler(
    isFinishAfterProcess => 1
    , forceTaskTypeIdList => to_char( tpr.task_type_id)
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ��������� ���������� ������� ('
      || 'taskId=' || taskId
      || ').'
    , true
  );
end;
/

timing stop

undefine taskId
