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

/* const: SoapAction_HttpHeader
  HTTP Header "SOAPAction", used to indicate the intent of the SOAP request.
*/
SoapAction_HttpHeader constant varchar2(100) := 'SOAPAction';

/* const: TransferEncoding_HttpHeader
  HTTP Header "Transfer-Encoding".
*/
TransferEncoding_HttpHeader constant varchar2(100) := 'Transfer-Encoding';



/* group: Values for "Content-Type" HTTP Header */

/* const: Json_ContentType
  Value of "Content-Type" HTTP Header for data in JSON format.
*/
Json_ContentType constant varchar2(100) := 'application/json';

/* const: SoapMessage_ContentType
  Value of "Content-Type" HTTP Header for SOAP message.
*/
SoapMessage_ContentType constant varchar2(100) := 'text/xml; charset="utf-8"';



/* group: Functions */



/* group: Execute of HTTP requests */

/* pproc: execHttpRequest
  Execute of HTTP request.

  Parameters:
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
  disableChunkedEncFlag       - Disable use chunked transfer encoding when
                                sending request
                                (1 yes, 0 no (is default))
  headerList                  - Request headers
                                (defaut is absent, but some headers can be
                                  added by default, see the remarks below)
  bodyCharset                 - Sets the character set of the request body when
                                the media type is text but the character set
                                is not specified in the Content-Type header
                                (default is UTF-8)
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)

  Remarks:
  - headers in headerList with null value are not sent;
  - by default, request uses chunked transfer-encoding and sends
    "Transfer-Encoding: chunked" header ( this will be disabled if
    disableChunkedEncFlag=1 or you use <ContentLength_HttpHeader> or
    <TransferEncoding_HttpHeader> in headerList);
  - by default, request sends <ContentType_HttpHeader> header with value
    "application/x-www-form-urlencoded" if it is POST request with parameters,
    with value "text/xml" if request text starts with "<?xml ",
    with value <Json_ContentType> if request text starts with "[" or "{"
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
  , disableChunkedEncFlag integer := null
  , headerList wbu_header_list_t := null
  , bodyCharset varchar2 := null
  , maxWaitSecond integer := null
);

/* pproc: checkResponseError
  Raises an exception when the Web server returns a status code other than
  successful code ( HTTP 200).

  Parameters:
  statusCode                  - Request result code (HTTP Status-Code)
  reasonPhrase                - Description of the query result
                                (HTTP Reason-Phrase)
  entityBody                  - Response to request (HTTP entity-body)
  soapRequestFlag             - SOAP request was sent
                                (1 yes, 0 no (by default))

  Remarks:
  - in the case of specifying soapRequestFlag = 1, an attempt is made to
    obtain error information according to the format of the SOAP response
    (from the tag Fault);

  ( <body::checkResponseError>)
*/
procedure checkResponseError(
  statusCode integer
  , reasonPhrase varchar2
  , entityBody clob
  , soapRequestFlag integer := null
);

/* pfunc: getResponseXml
  Attempts to return response in XML format.

  Parameters:
  entityBody                  - Response text
  contentType                 - Type of response (HTTP Content-Type)
                                (default is unknown)

  Return:
  response in XML format.

  ( <body::getResponseXml>)
*/
function getResponseXml(
  entityBody clob
  , contentType varchar2 := null
)
return xmltype;

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
  disableChunkedEncFlag       - Disable use chunked transfer encoding when
                                sending request
                                (1 yes, 0 no (is default))
  headerList                  - Request headers
                                (defaut is absent, but some headers can be
                                  added by default, see the remarks below)
  bodyCharset                 - Sets the character set of the request body when
                                the media type is text but the character set
                                is not specified in the Content-Type header
                                (default is UTF-8)
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)

  Return:
  text data, returned from the HTTP request.

  ( <body::getHttpResponse>)
*/
function getHttpResponse(
  requestUrl varchar2
  , requestText clob := null
  , parameterList wbu_parameter_list_t := null
  , httpMethod varchar2 := null
  , disableChunkedEncFlag integer := null
  , headerList wbu_header_list_t := null
  , bodyCharset varchar2 := null
  , maxWaitSecond integer := null
)
return clob;

/* pfunc: getSoapResponse
  Returns SOAP message, received by using HTTP request to web service.

  Parameters:
  requestUrl                  - URL of web service
  soapAction                  - Action for request
  soapMessage                 - Text of SOAP message to web service
  disableChunkedEncFlag       - Disable use chunked transfer encoding when
                                sending request
                                (1 yes, 0 no (is default))
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)

  Return:
  XML with SOAP message, received from web service.

  ( <body::getSoapResponse>)
*/
function getSoapResponse(
  requestUrl varchar2
  , soapAction varchar2
  , soapMessage clob
  , disableChunkedEncFlag integer := null
  , maxWaitSecond integer := null
)
return xmltype;

/* pfunc: getSoapResponse( PARAMETERS)
  Returns SOAP message, received by using HTTP POST-request with parameters.

  Parameters:
  requestUrl                  - URL of web service
  parameterList               - Request parameters
  disableChunkedEncFlag       - Disable use chunked transfer encoding when
                                sending request
                                (1 yes, 0 no (is default))
  headerList                  - Request headers
                                (defaut is absent, but some headers can be
                                  added by default, see the remarks below)
  maxWaitSecond               - Maximum response time on request
                                (in seconds, default 60 seconds)

  Return:
  XML with SOAP message, received by request.

  ( <body::getSoapResponse( PARAMETERS)>)
*/
function getSoapResponse(
  requestUrl varchar2
  , parameterList wbu_parameter_list_t
  , disableChunkedEncFlag integer := null
  , headerList wbu_header_list_t := null
  , maxWaitSecond integer := null
)
return xmltype;

end pkg_WebUtility;
/
