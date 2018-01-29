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
  , maxWaitSecond integer := null
  , headerText varchar2 := null
);

end pkg_WebUtility;
/
