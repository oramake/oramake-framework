create or replace package body pkg_WebUtilityTest is
/* package body: pkg_WebUtilityTest::body */



/* group: Variables */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_WebUtility.Module_Name
  , objectName  => 'pkg_WebUtilityTest'
);

/* ivar: opt
  Test parameters.
*/
opt opt_plsql_object_option_t := opt_plsql_object_option_t(
  moduleName    => pkg_WebUtility.Module_Name
  , objectName  => 'pkg_WebUtilityTest'
);



/* group: ������� */

/* proc: testGetHttpResponse
  Test data retrieval using an HTTP request at a given URL.

  Parameters:
  testCaseNumber              - Number of test case to be tested
                                (default unlimited)
*/
procedure testGetHttpResponse(
  testCaseNumber integer := null
)
is

  -- Number of current (or last) test case
  checkCaseNumber integer := 0;



  /*
    Checks test case.
  */
  procedure checkCase(
    caseDescription varchar2
    , requestUrl varchar2
    , requestText clob := null
    , httpMethod varchar2 := null
    , resultHeadMask varchar2 := null
    , resultTailMask varchar2 := null
    , execErrorMessageMask varchar2 := null
    , nextCaseUsedCount pls_integer := null
  )
  is

    -- Description of test case
    cinfo varchar2(200) :=
      'CASE ' || to_char( checkCaseNumber + 1)
      || ' "' || caseDescription || '": '
    ;

    -- Runtime error message
    execErrorMessage varchar2(32767);

    -- Result of execution
    execResult clob;

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
    logger.info( '*** ' || cinfo);

    begin
      execResult := pkg_WebUtility.getHttpResponse(
        requestUrl          => requestUrl
        , requestText       => requestText
        , httpMethod        => httpMethod
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
                cinfo || 'Error message does not match mask'
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
      if resultHeadMask is not null
            and substr( execResult, 1, 32767) not like resultHeadMask
          then
        pkg_TestUtility.compareChar(
          actualString        => substr( execResult, 1, 32767)
          , expectedString    => resultHeadMask
          , failMessageText   =>
              cinfo || 'Result does not match head mask'
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Error while running test case ('
          || 'caseNumber=' || checkCaseNumber
          || ', caseDescription="' || caseDescription || '"'
          || ').'
        )
      , true
    );
  end checkCase;



-- testGetHttpResponse
begin
  pkg_TestUtility.beginTest(
    'get HTTP response'
  );

  checkCase(
    'Non-existent host'
    , opt.getString( TestHttpAbsentHost_OptSName)
      -- ORA-29273: HTTP request failed
      -- ORA-12545: Connect failed because target host or object does not exist
    , execErrorMessageMask    => '%ORA-29273:%ORA-12545:%'
  );

  checkCase(
    'Non-existent path'
    , opt.getString( TestHttpAbsentPath_OptSName)
      -- ORA-29273: HTTP request failed
      -- ORA-12545: Connect failed because target host or object does not exist
    , execErrorMessageMask    => '%HTTP error 404: Not Found%'
  );

  checkCase(
    'Receive text by URL'
    , opt.getString( TestHttpTextUrl_OptSName)
    , resultHeadMask          => opt.getString( TestHttpTextPattern_OptSName)
  );

  pkg_TestUtility.endTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while testing getHttpResponse ('
        || 'testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testGetHttpResponse;

end pkg_WebUtilityTest;
/