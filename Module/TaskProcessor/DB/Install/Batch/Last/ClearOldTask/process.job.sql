-- Удаление старых неиспользуемых заданий
declare

                                        --Число удаленных заданий
  nDeleted integer;

begin
  nDeleted := pkg_TaskProcessorUtility.ClearOldTask;
  jobResultMessage := 'Удалено ' || to_char( nDeleted) || ' заданий.';
end;