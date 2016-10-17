create or replace package pkg_MailHandler is
/* package: pkg_MailHandler
  Внутренние процедуры обработки модуля Mail.
*/



/* group: Функции */



/* group: Отправка писем */

/* pfunc: sendMessage
  Отправляет ожидающие отправки сообщения и возвращает число отправленных
  сообщений.

  Параметры:
  smtpServer                  - имя ( или ip-адрес) SMTP-сервера
                                Значение null приравнивается к
                                pkg_Common.getSmtpServer.
  maxMessageCount             - ограничение по количеству отправляемых сообщений
                                за один запуск процедуры. В случае передачи
                                null, ограничение не используется.

  Возврат:
  число отправленных сообщений.

  Замечание:
  - в вызываемой процедуре <body::sendMessageJava> происходит фиксация
    автономной транзакции после каждого отправляемого email-сообщения;

  ( <body::sendMessage>)
*/
function sendMessage(
  smtpServer varchar2 := null
  , maxMessageCount integer := null
)
return integer;

/* pfunc: sendHandler
  Обработчик отправки писем.

  Параметры:
  smtpServerList              - список имён ( или ip-адресов) SMTP-серверов
                                через ",".
                                Значение null приравнивается к pkg_Common.getSmtpServer.
  maxMessageCount             - ограничение по количеству отправляемых сообщений
                                за один запуск процедуры. В случае передачи
                                null, ограничение не используется.

  Замечание:
  - в вызываемой процедуре <body::sendMessage> происходит фиксация транзакции.

  ( <body::sendHandler>)
*/
procedure sendHandler(
  smtpServerList varchar2 := null
  , maxMessageCount integer := null
);



/* group: Получение писем */

/* pfunc: fetchMessageImmediate
  Получает почту и возвращает число полученных сообщений ( в том же сеансе).

  Параметры:
  errorMessage                - сообщение об ошибке получения сообщений
                                ( возврат)
  errorCode                   - код сообщения об ошибке
                                ( возврат)
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  password                    - пароль для подключения к почтовому ящику
                                ( если null, то используется пароль из url)
  recipientAddress            - адрес получателя, под которым будут сохраняться
                                полученные сообщения ( при отсутствии выделяется
                                из URL как user@domen)
  isGotMessageDeleted         - удалять ли из ящика полученные сообщения
  fetchRequestId              - id запроса извлечения из ящика

  Возврат:
  число полученных сообщений

  Замечания:
  - функция выполняется в автономной транзакции;

  ( <body::fetchMessageImmediate>)
*/
function fetchMessageImmediate(
  errorMessage in out varchar2
  , errorCode in out integer
  , url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , isGotMessageDeleted integer := null
  , fetchRequestId integer := null
)
return integer;

/* pfunc: processFetchRequest
  Обработка текущих запросов на извлечение из ящиков

  Параметры:
  batchShortName              - обработка запросов только от определённого
                                прикладного батча
  fetchRequestId              - параметр для обработки определённого запроса

  Возврат:
  количество обработанных запросов.

  ( <body::processFetchRequest>)
*/
function processFetchRequest(
  batchShortName varchar2 := null
  , fetchRequestId integer := null
)
return integer;

/* pproc: fetchHandler
  Обработчик запросов на извлечение из ящиков

  Параметры:
  checkRequestInterval        - интервал для проверки наличия запросов для
                                обработки
  maxRequestCount             - максимальное количество обрабатываемых
                                запросов за запуск
  batchShortName              - параметр для обработки запросов только от
                                определённого прикладного батча

  ( <body::fetchHandler>)
*/
procedure fetchHandler(
  checkRequestInterval interval day to second
  , maxRequestCount integer := null
  , batchShortName varchar2 := null
);



/* group: Вспомогательные функции */

/* pfunc: notifyError
  Информирует об ошибках ( по e-mail) и возвращает число найденных ошибок.

  Параметры:
  sendLimit                   - лимит времени, в течении которого должна быть
                                произведена попытка отправки сообщения ( при
                                передаче null будет использовано значение по
                                умолчанию)
  smtpServerList              - список имён ( или ip-адресов) SMTP-серверов
                                через ",". Пустая строка приравнивается
                                к pkg_Common.getSmtpServer.

  Возврат:
    - количество ошибок

  ( <body::notifyError>)
*/
function notifyError(
  sendLimit interval day to second := null
  , smtpServerList varchar2 := null
)
return integer;

/* pfunc: clearExpiredMessage
  Удаляет сообщения с истекшим сроком жизни и возвращает число удаленных
  сообщений.

  Параметры:
  checkDate                   - дата проверки ( по умолчанию текущая дата)

  Замечание:
  если сообщение входит в цепочку ( по source_message_id), то оно будет удалено
  только вместе со всей цепочкой ( т.е. когда у всех сообщений в цепочке
  истечет срок жизни).
  Вложенные сообщения удаляются при истечении срока жизни сообщения основного
  сообщения.

  ( <body::clearExpiredMessage>)
*/
function clearExpiredMessage(
  checkDate date := null
)
return integer;

/* pfunc: clearFetchRequest
  Удаляет запросы извлечения из ящика
  с датой создания до определённой
  даты

  Параметры:
  beforeDate                  - дата, до которой удалять запросы

  ( <body::clearFetchRequest>)
*/
procedure clearFetchRequest(
  beforeDate date
);

end pkg_MailHandler;
/
