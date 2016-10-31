create or replace package body pkg_ModuleInfoTest is
/* package body: pkg_ModuleInfoTest::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => 'ModuleInfo'
  , objectName  => 'pkg_ModuleInfoTest'
);



/* group: ������� */

/* iproc: getTestModule
  ���������� ��������� ��������� ������.
  ���� ��������� ������ �� ����������, �� ���������.

  ���������:
  moduleId                    - Id ������
                                ( �������)
  moduleName                  - ������������ ������
                                ( �������)
  baseName                    - ���������� ������� ��� ������
*/
procedure getTestModule(
  moduleId out integer
  , moduleName out varchar2
  , baseName varchar2
)
is
begin
  moduleName := Test_ModuleNamePrefix || baseName;
  moduleId := pkg_ModuleInfoInternal.getModuleId(
    svnRoot           => 'Oracle/Module/' || moduleName
    , initialSvnPath  => 'Oracle/Module/' || moduleName || '@12345'
    , isCreate        => 1
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ���������� ��������� ������ ('
        || ' baseName="' || baseName || '"'
        || ').'
      )
    , true
  );
end getTestModule;

/* func: getTestModuleId
  ���������� Id ��������� ������.
  ���� ��������� ������ �� ����������, �� ���������.

  ���������:
  baseName                    - ���������� ������� ��� ������

  �������:
  Id ������.
*/
function getTestModuleId(
  baseName varchar2
)
return integer
is

  mdr v_mod_module%rowtype;

begin
  getTestModule(
    moduleId        => mdr.module_id
    , moduleName    => mdr.module_name
    , baseName      => baseName
  );
  return mdr.module_id;
end getTestModuleId;

/* func: getTestModuleName
  ���������� ������������ ��������� ������.
  ���� ��������� ������ �� ����������, �� ���������.

  ���������:
  baseName                    - ���������� ������� ��� ������

  �������:
  ������������ ������ ( module_name)
*/
function getTestModuleName(
  baseName varchar2
)
return varchar2
is

  mdr v_mod_module%rowtype;

begin
  getTestModule(
    moduleId        => mdr.module_id
    , moduleName    => mdr.module_name
    , baseName      => baseName
  );
  return mdr.module_name;
end getTestModuleName;

/* proc: testGetModuleId
  ������������ ������� <pkg_ModuleInfo.getModuleId>;
*/
procedure testGetModuleId(
  findModuleString varchar2 := null
  , moduleName varchar2 := null
  , svnRoot varchar2 := null
  , initialSvnPath varchar2 := null
  , raiseExceptionFlag number := null
  , searchResult number
  , exceptionFlag number := null
)
is
  actualSearchResult number(1,0) := 0;
  actualExceptionFlag number(1,0) := 0;

  /*
    ����� �������.
  */
  procedure callFunction
  is
    moduleId integer;
  begin
    moduleId :=
      pkg_ModuleInfo.getModuleId(
        findModuleString => findModuleString
        , moduleName => moduleName
        , svnRoot => svnRoot
        , initialSvnPath => initialSvnPath
        , raiseExceptionFlag => raiseExceptionFlag
      );
    if moduleId is not null then
      actualSearchResult := 1;
    end if;
  exception when others then
    actualExceptionFlag := 1;
  end callFunction;

-- testGetModuleId
begin
  pkg_TestUtility.beginTest( 'testGetModuleId ( "' || findModuleString || '"');
  callFunction();
  pkg_TestUtility.compareChar(
    expectedString => to_char( searchResult)
    , actualString => to_char( actualSearchResult)
    , failMessageText => 'searchResult'
  );
  pkg_TestUtility.compareChar(
    expectedString => to_char( coalesce( exceptionFlag, 0))
    , actualString => to_char( actualExceptionFlag)
    , failMessageText => 'exceptionFlag'
  );
  pkg_TestUtility.endTest();
end testGetModuleId;

end pkg_ModuleInfoTest;
/
