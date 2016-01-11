-- Обработчик заданий модуля TaskProcessor
declare

  isFinishAfterProcess integer := pkg_Scheduler.GetContextInteger(
    'IsFinishAfterProcess'
    , riseException => 1
  );

  nProcessed integer;

begin
  nProcessed := pkg_TaskProcessorHandler.taskHandler(
	  isFinishAfterProcess => isFinishAfterProcess
  );
  jobResultMessage := 'Обработано ' || to_char( nProcessed) || ' заданий.';
end;