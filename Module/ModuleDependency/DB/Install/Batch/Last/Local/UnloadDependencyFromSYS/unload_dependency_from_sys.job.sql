-- Выгрузка зависимостей по системному представлению all_dependencies
declare

  targetDbLink varchar2(1000) := pkg_Scheduler.getContextString(
    'TargetDbLink'
    , riseException => 0
  );

begin
  pkg_ModuleDependencySource.unloadObjectDependency(targetDbLink => targetDbLink);
end;
