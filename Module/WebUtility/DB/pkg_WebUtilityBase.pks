create or replace package pkg_WebUtilityBase is
/* package: pkg_WebUtilityBase
  Common internal constans and functions of module.

  SVN root: Oracle/Module/WebUtility
*/



/* group: Functions */

/* pproc: setNextTestResponse
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

  ( <body::setNextTestResponse>)
*/
procedure setNextTestResponse(
  statusCode integer := null
  , reasonPhrase varchar2 := null
  , contentType varchar2 := null
  , entityBody clob := null
  , execSecond number := null
);

/* pfunc: getTestResponse
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

  ( <body::getTestResponse>)
*/
function getTestResponse(
  statusCode in out nocopy integer
  , reasonPhrase in out nocopy varchar2
  , contentType in out nocopy varchar2
  , entityBody in out nocopy clob
  , execSecond in out nocopy number
)
return boolean;

end pkg_WebUtilityBase;
/
