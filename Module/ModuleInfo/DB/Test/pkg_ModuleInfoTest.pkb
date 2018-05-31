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

/* iproc: getTestModule
  Возвращает параметры тестового модуля.
  Если тестового модуля не существует, он создается.

  Параметры:
  moduleId                    - Id модуля
                                ( возврат)
  moduleName                  - Наименование модуля
                                ( возврат)
  baseName                    - Уникальное базовое имя модуля
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
        'Ошибка при получении параметров тестового модуля ('
        || ' baseName="' || baseName || '"'
        || ').'
      )
    , true
  );
end getTestModule;

/* func: getTestModuleId
  Возвращает Id тестового модуля.
  Если тестового модуля не существует, он создается.

  Параметры:
  baseName                    - Уникальное базовое имя модуля

  Возврат:
  Id модуля.
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
  Возвращает наименование тестового модуля.
  Если тестового модуля не существует, он создается.

  Параметры:
  baseName                    - Уникальное базовое имя модуля

  Возврат:
  наименование модуля ( module_name)
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

/* proc: testCompareVersion
  Test <pkg_ModuleInfoInternal.compareVersion>.

  Parameters:
  testCaseNumber              - Number of test case to be tested
                                (default unlimited)
*/
procedure testCompareVersion(
  testCaseNumber integer := null
)
is

  -- Number of current (or last) test case
  checkCaseNumber integer := 0;



  /*
    Checks test case.
  */
  procedure checkCase(
    version1 varchar2
    , version2 varchar2
    , resValue integer := null
    , caseDescription varchar2 := null
    , execErrorMessageMask varchar2 := null
    , nextCaseUsedCount pls_integer := null
  )
  is

    -- Description of test case
    cinfo varchar2(200) :=
      'CASE ' || to_char( checkCaseNumber + 1)
      || ': "'
      || coalesce(
          caseDescription
          , version1 || '" '
            || case resValue
                when -1  then '<'
                when  0  then '='
                when  1  then '>'
                else '?'
              end
            || ' "' || version2
        )
      || '": '
    ;

    -- Runtime error message
    execErrorMessage varchar2(32767);

    -- Result of execution
    execResult integer;

    i integer;

  -- checkCase
  begin
    checkCaseNumber := checkCaseNumber + 1;
    if pkg_TestUtility.isTestFailed()
          or testCaseNumber is not null
            and testCaseNumber
              not between checkCaseNumber
                and checkCaseNumber + coalesce( nextCaseUsedCount, 0)
        then
      return;
    end if;
    logger.info( '*** ' || rtrim( cinfo, ' :'));

    begin
      execResult := pkg_ModuleInfoInternal.compareVersion(
        version1      => version1
        , version2    => version2
      );
      if execErrorMessageMask is not null then
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Successful execution instead of error'
        );
      end if;
    exception when others then
      if execErrorMessageMask is not null then
        execErrorMessage := logger.getErrorStack();
        if logger.isTraceEnabled() then
          logger.trace(
            'execution for test case finished with error:'
            || chr(10) || execErrorMessage
          );
        end if;
        if execErrorMessage not like execErrorMessageMask then
          pkg_TestUtility.compareChar(
            actualString        => execErrorMessage
            , expectedString    => execErrorMessageMask
            , failMessageText   =>
                cinfo || 'Error message does not match pattern'
          );
        end if;
      else
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Execution failed with error:'
            || chr(10) || logger.getErrorStack()
        );
      end if;
    end;

    -- Checking for a successful result
    if execErrorMessageMask is null then
      pkg_TestUtility.compareChar(
        actualString        => execResult
        , expectedString    => resValue
        , failMessageText   =>
            cinfo || 'Unexpected result of comparison'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Error while running test case ('
          || 'caseNumber=' || checkCaseNumber
          || ', cinfo="' || cinfo || '"'
          || ').'
        )
      , true
    );
  end checkCase;



-- testCompareVersion
begin
  pkg_TestUtility.beginTest(
    'compare version'
  );

  checkCase( '1.0.0', '1.0.0', 0);
  checkCase( '1.0', '1.00', 0);
  checkCase( '1.0.0', '1.0', 0);
  checkCase( '1.00', '1.0.0', 0);

  checkCase( '3.0.0', '4.0.0', -1);
  checkCase( '4.0.0', '3.0.0', 1);
  checkCase( '3.0.0', '3.0.1', -1);
  checkCase( '3.0.2.3', '3.0.1', 1);
  checkCase( '3.0.2.3', '3.0.15', -1);

  pkg_TestUtility.endTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while testing compareVersion ('
        || 'testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testCompareVersion;

end pkg_ModuleInfoTest;
/
