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






/* group: Функции */

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
