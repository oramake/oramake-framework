create or replace package pkg_ModuleDependencySource is
/* package: pkg_ModuleDependency
  Выгружает зависимости из all_dependencies.

  SVN root:
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'ModuleDependency';



/* group: Функции */

/* pproc: unloadObjectDependency
  Выгружает зависимости из all_dependencies.

  Параметры:
  targetDbLink                - dbLink до БД назначения для выгрузки
                                зависимостей all_dependencies.
*/
procedure unloadObjectDependency(
  targetDbLink varchar2 default null
);

end pkg_ModuleDependencySource;
/
