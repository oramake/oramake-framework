begin
  pkg_ModuleInfoTest.testGetModuleId(
    findModuleString => 'Oracle/Module/ModuleInfo@711'
    , moduleName => 'ModuleInfo'
    , raiseExceptionFlag => 1
    , searchResult => 1
  );
  pkg_ModuleInfoTest.testGetModuleId(
    findModuleString => 'Oracle/Module/ModuleInfo@711'
    , moduleName => 'ModuleInfo'
    , svnRoot => 'Oracle'
    , raiseExceptionFlag => 1
    , searchResult => 0
    , exceptionFlag => 1
  );
  pkg_ModuleInfoTest.testGetModuleId(
    findModuleString => 'Oracle/Module/ModuleInfo'
    , raiseExceptionFlag => 0
    , searchResult => 1
  );
end;
/

