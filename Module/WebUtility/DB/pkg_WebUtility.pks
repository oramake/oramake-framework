create or replace package pkg_WebUtility
authid current_user
is
/* package: pkg_WebUtility
  Functions for performing HTTP requests.

  SVN root: Oracle/Module/WebUtility
*/



/* group: Constants */

/* const: Module_Name
  Name of the module to which the package belongs.
*/
Module_Name constant varchar2(30) := 'WebUtility';



/* group: HTTP Methods */

/* const: Get_HttpMethod
  HTTP Method "GET".
*/
Get_HttpMethod constant varchar2(64) := 'GET';

/* const: Post_HttpMethod
  HTTP Method "POST".
*/
Post_HttpMethod constant varchar2(64) := 'POST';



/* group: HTTP Headers */

/* const: ContentLength_HttpHeader
  HTTP Header "Content-Length".
*/
ContentLength_HttpHeader constant varchar2(100) := 'Content-Length';

/* const: ContentType_HttpHeader
  HTTP Header "Content-Type".
*/
ContentType_HttpHeader constant varchar2(100) := 'Content-Type';

/* const: TransferEncoding_HttpHeader
  HTTP Header "Transfer-Encoding".
*/
TransferEncoding_HttpHeader constant varchar2(100) := 'Transfer-Encoding';



/* group: Functions */



/* group: Execute of HTTP requests */

/* pproc: execHttpRequest
  Execute of HTTP request.

  Параметры:
  statusCode                  - Request result code (HTTP Status-Code)
                                (out)
  reasonPhrase                - Description of the query result
                                (HTTP Reason-Phrase)
                                (out, maximum 256 chars)
  contentType                 - Type of response (HTTP Content-Type)
                                (out, maximum 1024 chars)
  entityBody                  - Response to request (HTTP entity-body)
                                (out)
  execSecond                  - Request execution time
                                (in seconds, -1 if it was not possible to
                                  measure)
                                (out)
  requestUrl                  - Request URL
  requestText                 - Request text
                                (default is absent)
  parameterList               - Request parameters
                                (default is absent)
  httpMethod                  - HTTP method for request
                                (default POST if requestText or parameterList
                                  is not empty oterwise GET)
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)
  headerList                  - Request headers
                                (defaut is absent, but some headers can be
                                  added by default, see the remarks below)
  bodyCharset                 - Sets the character set of the request body when
                                the media type is text but the character set
                                is not specified in the Content-Type header
                                (default is UTF-8)

  Remarks:
  - headers in headerList with null value are not sent;
  - by default, request uses chunked transfer-encoding and sends
    "Transfer-Encoding: chunked" header ( this will be disabled if you use
    <ContentLength_HttpHeader> or <TransferEncoding_HttpHeader> in headerList);
  - by default, request sends <ContentType_HttpHeader> header with value
    "application/x-www-form-urlencoded" if it is POST request with parameters,
    with value "text/xml" if request text starts with "<?xml ",
    with value "application/json" header if request text starts with "[" or "{"
    ( this will be disabled if you use <ContentType_HttpHeader> in
    headerList);
  - data is automatically converted from the database character set to the
    request body character set;

  ( <body::execHttpRequest>)
*/
procedure execHttpRequest(
  statusCode out nocopy integer
  , reasonPhrase out nocopy varchar2
  , contentType out nocopy varchar2
  , entityBody out nocopy clob
  , execSecond out nocopy number
  , requestUrl varchar2
  , requestText clob := null
  , parameterList wbu_parameter_list_t := null
  , httpMethod varchar2 := null
  , maxWaitSecond integer := null
  , headerList wbu_header_list_t := null
  , bodyCharset varchar2 := null
);

/* pproc: checkResponseError
  Raises an exception when the Web server returns a status code other than
  successful code ( HTTP 200).

  Parameters:
  statusCode                  - Request result code (HTTP Status-Code)
  reasonPhrase                - Description of the query result
                                (HTTP Reason-Phrase)
  entityBody                  - Response to request (HTTP entity-body)

  ( <body::checkResponseError>)
*/
procedure checkResponseError(
  statusCode integer
  , reasonPhrase varchar2
  , entityBody clob
);

/* pfunc: getHttpResponse
  Returns data received by using an HTTP request at a given URL.

  Parameters:
  requestUrl                  - URL for request
  requestText                 - Request text
                                ( default is absent)
  parameterList               - Request parameters
                                ( default is absent)
  httpMethod                  - HTTP method for request
                                ( default POST if requestText not empty
                                  oterwise GET)
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)
  headerList                  - Request headers
                                (defaut is absent, but some headers can be
                                  added by default, see the remarks below)
  bodyCharset                 - Sets the character set of the request body when
                                the media type is text but the character set
                                is not specified in the Content-Type header
                                (default is UTF-8)

  Return values:
  text data, returned from the HTTP request.

  ( <body::getHttpResponse>)
*/
function getHttpResponse(
  requestUrl varchar2
  , requestText clob := null
  , parameterList wbu_parameter_list_t := null
  , httpMethod varchar2 := null
  , maxWaitSecond integer := null
  , headerList wbu_header_list_t := null
  , bodyCharset varchar2 := null
)
return clob;

end pkg_WebUtility;
/
