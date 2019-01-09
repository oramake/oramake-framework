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

/* proc: testCheckInstallVersion
  Test <pkg_ModuleInfoInternal.checkInstallVersion>.

  Parameters:
  testCaseNumber              - Number of test case to be tested
                                (default unlimited)
*/
procedure testCheckInstallVersion(
  testCaseNumber integer := null
)
is

  -- Number of current (or last) test case
  checkCaseNumber integer := 0;


  -- Параметры тестового модуля
  testMod v_mod_module%rowtype;

  testInstallResultId integer;


  /*
    Подготовка данных для теста.
  */
  procedure prepareTestData
  is

    pragma autonomous_transaction;

  begin
    getTestModule(
      moduleId      => testMod.module_id
      , moduleName  => testMod.module_name
      , baseName    => 'ModCheckInstVer'
    );
    select
      md.*
    into testMod
    from
      v_mod_module md
    where
      md.module_id = testMod.module_id
    ;
    delete
      mod_install_result ir
    where
      ir.module_id = testMod.module_id
    ;
    testInstallResultId := pkg_ModuleInstall.createInstallResult(
      moduleSvnRoot             => testMod.svn_root
      , moduleInitialSvnPath    =>
          testMod.initial_svn_root || '@' || testMod.initial_svn_revision
      , hostProcessStartTime    => systimestamp
      , hostProcessId           => 0
      , moduleVersion           => '1.0.0'
      , actionGoalList          => 'install'
      , actionOptionList        => 'INSTALL_VERSION=Last'
      , modulePartNumber        => 1
      , installVersion          => '1.0.0'
      , installTypeCode         => 'OBJ'
      , isFullInstall           => 1
    );
    commit;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при подготовке данных для теста.'
        )
      , true
    );
  end prepareTestData;



  /*
    Устанавливает текущую версию тестового модуля.
  */
  procedure setCurrentVersion(
    currentVersion varchar2
  )
  is

    pragma autonomous_transaction;

  begin
    update
      mod_install_result t
    set
      t.install_version = coalesce( currentVersion, t.install_version)
      , t.is_full_install = 1
      , t.is_revert_install =
          case when currentVersion is not null then 0 else 1 end
      , t.result_version = currentVersion
      , t.is_current_version =
          case when currentVersion is not null then 1 else 0 end
    where
      t.install_result_id = testInstallResultId
    ;
    commit;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при установке текущей версии тестового модуля ('
          || ' currentVersion="' || currentVersion || '"'
          || ').'
        )
      , true
    );
  end setCurrentVersion;



  /*
    Checks test case.
  */
  procedure checkCase(
    caseDescription varchar2
    , currentVersion varchar2 := null
    , moduleSvnRoot varchar2 := testMod.svn_root
    , moduleInitialSvnPath varchar2 := null
    , modulePartNumber integer := 1
    , installVersion varchar2 := null
    , installTypeCode varchar2 := 'OBJ'
    , isFullInstall integer := 0
    , isRevertInstall integer := 0
    , installUser varchar2 := null
    , objectSchema varchar2 := null
    , privsUser varchar2 := null
    , installScript varchar2 := null
    , resultVersion varchar2 := null
    , execErrorMessageMask varchar2 := null
    , nextCaseUsedCount pls_integer := null
  )
  is

    -- Description of test case
    cinfo varchar2(200) :=
      'CASE ' || to_char( checkCaseNumber + 1)
      || ': "' || caseDescription || '"'
      || case when execErrorMessageMask is not null  then
         ' (ошибка)'
        end
      || ': '
    ;

    -- Runtime error message
    execErrorMessage varchar2(32767);

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

    setCurrentVersion( currentVersion);

    begin
      pkg_ModuleInstall.checkInstallVersion(
        moduleSvnRoot             => moduleSvnRoot
        , moduleInitialSvnPath    => moduleInitialSvnPath
        , modulePartNumber        => modulePartNumber
        , installVersion          => installVersion
        , installTypeCode         => installTypeCode
        , isFullInstall           => isFullInstall
        , isRevertInstall         => isRevertInstall
        , installUser             => installUser
        , objectSchema            => objectSchema
        , privsUser               => privsUser
        , installScript           => installScript
        , resultVersion           => resultVersion
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
                || chr(10) || 'actual error message:'
                || chr(10) || execErrorMessage
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
      null;
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



-- testCheckInstallVersion
begin
  pkg_TestUtility.beginTest(
    'check install version'
  );

  prepareTestData();

  checkCase(
    'Не указан модуль'
    , moduleSvnRoot         => null
    , moduleInitialSvnPath  => null
    , execErrorMessageMask  =>
'%ORA-20195: Не указаны параметры модуля.%'
  );

  checkCase(
    'Обновление без установленной версии'
    , currentVersion        => null
    , installVersion        => '3.5.0'
    , execErrorMessageMask  =>
'%ORA-20195: Нет установленной версии для обновления (modulePartNumber=1, objectSchema="TST_OM_BASE", currentVersion="", installVersion="3.5.0", isRevertInstall=0, isFullInstall=0, install_result_id=).%'
  );

  checkCase(
    'Откат обновления без установленной версии'
    , currentVersion        => null
    , installVersion        => '3.5.0'
    , isRevertInstall       => 1
    , resultVersion         => '3.4.0'
    , execErrorMessageMask  =>
'%ORA-20195: Нет установленной версии для отката (modulePartNumber=1, objectSchema="TST_OM_BASE", currentVersion="", installVersion="3.5.0", isRevertInstall=1, isFullInstall=0, resultVersion="3.4.0", install_result_id=).%'
  );

  checkCase(
    'Удаление модуля без установленной версии'
    , currentVersion        => null
    , installVersion        => '3.5.0'
    , isRevertInstall       => 1
    , isFullInstall         => 1
  );

  checkCase(
    'Первоначальная установка'
    , currentVersion        => null
    , installVersion        => '3.5.0'
    , isFullInstall         => 1
  );

  checkCase(
    'Повторная установка'
    , currentVersion        => '3.5.0'
    , installVersion        => '3.5.0'
    , isFullInstall         => 1
  );

  checkCase(
    'Установка старшей версии'
    , currentVersion        => '3.5.0'
    , installVersion        => '3.6.0'
    , isFullInstall         => 1
  );

  checkCase(
    'Установка младшей версии'
    , currentVersion        => '3.5.0'
    , installVersion        => '3.4.0'
    , isFullInstall         => 1
    , execErrorMessageMask  =>
'%ORA-20195: Устанавливаемая версия младше, чем установленная ранее (modulePartNumber=1, objectSchema="TST_OM_BASE", currentVersion="3.5.0", installVersion="3.4.0", isRevertInstall=0, isFullInstall=1, install_result_id=%).%'
  );

  checkCase(
    'Установка обновления'
    , currentVersion        => '3.5.0'
    , installVersion        => '3.6.0'
  );

  checkCase(
    'Повторная установка обновления'
    , currentVersion        => '3.5.0'
    , installVersion        => '3.5.0'
  );

  checkCase(
    'Установка обновления младшей версии'
    , currentVersion        => '3.5.0'
    , installVersion        => '3.4.0'
    , execErrorMessageMask  =>
'%ORA-20195: Устанавливаемая версия младше, чем установленная ранее (modulePartNumber=1, objectSchema="TST_OM_BASE", currentVersion="3.5.0", installVersion="3.4.0", isRevertInstall=0, isFullInstall=0, install_result_id=%).%'
  );

  checkCase(
    'Откат обновления'
    , currentVersion        => '3.6.0'
    , installVersion        => '3.6.0'
    , isRevertInstall       => 1
    , resultVersion         => '3.5.0'
  );

  checkCase(
    'Повторный откат обновления'
    , currentVersion        => '3.5.0'
    , installVersion        => '3.5.0'
    , isRevertInstall       => 1
    , resultVersion         => '3.5.0'
  );

  checkCase(
    'Откат обновления к старшей версии'
    , currentVersion        => '3.5.0'
    , installVersion        => '3.5.0'
    , isRevertInstall       => 1
    , resultVersion         => '3.6.0'
    , execErrorMessageMask  =>
'%ORA-20195: После отмены установки версии не можеть остаться более старшая версия (modulePartNumber=1, objectSchema="TST_OM_BASE", currentVersion="3.5.0", installVersion="3.5.0", isRevertInstall=1, isFullInstall=0, resultVersion="3.6.0", install_result_id=%).%'
  );

  checkCase(
    'Удаление модуля'
    , currentVersion        => '3.5.0'
    , installVersion        => '3.5.0'
    , isRevertInstall       => 1
    , isFullInstall         => 1
  );

  pkg_TestUtility.endTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while testing checkInstallVersion ('
        || 'testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testCheckInstallVersion;

end pkg_ModuleInfoTest;
/
