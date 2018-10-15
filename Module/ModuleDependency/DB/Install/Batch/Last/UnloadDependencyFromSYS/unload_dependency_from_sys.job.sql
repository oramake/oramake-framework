-- Выгрузка зависимостей по системному представлению all_dependencies
begin
  pkg_ModuleDependencySource.unloadObjectDependency();
end;
