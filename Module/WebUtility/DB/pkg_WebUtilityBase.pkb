create or replace package body pkg_WebUtilityBase is
/* package body: pkg_WebUtilityBase::body */



/* group: Variables */

/* ivar: logger
  Logger of package.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_WebUtility.Module_Name
  , objectName  => 'pkg_WebUtilityBase'
);



/* group: Test response */

/* ivar: testResp
  Status code and reason message for next test response (status_code null if
  not sets).
*/
testResp utl_http.resp := null;

/* ivar: testRespContentType
  Type of response (HTTP Content-Type) for next test response.
*/
testRespContentType varchar2(1024);

/* ivar: testRespEntityBody
  Response to request (HTTP entity-body) for next test response.
*/
testRespEntityBody clob;

/* ivar: testRespExecSecond
  Request execution time for next test response.
*/
testRespExecSecond number;



/* group: Functions */

/* proc: setNextTestResponse
  Sets test response data for next request (works onlys in test database).
  Call without parameters (or with null values for statusCode) clears the
  previously set response data.

  Parameters:
  statusCode                  - Request result code (HTTP Status-Code)
                                (default is null)
  reasonPhrase                - Description of the query result
                                (default is null)
  contentType                 - Type of response (HTTP Content-Type)
                                (default is null)
  entityBody                  - Response to request (HTTP entity-body)
                                (default is null)
  execSecond                  - Request execution time
                                (default is null)
*/
procedure setNextTestResponse(
  statusCode integer := null
  , reasonPhrase varchar2 := null
  , contentType varchar2 := null
  , entityBody clob := null
  , execSecond number := null
)
is
begin
  if pkg_Common.isProduction() = 0 then
    testResp.status_code    := statusCode;
    testResp.reason_phrase  := reasonPhrase;
    testRespContentType     := contentType;
    testRespEntityBody      := entityBody;
    testRespExecSecond      := execSecond;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while setting test response data for next request.'
      )
    , true
  );
end setNextTestResponse;

/* func: getTestResponse
  Returns test response data for request.

  Parameters:
  statusCode                  - Request result code (HTTP Status-Code)
                                (in out)
  reasonPhrase                - Description of the query result
                                (in out)
  contentType                 - Type of response (HTTP Content-Type)
                                (in out)
  entityBody                  - Response to request (HTTP entity-body)
                                (in out)
  execSecond                  - Request execution time
                                (in out)
*/
function getTestResponse(
  statusCode in out nocopy integer
  , reasonPhrase in out nocopy varchar2
  , contentType in out nocopy varchar2
  , entityBody in out nocopy clob
  , execSecond in out nocopy number
)
return boolean
is

  isOk boolean := false;

begin
  if testResp.status_code is not null then
    statusCode    := testResp.status_code;
    reasonPhrase  := testResp.reason_phrase;
    contentType   := testRespContentType;
    entityBody    := testRespEntityBody;
    execSecond    := testRespExecSecond;

    testResp := null;
    isOk := true;
  end if;
  return isOk;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Error while returns test response data for request.'
      )
    , true
  );
end getTestResponse;

end pkg_WebUtilityBase;
/
