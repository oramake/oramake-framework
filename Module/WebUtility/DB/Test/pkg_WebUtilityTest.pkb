create or replace package body pkg_WebUtilityTest is
/* package body: pkg_WebUtilityTest::body */



/* group: Variables */

/* ivar: logger
  Логер пакета.
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



/* group: Функции */

/* func: getTestOptionList
  Returns test parameters.
*/
function getTestOptionList
return opt_option_list_t
is
begin
  return opt;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while returning test parameters.'
      )
    , true
  );
end getTestOptionList;

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
    , parameterList wbu_parameter_list_t := null
    , httpMethod varchar2 := null
    , disableChunkedEncFlag integer := null
    , headerList wbu_header_list_t := null
    , bodyCharset varchar2 := null
    , maxWaitSecond integer := null
    , resultPatternList cmn_string_table_t := null
    , resultMissingPatternList cmn_string_table_t := null
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
    logger.info( '*** ' || cinfo);

    begin
      execResult := pkg_WebUtility.getHttpResponse(
        requestUrl                => requestUrl
        , requestText             => requestText
        , parameterList           => parameterList
        , httpMethod              => httpMethod
        , disableChunkedEncFlag   => disableChunkedEncFlag
        , headerList              => headerList
        , bodyCharset             => bodyCharset
        , maxWaitSecond           => maxWaitSecond
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
      if resultPatternList is not null then
        i := 1;
        while i <= resultPatternList.last() loop
          if coalesce( execResult not like resultPatternList( i), true) then
            pkg_TestUtility.failTest(
              failMessageText   =>
                cinfo || 'Result does not match pattern #' || i
                || ' ( pattern="' || resultPatternList( i) || '"'
                || ')'
            );
            exit;
          end if;
          i := resultPatternList.next( i);
        end loop;
      end if;
      if resultMissingPatternList is not null then
        i := 1;
        while i <= resultMissingPatternList.last() loop
          if execResult like resultMissingPatternList( i) then
            pkg_TestUtility.failTest(
              failMessageText   =>
                cinfo || 'Result matches missing pattern #' || i
                || ' ( pattern="' || resultMissingPatternList( i) || '"'
                || ')'
            );
            exit;
          end if;
          i := resultPatternList.next( i);
        end loop;
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
    , resultPatternList       =>
        cmn_string_table_t(
          opt.getString( TestHttpTextPattern_OptSName)
        )
  );

  checkCase(
    'Illegal arguments: use requestText and parameterList'
    , opt.getString( TestHttpTextUrl_OptSName)
    , requestText             => 'test'
    , parameterList           =>
        wbu_parameter_list_t( wbu_parameter_t( 'param1', null))
    , execErrorMessageMask    =>
        '%ORA-20195: Simultaneous use of request text and parameters is incorrect.%'
  );

  checkCase(
    'POST (by default) with parameters'
    , opt.getString( TestHttpEchoUrl_OptSName)
    , parameterList           =>
        wbu_parameter_list_t(
          wbu_parameter_t( 'param1', 'valueOfParam1')
          , wbu_parameter_t( 'param2', 'valueOfParam2')
        )
    , resultPatternList       =>
        cmn_string_table_t(
          '%POST%'
          , '%application/x-www-form-urlencoded%'
            -- Transfer-Encoding: chunked
          , '%chunked%'
          , '%param1%=%valueOfParam1%'
          , '%param2%=%valueOfParam2%'
        )
  );

  checkCase(
    'Empty Transfer-Encoding header value'
    , opt.getString( TestHttpEchoUrl_OptSName)
    , parameterList           =>
        wbu_parameter_list_t(
          wbu_parameter_t( 'param1', 'valueOfParam1')
          , wbu_parameter_t( 'param2', 'valueOfParam2')
        )
    , headerList              =>
        wbu_header_list_t(
          wbu_header_t( pkg_WebUtility.TransferEncoding_HttpHeader, null)
        )
    , resultPatternList       =>
        cmn_string_table_t(
          '%POST%'
          , '%application/x-www-form-urlencoded%'
          , '%param1%=%valueOfParam1%'
          , '%param2%=%valueOfParam2%'
        )
    , resultMissingPatternList  =>
        cmn_string_table_t(
          -- Transfer-Encoding: chunked
          '%chunked%'
        )
  );

  checkCase(
    'Disable chunked Transfer-Encoding'
    , opt.getString( TestHttpEchoUrl_OptSName)
    , parameterList           =>
        wbu_parameter_list_t(
          wbu_parameter_t( 'param1', 'valueOfParam1')
          , wbu_parameter_t( 'param2', 'valueOfParam2')
        )
    , disableChunkedEncFlag   => 1
    , resultPatternList       =>
        cmn_string_table_t(
          '%POST%'
          , '%application/x-www-form-urlencoded%'
          , '%param1%=%valueOfParam1%'
          , '%param2%=%valueOfParam2%'
        )
    , resultMissingPatternList  =>
        cmn_string_table_t(
          -- Transfer-Encoding: chunked
          '%chunked%'
        )
  );

  checkCase(
    'GET with parameters'
    , opt.getString( TestHttpEchoUrl_OptSName)
    , parameterList           =>
        wbu_parameter_list_t(
          wbu_parameter_t( 'param1', 'valueOfParam1')
          , wbu_parameter_t( 'param2', 'valueOfParam2')
        )
    , httpMethod              => pkg_WebUtility.Get_HttpMethod
    , resultPatternList       =>
        cmn_string_table_t(
          '%GET%'
          , '%param1%=%valueOfParam1%'
          , '%param2%=%valueOfParam2%'
        )
  );

  checkCase(
    'Use headerList'
    , opt.getString( TestHttpHeadersUrl_OptSName)
    , headerList              =>
        wbu_header_list_t(
          wbu_header_t( 'X-Custom-Header', 'value of custom header')
          , wbu_header_t(
              'User-Agent'
              , 'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36'
          )
        )
    , resultPatternList       =>
        cmn_string_table_t(
          '%value of custom header%'
          , '%Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36%'
        )
  );

  checkCase(
    'Set Content-Type for XML'
    , opt.getString( TestHttpHeadersUrl_OptSName)
    , requestText             => '<?xml version="1.0"><a/>'
    , resultPatternList       => cmn_string_table_t( '%text/xml%')
  );

  checkCase(
    'Set Content-Type for JSON object'
    , opt.getString( TestHttpHeadersUrl_OptSName)
    , requestText             => '{ "n": 1 }'
    , resultPatternList       =>
        cmn_string_table_t( '%' || pkg_WebUtility.Json_ContentType || '%')
  );

  checkCase(
    'Set Content-Type for JSON array'
    , opt.getString( TestHttpHeadersUrl_OptSName)
    , requestText             => '[ 1, 2 ]'
    , resultPatternList       =>
        cmn_string_table_t( '%' || pkg_WebUtility.Json_ContentType || '%')
  );

  checkCase(
    'Priority of custom Content-Type'
    , opt.getString( TestHttpHeadersUrl_OptSName)
    , requestText             => '[ 1, 2 ]'
    , headerList              => wbu_header_list_t(
        wbu_header_t( pkg_WebUtility.ContentType_HttpHeader, 'text/plain')
      )
    , resultPatternList       => cmn_string_table_t( '%text/plain%')
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
