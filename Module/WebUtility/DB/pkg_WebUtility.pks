create or replace package pkg_WebUtility
authid current_user
is
/* package: pkg_WebUtility
  ������������ ����� ������ WebUtility.

  SVN root: Oracle/Module/WebUtility
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
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



/* group: HTTP Header Fields */

/* const: ContentLength_HttpHField
  HTTP Header Field "Content-Length".
*/
ContentLength_HttpHField constant varchar2(100) := 'Content-Length';

/* const: ContentType_HttpHField
  HTTP Header Field "Content-Type".
*/
ContentType_HttpHField constant varchar2(100) := 'Content-Type';

/* const: TransferEncoding_HttpHField
  HTTP Header Field "Transfer-Encoding".
*/
TransferEncoding_HttpHField constant varchar2(100) := 'Transfer-Encoding';



/* group: ������� */



/* group: Execute of HTTP requests */

/* pproc: execHttpRequest
  Execute of HTTP request.

  ���������:
  statusCode                  - ��� ���������� ������� ( HTTP Status-Code)
                                ( �������)
  reasonPhrase                - �������� ���������� �������
                                ( HTTP Reason-Phrase)
                                ( �������, �������� 256 ��������)
  contentType                 - ��� ���� ������ ( HTTP Content-Type)
                                ( �������, �������� 1024 �������)
  entityBody                  - ���� ������ ( HTTP entity-body)
                                ( �������)
  execSecond                  - ����� ���������� �������
                                ( � ��������, -1 ���� �� ������� ��������)
                                ( �������)
  requestUrl                  - URL ��� ���������� �������
  requestText                 - Request text
                                ( default is absent)
  parameterList               - Request parameters
                                ( default is absent)
  httpMethod                  - HTTP method for request
                                ( default POST if requestText or parameterList
                                  is not empty oterwise GET)
  maxWaitSecond               - ������������ ����� �������� ������ �� �������
                                ( � ��������, �� ��������� 60 ������)
  headerText                  - ������ ���������� � �������
                                ( �� ��������� ���������� Content-Type
                                  � Content-Length)

  ���������:
  - ��������� ���������� � ���� ������
  (code)
  Host: ads.betweendigital.com
  Connection: keep-alive
  ...
  (end code)
  - ��� ��������� ���������� ������� ���������� ������ ����� ACL ������������,
    ����������� ���������

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
  , headerText varchar2 := null
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

  Return values:
  text data, returned from the HTTP request.

  ( <body::getHttpResponse>)
*/
function getHttpResponse(
  requestUrl varchar2
  , requestText clob := null
  , parameterList wbu_parameter_list_t := null
  , httpMethod varchar2 := null
)
return clob;

end pkg_WebUtility;
/
