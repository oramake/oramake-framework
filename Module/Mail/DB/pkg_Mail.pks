create or replace package pkg_Mail is
/* package: pkg_Mail
  Интерфейсный пакет модуля Mail.
*/

/* const: Module_Name
  Название модуля, к которому относится пакет
*/
Module_Name constant varchar2(30) := 'Mail';

/* Group: Коды состояния сообщения */

/* const: Received_MessageStateCode
  Код состояния сообщения "Получено"
*/
Received_MessageStateCode constant varchar2(10) := 'R';

/* const: Nested_MessageStateCode
  Код состояния сообщения "Вложенное"
*/
Nested_MessageStateCode constant varchar2(10) := 'N';

/* const: Processed_MessageStateCode
  Код состояния сообщения "Обработано"
*/
Processed_MessageStateCode constant varchar2(10) := 'P';

/* const: ProcessError_MessageStateCode
  Код состояния сообщения "Ошибка обработки"
*/
ProcessError_MessageStateCode constant varchar2(10) := 'PE';

/* const: WaitSend_MessageStateCode
  Код состояния сообщения "Ожидает отправки"
*/
WaitSend_MessageStateCode constant varchar2(10) := 'WS';

/* const: SendCanceled_MessageStateCode
  Код состояния сообщения "Отправка отменена".
  Выставляется при отмене отправки ожидающих отправки сообщений.
*/
SendCanceled_MessageStateCode constant varchar2(10) := 'SC';

/* const: Send_MessageStateCode
  Код состояния сообщения "Отправлено"
*/
Send_MessageStateCode constant varchar2(10) := 'S';

/* const: SendError_MessageStateCode
  Код состояния сообщения "Ошибка отправки"
*/
SendError_MessageStateCode constant varchar2(10) := 'SE';

/* Group: MIME-типы данных */

/* const: PlainText_MimeType
  Название MIME-типа для текстовых данных
*/
PlainText_MimeType constant varchar2(40) := 'text/plain';

/* const: BinaryData_MimeType
  Название MIME-типа для бинарных данных
*/
BinaryData_MimeType constant varchar2(40) := 'application/octet-stream';

/* const: ImageJPEGData_MimeType
  Название MIME-типа для изображения JPEG
*/
ImageJPEGData_MimeType constant varchar2(40) := 'image/jpeg';

/* Group: Functions public */

/* pproc: SendMail
  Отправляет письмо ( немедленно) ( <body::SendMail>).
*/
procedure SendMail(
  sender varchar2
  , recipient varchar2
  , copyRecipient varchar2 := null
  , subject varchar2
  , messageText clob
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob := null
  , smtpServer varchar2 := null
  , isHTML boolean := null
);
/* pfunc: FetchMessageImmediate(out error)
  Получает почту и возвращает число полученных сообщений
  ( <body::FetchMessageImmediate(out error)>)
*/
function FetchMessageImmediate(
 url varchar2
 , password varchar2 := null
 , recipientAddress varchar2 := null
 , isGotMessageDeleted integer := null
 , fetchRequestId integer := null
 , errorMessage in out varchar2
 , errorCode in out integer
)
return integer;

/* pfunc: FetchMessageImmediate
  Получает почту и возвращает число полученных сообщений
  ( <body::FetchMessageImmediate>)
*/
function FetchMessageImmediate
 (url varchar2
 , password varchar2 := null
 , recipientAddress varchar2 := null
)
return integer;

/* pfunc: FetchMessage
  Получает почтовые сообщения ( <body::FetchMessage>).
*/
function FetchMessage
 (url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
 )
 return integer;
/* pfunc: GetMessage
  Возвращает Id сообщения для обработки ( <body::GetMessage>).
*/
function GetMessage(
  url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , expireDate date := null
)
return integer;
/* pfunc: GetMessage( out SenderAddress)
  Возвращает сообщение для обработки
  ( <body::GetMessage( out SenderAddress)>).
*/
function GetMessage(
  senderAddress out nocopy varchar2
  , url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , expireDate date := null
)
return integer;
/* pfunc: GetMessage( out DATA)
  Возвращает сообщение для обработки ( <body::GetMessage( out DATA)>).
*/
function GetMessage(
  senderAddress out nocopy varchar2
  , sendDate out nocopy timestamp with time zone
  , subject out nocopy varchar2
  , messageText out nocopy clob
  , url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , expireDate date := null
)
return integer;
/* pfunc: GetMessage( out DATA, out ATTACHMENT)
  Возвращает сообщение и вложение ( если есть) для обработки
  ( <body::GetMessage( out DATA, out ATTACHMENT)>).
*/
function GetMessage(
  senderAddress out nocopy varchar2
  , sendDate out nocopy timestamp with time zone
  , subject out nocopy varchar2
  , messageText out nocopy clob
  , attachmentFileName out nocopy varchar2
  , attachmentType out nocopy varchar2
  , attachmentData out nocopy blob
  , url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , expireDate date := null
)
return integer;
/* pfunc: SetProcessError
  Устанавливает ошибку обработки сообщения ( <body::SetProcessError>).
*/
procedure SetProcessError(
  messageId integer
  , errorCode integer
  , errorMessage varchar2
  , expireDate date := null
);
/* pfunc: SendMessage
  Создает сообщение для отправки ( <body::SendMessage>).
*/
function SendMessage(
  sender varchar2
  , recipient varchar2
  , copyRecipient varchar2 := null
  , subject varchar2
  , messageText clob
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob := null
  , smtpServer varchar2 := null
  , expireDate date := null
)
return integer;
/* pfunc: SendHTMLMessage
  Создает сообщение в виде HTML.
  Отправка сообщения будет выполнена после ( и в случае) фиксации транзакции.
  ( <body::SendHTMLMessage>).
*/
function SendHTMLMessage(
  sender varchar2
  , recipient varchar2
  , copyRecipient varchar2 := null
  , subject varchar2
  , htmlText clob
  , smtpServer varchar2 := null
  , expireDate date := null
)
return integer;
/* pfunc: SendReplyMessage
  Создает ответное сообщение для отправки ( <body::SendReplyMessage>).
*/
function SendReplyMessage(
  sourceMessageId integer
  , sender varchar2 := null
  , recipient varchar2 := null
  , copyRecipient varchar2 := null
  , subject varchar2 := null
  , messageText clob
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob := null
  , smtpServer varchar2 := null
  , expireDate date := null
)
return integer;
/* pfunc: AddAttachment
  Добавляет вложение к сообщению для отправки
  ( <body::AddAttachment>).
*/
function AddAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob
)
return integer;
/* func: AddHTMLImageAttachment
  Добавляет изображение к HTML-сообщению для отправки.
 ( <body::AddHTMLImageAttachment>).
*/
function AddHTMLImageAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , contentType varchar2 := null
  , image blob
)
return integer;

/* pfunc: CancelSendMessage
  Отменяет отправку сообщения ( <body::CancelSendMessage>).
*/
procedure CancelSendMessage(
  messageId integer
  , expireDate date := null
);


end pkg_Mail;
/
