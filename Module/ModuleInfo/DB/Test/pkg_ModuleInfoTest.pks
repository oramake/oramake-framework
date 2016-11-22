create or replace package pkg_ModuleInfoTest is
/* package: pkg_ModuleInfoTest
  Пакет для тестирования модуля.

  SVN root: Oracle/Module/ModuleInfo
*/



/* group: Константы */

/* const: TestOperator_LoginPrefix
  Префикс имени тестовых модулей.
*/
Test_ModuleNamePrefix constant varchar2(50) := 'TestMod_';



/* group: Функции */

/* pfunc: getTestModuleId
  Возвращает Id тестового модуля.
  Если тестового модуля не существует, он создается.

  Параметры:
  baseName                    - Уникальное базовое имя модуля

  Возврат:
  Id модуля.

  ( <body::getTestModuleId>)
*/
function getTestModuleId(
  baseName varchar2
)
return integer;

/* pfunc: getTestModuleName
  Возвращает наименование тестового модуля.
  Если тестового модуля не существует, он создается.

  Параметры:
  baseName                    - Уникальное базовое имя модуля

  Возврат:
  наименование модуля ( module_name)

  ( <body::getTestModuleName>)
*/
function getTestModuleName(
  baseName varchar2
)
return varchar2;

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
