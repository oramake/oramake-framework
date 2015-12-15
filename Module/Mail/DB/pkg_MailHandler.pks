create or replace package pkg_MailHandler is
/* package: pkg_MailHandler
  Внутренние процедуры обработки модуля Mail.
*/

/* pfunc: NotifyError
  Информирует об ошибках ( <body::NotifyError>).
*/
function NotifyError(
  sendLimit interval day to second := null
  , smtpServerList varchar2 := null
)
return integer;

/* pfunc: ClearExpiredMessage
  Удаляет сообщения с истекшим сроком жизни ( <body::ClearExpiredMessage>).
*/
function ClearExpiredMessage(
  checkDate date := null
)
return integer;

/* pfunc: ClearFetchRequest
  Удаляет запросы извлечения из ящика 
  (<body::ClearFetchRequest>)
*/
procedure ClearFetchRequest(
  beforeDate date
);

/* pfunc: SendMessage
  Отправляет ожидающие отправки сообщения ( <body::SendMessage>).
*/
function SendMessage(
  smtpServer varchar2 := null
  , maxMessageCount integer := null
)
return integer;

/* pfunc: SendHandler
  Обработчик отправки писем ( <body::SendHandler>).
*/
procedure SendHandler(
  smtpServerList varchar2 := null
  , maxMessageCount integer := null
);

/* pfunc: ProcessFetchRequest
  Обработка текущих запросов на извлечение из ящиков
  (<body::ProcessFetchRequest>)
*/
function ProcessFetchRequest(
  batchShortName varchar2 := null
  , fetchRequestId integer := null
)
return integer;

/* pproc: FetchHandler
  Обработчик запросов на извлечение из ящиков
  (<body::FetchHandler>)
*/
procedure FetchHandler(
  checkRequestInterval interval day to second
  , maxRequestCount integer := null
  , batchShortName varchar2 := null
);

end pkg_MailHandler;
/
