create or replace package pkg_ModuleInfoTest is
/* package: pkg_ModuleInfoTest
  ����� ��� ������������ ������.

  SVN root: Oracle/Module/ModuleInfo
*/



/* group: ��������� */

/* const: TestOperator_LoginPrefix
  ������� ����� �������� �������.
*/
Test_ModuleNamePrefix constant varchar2(50) := 'TestMod_';



/* group: ������� */

/* pfunc: getTestModuleId
  ���������� Id ��������� ������.
  ���� ��������� ������ �� ����������, �� ���������.

  ���������:
  baseName                    - ���������� ������� ��� ������

  �������:
  Id ������.

  ( <body::getTestModuleId>)
*/
function getTestModuleId(
  baseName varchar2
)
return integer;

/* pfunc: getTestModuleName
  ���������� ������������ ��������� ������.
  ���� ��������� ������ �� ����������, �� ���������.

  ���������:
  baseName                    - ���������� ������� ��� ������

  �������:
  ������������ ������ ( module_name)

  ( <body::getTestModuleName>)
*/
function getTestModuleName(
  baseName varchar2
)
return varchar2;

/* pproc: testGetModuleId
  ������������ ������� <pkg_ModuleInfo.getModuleId>;

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
