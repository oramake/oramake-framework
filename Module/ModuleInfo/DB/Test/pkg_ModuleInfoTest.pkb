create or replace package body pkg_ModuleInfoTest is
/* package body: pkg_ModuleInfoTest::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => 'ModuleInfo'
  , objectName  => 'pkg_ModuleInfoTest'
);



/* group: Функции */

/* proc: testGetModuleId
  Тестирование функции <pkg_ModuleInfo.getModuleId>;
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
    Вызов функции.
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
