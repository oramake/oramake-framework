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
Get_HttpMethod constant varchar2(10) := 'GET';

/* const: Post_HttpMethod
  HTTP Method "POST".
*/
Post_HttpMethod constant varchar2(10) := 'POST';




/* group: ������� */



/* group: �������� ������� �������� �� http */

/* pproc: processHttpRequest
  ��������� ������ �� ��������� HTTP.

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
  requestText                 - ����� �������
  httpMethod                  - HTTP method for request
                                ( default POST if requestText not empty
                                  oterwise GET)
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

  ( <body::processHttpRequest>)
*/
procedure processHttpRequest(
  statusCode out nocopy integer
  , reasonPhrase out nocopy varchar2
  , contentType out nocopy varchar2
  , entityBody out nocopy clob
  , execSecond out nocopy number
  , requestUrl varchar2
  , requestText clob
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
  , httpMethod varchar2 := null
)
return clob;

end pkg_WebUtility;
/
