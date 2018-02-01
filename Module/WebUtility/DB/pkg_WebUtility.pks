create or replace package pkg_WebUtility
authid current_user
is
/* package: pkg_WebUtility
  Интерфейсный пакет модуля WebUtility.

  SVN root: Oracle/Module/WebUtility
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
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




/* group: Функции */



/* group: Отправка внешних запросов по http */

/* pproc: processHttpRequest
  Выполняет запрос по протоколу HTTP.

  Параметры:
  statusCode                  - Код результата запроса ( HTTP Status-Code)
                                ( возврат)
  reasonPhrase                - Описание результата запроса
                                ( HTTP Reason-Phrase)
                                ( возврат, максимум 256 символов)
  contentType                 - Тип тела ответа ( HTTP Content-Type)
                                ( возврат, максимум 1024 символа)
  entityBody                  - Тело ответа ( HTTP entity-body)
                                ( возврат)
  execSecond                  - время выполнения запроса
                                ( в секундах, -1 если не удалось измерить)
                                ( возврат)
  requestUrl                  - URL для выполнения запроса
  requestText                 - Текст запроса
  httpMethod                  - HTTP method for request
                                ( default POST if requestText not empty
                                  oterwise GET)
  maxWaitSecond               - Максимальное время ожидания ответа по запросу
                                ( в секундах, по умолчанию 60 секунд)
  headerText                  - список заголовков к запросу
                                ( по умолчанию передается Content-Type
                                  и Content-Length)

  Замечания:
  - заголовки передаются в виде текста
  (code)
  Host: ads.betweendigital.com
  Connection: keep-alive
  ...
  (end code)
  - для успешного выполнения запроса необходимо выдать права ACL пользователю,
    вызывающему процедуру

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
