-- Обработчик заданий модуля TaskProcessor
declare

  isFinishAfterProcess integer := pkg_Scheduler.GetContextInteger(
    'IsFinishAfterProcess'
    , riseException => 1
  );

  forceTaskTypeIdList varchar2( 4000) := pkg_Scheduler.getContextString(
    'ForceTaskTypeIdList'
  );

  ignoreTaskTypeIdList varchar2( 4000) := pkg_Scheduler.getContextString(
    'IgnoreTaskTypeIdList'
  );

  nProcessed integer;

begin
  nProcessed := pkg_TaskProcessorHandler.taskHandler(
	  isFinishAfterProcess => isFinishAfterProcess
  , forceTaskTypeIdList => forceTaskTypeIdList
  , ignoreTaskTypeIdList => ignoreTaskTypeIdList
  );
  jobResultMessage := 'Обработано ' || to_char( nProcessed) || ' заданий.';
end;
