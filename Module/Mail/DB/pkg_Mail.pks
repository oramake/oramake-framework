create or replace package pkg_Mail is
/* package: pkg_Mail
  Интерфейсный пакет модуля Mail.
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет
*/
Module_Name constant varchar2(30) := 'Mail';



/* group: Коды состояния сообщения */

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



/* group: MIME-типы данных */

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



/* group: Функции */



/* group: Отправка писем */

/* pproc: sendMail
  Отправляет письмо ( немедленно).

  Параметры:
  sender                      - адрес отправителя
  recipient                   - адреса получателей
  copyRecipient               - адреса получателей копии
  subject                     - тема письма
  messageText                 - текст письма
  attachmentFileName          - имя файла вложения
  attachmentType              - тип вложения
  attachmentData              - данные вложения
  smtpServer                  - имя ( или ip-адрес) SMTP-сервера ( по умолчанию
                                используется сервер из pkg_Common.getSmtpServer)
  isHtml                      - отправлять ли письмо как HTML;
                                по-умолчанию письмо отправляется как обычный текст

  ( <body::sendMail>)
*/
procedure sendMail(
  sender varchar2
  , recipient varchar2
  , copyRecipient varchar2 := null
  , subject varchar2
  , messageText clob
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob := null
  , smtpServer varchar2 := null
  , isHtml boolean := null
);

/* pfunc: sendMessage
  Создает сообщение для отправки и возвращает его Id.
  Отправка сообщения будет выполнена после ( и в случае) фиксации транзакции.

  Параметры:
  sender                      - адрес отправителя
  recipient                   - адреса получателей
  copyRecipient               - адреса получателей копии
  subject                     - тема письма
  messageText                 - текст письма
  attachmentFileName          - имя файла вложения
  attachmentType              - тип вложения
  attachmentData              - данные вложения
  expireDate                  - дата истечения срока жизни сообщения

  Возврат:
  Id сообщения.

  ( <body::sendMessage>)
*/
function sendMessage(
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

/* pfunc: sendHtmlMessage
  Создает сообщение как HTML.
  Отправка сообщения будет выполнена после ( и в случае) фиксации транзакции.

  Параметры:
  sender                      - адрес отправителя
  recipient                   - адреса получателей
  copyRecipient               - адреса получателей копии
  subject                     - тема письма
  htmlText                    - html-текст письма
  attachmentFileName          - имя файла вложения
  attachmentType              - тип вложения
  attachmentData              - данные вложения
  expireDate                  - дата истечения срока жизни сообщения

  Возврат:
  Id сообщения.

  ( <body::sendHtmlMessage>)
*/
function sendHtmlMessage(
  sender varchar2
  , recipient varchar2
  , copyRecipient varchar2 := null
  , subject varchar2
  , htmlText clob
  , smtpServer varchar2 := null
  , expireDate date := null
)
return integer;

/* pfunc: sendReplyMessage
  Создает ответное сообщение для отправки и возвращает его Id.
  Отправка сообщения будет выполнена после ( и в случае) фиксации транзакции.

  Параметры:
  sourceMessageId             - Id сообщения, на которое посылается ответ
  sender                      - адрес отправителя
  recipient                   - адреса получателей
  copyRecipient               - адреса получателей копии
  subject                     - тема письма
  messageText                 - текст письма
  attachmentFileName          - имя файла вложения
  attachmentType              - тип вложения
  attachmentData              - данные вложения
  expireDate                  - дата истечения срока жизни сообщения

  Возврат:
  Id сообщения.

  Замечание:
  в случае отсутствия значений у параметров sender, recipient, copyRecipient и
  subject будут использоваться данные исходного письма в предположении, что
  формируемое письмо является ответом на него.

  ( <body::sendReplyMessage>)
*/
function sendReplyMessage(
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

/* pfunc: addAttachment
  Добавляет вложение к сообщению для отправки.
  При добавлении сообщение блокируется и проверяется, что оно находится в
  состоянии <WaitSend_MessageStateCode>, иначе выбрасывается исключение.

  Параметры:
  messageId                   - Id сообщения, к которому добавляется вложение
  attachmentFileName          - имя файла вложения ( если null, то используется
                                значение из <Attachment_DefaultFileName>)
  attachmentType              - тип вложения ( если null, то используется
                                значение из <Attachment_DefaultType>)
  attachmentData              - данные вложения

  Возврат:
  Id добавленного вложения

  ( <body::addAttachment>)
*/
function addAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob
)
return integer;

/* pfunc: addHtmlImageAttachment
  Добавляет изображение к HTML-сообщению для отправки.
  При добавлении сообщение блокируется и проверяется, что оно находится в
  состоянии <WaitSend_MessageStateCode> и то, что это HTML-сообщение,
  иначе выбрасывается исключение.

  Параметры:
  messageId                   - Id сообщения, к которому добавляется вложение
  attachmentFileName          - имя файла вложения ( если null, то используется
                                значение из <Attachment_DefaultFileName>)
  contentType                 - тип вложения ( если null, то используется
                                значение из <AttachmentImage_DefaultType>
                                плюс символ ";" плюс name="<attachmentFileName>" )
  image                         - данные изображения

  Возврат:
  Id добавленного вложения

  ( <body::addHtmlImageAttachment>)
*/
function addHtmlImageAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , contentType varchar2 := null
  , image blob
)
return integer;

/* pproc: cancelSendMessage
  Отменяет отправку сообщения.
  Состояние сообщения при этом изменяется с <WaitSend_MessageStateCode> на
  <SendCanceled_MessageStateCode>.

  Параметры:
  messageId                   - Id сообщения
  expireDate                  - дата истечения срока жизни ( если null, то
                                не изменяется)

  Замечания:
  - в случае отсутствия сообщения в состоянии <WaitSend_MessageStateCode>
    выбрасывается исключение;

  ( <body::cancelSendMessage>)
*/
procedure cancelSendMessage(
  messageId integer
  , expireDate date := null
);



/* group: Получение и обработка писем */

/* pfunc: fetchMessage
  Получает почту и возвращает число полученных сообщений.

  Параметры:
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  password                    - пароль для подключения к почтовому ящику
                                ( если null, то используется пароль из url)
  recipientAddress            - адрес получателя, под которым будут сохраняться
                                полученные сообщения ( при отсутствии выделяется
                                из URL как user@domen)
  isGotMessageDeleted         - удалять ли из ящика полученные сообщения
                                ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  число полученных сообщений

  Замечания:
  - функция выполняется в автономной транзакции;

  ( <body::fetchMessage>)
*/
function fetchMessage(
  url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , isGotMessageDeleted integer := null
)
return integer;

/* pfunc: getMessage
  Ищет незаблокированное сообщение в статусе "Получено" и, если оно найдено,
  блокирует его, переводит в статус "Обработано" и возвращает Id сообщения для
  выполнения обработки.
  В случае, если в БД нет сообщений для обработки и был передан URL почтового
  ящика, будет выполнено получение писем из почтового ящика ( с помощью вызова
  <fetchMessage>).

  Параметры:
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  password                    - пароль для подключения к почтовому ящику
                                ( если null, то используется пароль из url)
  recipientAddress            - адрес получателя, по которому выбираются
                                полученные сообщения ( при отсутствии выделяется
                                из URL как user@domen)
  isGotMessageDeleted         - удалять ли из ящика полученные сообщения
                                ( 1 да ( по умолчанию), 0 нет)
  expireDate                  - дата истечения срока жизни, которая
                                устанавливается при изменении статуса сообщения
                                ( если null, то не изменяется)

  Возврат:
  Id сообщения для выполнения обработки ( null при отсутствии сообщений).

  ( <body::getMessage>)
*/
function getMessage(
  url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , isGotMessageDeleted integer := null
  , expireDate date := null
)
return integer;

/* pfunc: getMessage( out senderAddress)
  Ищет незаблокированное сообщение в статусе "Получено" и, если оно найдено,
  блокирует его, переводит в статус "Обработано" и возвращает Id сообщения
  и почтовый адрес отправителя для выполнения обработки.
  В случае, если в БД нет сообщений для обработки и был передан URL почтового
  ящика, будет выполнено получение писем из почтового ящика ( с помощью вызова
  <fetchMessage>).

  Параметры:
  senderAddress               - адрес отправителя
                                ( возврат)
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  password                    - пароль для подключения к почтовому ящику
                                ( если null, то используется пароль из url)
  recipientAddress            - адрес получателя, по которому выбираются
                                полученные сообщения ( при отсутствии выделяется
                                из URL как user@domen)
  isGotMessageDeleted         - удалять ли из ящика полученные сообщения
                                ( 1 да ( по умолчанию), 0 нет)
  expireDate                  - дата истечения срока жизни, которая
                                устанавливается при изменении статуса сообщения
                                ( если null, то не изменяется)

  Возврат:
  Id сообщения для выполнения обработки ( null при отсутствии сообщений).

  ( <body::getMessage( out senderAddress)>)
*/
function getMessage(
  senderAddress out nocopy varchar2
  , url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , isGotMessageDeleted integer := null
  , expireDate date := null
)
return integer;

/* pfunc: getMessage( out DATA)
  Ищет незаблокированное сообщение в статусе "Получено" и, если оно найдено,
  блокирует его, переводит в статус "Обработано" и возвращает Id и данные
  сообщение для выполнения обработки.
  В случае, если в БД нет сообщений для обработки и был передан URL почтового
  ящика, будет выполнено получение писем из почтового ящика ( с помощью вызова
  <fetchMessage>).

  Параметры:
  senderAddress               - адрес отправителя
                                ( возврат)
  sendDate                    - дата отправки
                                ( возврат)
  subject                     - тема сообщения
                                ( возврат)
  messageText                 - текст сообщнеия
                                ( возврат)
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  password                    - пароль для подключения к почтовому ящику
                                ( если null, то используется пароль из url)
  recipientAddress            - адрес получателя, по которому выбираются
                                полученные сообщения ( при отсутствии выделяется
                                из URL как user@domen)
  isGotMessageDeleted         - удалять ли из ящика полученные сообщения
                                ( 1 да ( по умолчанию), 0 нет)
  expireDate                  - дата истечения срока жизни, которая
                                устанавливается при изменении статуса сообщения
                                ( если null, то не изменяется)

  ( <body::getMessage( out DATA)>)
*/
function getMessage(
  senderAddress out nocopy varchar2
  , sendDate out nocopy timestamp with time zone
  , subject out nocopy varchar2
  , messageText out nocopy clob
  , url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , isGotMessageDeleted integer := null
  , expireDate date := null
)
return integer;

/* pfunc: getMessage( out DATA, out ATTACHMENT)
  Ищет незаблокированное сообщение в статусе "Получено" и, если оно найдено,
  блокирует его, переводит в статус "Обработано" и возвращает Id и данные
  сообщение для выполнения обработки.
  Если сообщение имеет вложение, то также возвращаются данные вложения (
  если более одного вложения - выбрасывается исключение).
  В случае, если в БД нет сообщений для обработки и был передан URL почтового
  ящика, будет выполнено получение писем из почтового ящика ( с помощью вызова
  <fetchMessage>).

  Параметры:
  senderAddress               - адрес отправителя
                                ( возврат)
  sendDate                    - дата отправки
                                ( возврат)
  subject                     - тема сообщения
                                ( возврат)
  messageText                 - текст сообщнеия
                                ( возврат)
  attachmentFileName          - имя файла вложения
                                ( возврат)
  attachmentType              - тип вложения
                                ( возврат)
  attachmentData              - данные вложения
                                ( возврат)
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  password                    - пароль для подключения к почтовому ящику
                                ( если null, то используется пароль из url)
  recipientAddress            - адрес получателя, по которому выбираются
                                полученные сообщения ( при отсутствии выделяется
                                из URL как user@domen)
  isGotMessageDeleted         - удалять ли из ящика полученные сообщения
                                ( 1 да ( по умолчанию), 0 нет)
  expireDate                  - дата истечения срока жизни, которая
                                устанавливается при изменении статуса сообщения
                                ( если null, то не изменяется)

  Возврат:
  Id сообщения для выполнения обработки ( null при отсутствии сообщений).

  ( <body::getMessage( out DATA, out ATTACHMENT)>)
*/
function getMessage(
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
  , isGotMessageDeleted integer := null
  , expireDate date := null
)
return integer;

/* pproc: setProcessError
  Устанавливает ошибку обработки сообщения.

  Параметры:
  messageId                   - Id сообщения
  errorCode                   - код ошибки
  errorMessage                - сообщение об ошибке
  expireDate                  - дата истечения срока жизни
                                ( если null, то не изменяется)
  mailboxForDeleteFlag        - Флаг необходимости удаления сообщения из
                                почтового ящика в случае его наличия
                                ( 1 удалить, 0 не удалять)
                                ( если null, то не изменяется)

  ( <body::setProcessError>)
*/
procedure setProcessError(
  messageId integer
  , errorCode integer
  , errorMessage varchar2
  , expireDate date := null
  , mailboxForDeleteFlag number := null
);

/* pproc: deleteMailboxMessage
  Устанавливает флаг удаления сообщения из почтового ящике. Фактически
  удаление будет выполненено при очередном получении сообщений из почтового
  ящика в случае наличия в нем данного сообщения.

  Параметры:
  messageId                   - Id сообщения

  ( <body::deleteMailboxMessage>)
*/
procedure deleteMailboxMessage(
  messageId integer
);

end pkg_Mail;
/
