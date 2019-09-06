-- script: Test/repeat-task.sql
-- Повторно выполняет задание в текущей сессии с включенной трассировкой.
--
-- Парметры:
-- taskId                     - Id задания
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

  -- включаем трассировку
  lg_logger_t.getRootLogger().setLevel( lg_logger_t.getTraceLevelCode());

  -- ставим задание на выполнение
  pkg_TaskProcessor.startTask( taskId => taskId);

  nProcessedTask := pkg_TaskProcessorHandler.taskHandler(
    isFinishAfterProcess => 1
    , forceTaskTypeIdList => to_char( tpr.task_type_id)
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при повторном выполнении задания ('
      || 'taskId=' || taskId
      || ').'
    , true
  );
end;
/

timing stop

undefine taskId
