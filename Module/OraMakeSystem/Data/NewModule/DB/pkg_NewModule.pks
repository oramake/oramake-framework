create or replace package $(packageName) is
/* package: $(packageName)
  Интерфейсный пакет модуля $(moduleName).

  SVN root: $(svnModuleRoot)
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := '$(moduleName)';



/* group: Функции */

end $(packageName);
/
