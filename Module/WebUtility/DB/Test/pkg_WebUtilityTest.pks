create or replace package pkg_WebUtilityTest is
/* package: pkg_WebUtilityTest
  Functions for testing module.

  SVN root: Oracle/Module/WebUtility
*/



/* group: Constants */



/* group: Test parameters */

/* const: TestHttpAbsentHost_OptSName
  Short name of parameter
  "Tests: URL of non-existent accessible host".
*/
TestHttpAbsentHost_OptSName constant varchar2(30) := 'TestHttpAbsentHost';

/* const: TestHttpAbsentPath_OptSName
  Short name of parameter
  "Tests: URL with non-existent path on accessible host".
*/
TestHttpAbsentPath_OptSName constant varchar2(30) := 'TestHttpAbsentPath';

/* const: TestHttpEchoUrl_OptSName
  Short name of parameter
  "Tests: URL to echo server ( returns headers and request data as plain text)".
*/
TestHttpEchoUrl_OptSName constant varchar2(30) := 'TestHttpEchoUrl';

/* const: TestHttpHeadersUrl_OptSName
  Short name of parameter
  "Tests: URL to returns request headers".
*/
TestHttpHeadersUrl_OptSName constant varchar2(30) := 'TestHttpHeadersUrl';

/* const: TestHttpTextUrl_OptSName
  Short name of parameter
  "Tests: URL for downloading text data available via HTTP"
*/
TestHttpTextUrl_OptSName constant varchar2(30) := 'TestHttpTextUrl';

/* const: TestHttpTextPattern_OptSName
  Short name of parameter
  "Tests: Pattern (SQL like) for text data downloaded by URL specified in TestHttpTextUrl parameter".
*/
TestHttpTextPattern_OptSName constant varchar2(30) := 'TestHttpTextPattern';



/* group: Functions */



/* group: For other modules */

/* pfunc: getTestOptionList
  Returns test parameters.

  ( <body::getTestOptionList>)
*/
function getTestOptionList
return opt_option_list_t;

/* pproc: setNextResponse
  Sets response data for next request (works only in test database).
  Call without parameters (or with null values for statusCode and entityBody)
  clears the previously set response data.

  Parameters:
  statusCode                  - Request result code (HTTP Status-Code)
                                (default is 200 if entityBody is not null)
  reasonPhrase                - Description of the query result
                                (HTTP Reason-Phrase)
                                (default is "OK" if entityBody is not null)
  contentType                 - Type of response (HTTP Content-Type)
                                (with default value if entityBody is not null)
  entityBody                  - Response to request (HTTP entity-body)
                                (default is null)
  execSecond                  - Request execution time
                                (default is -1)


  Remarks:
  - by default for contentType uses value <pkg_WebUtility.Xml_ContentType> if
    entityBody starts with "<?xml ", value <pkg_WebUtility.Json_ContentType>
    if request text starts with "[" or "{", else uses value
    <pkg_WebUtility.WwwForm_ContentType> if entityBody is not null;

  ( <body::setNextResponse>)
*/
procedure setNextResponse(
  statusCode integer := null
  , reasonPhrase varchar2 := null
  , contentType varchar2 := null
  , entityBody clob := null
  , execSecond number := null
);



/* group: Internal tests */

/* pproc: testGetHttpResponse
  Test data retrieval using an HTTP request at a given URL.

  Parameters:
  testCaseNumber              - Number of test case to be tested
                                (default unlimited)

  ( <body::testGetHttpResponse>)
*/
procedure testGetHttpResponse(
  testCaseNumber integer := null
);

end pkg_WebUtilityTest;
/
