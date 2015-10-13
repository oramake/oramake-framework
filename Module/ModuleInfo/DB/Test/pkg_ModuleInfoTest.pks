create or replace package pkg_ModuleInfoTest is
/* package: pkg_ModuleInfoTest
  Пакет для тестирования модуля.

  SVN root: Oracle/Module/ModuleInfo
*/



/* group: Функции */

/* pproc: testGetModuleId
  Тестирование функции <pkg_ModuleInfo.getModuleId>;

  ( <body::testGetModuleId>)
*/
procedure testGetModuleId(
  findModuleString varchar2 := null
  , moduleName varchar2 := null
  , svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
  , raiseExceptionFlag number := null
  , searchResult number
  , exceptionFlag number := null
);

end pkg_ModuleInfoTest;
/
