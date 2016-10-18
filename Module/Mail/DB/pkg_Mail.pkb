create or replace package body pkg_Mail is
/* package body: pkg_Mail::body */



/* group: Константы */

/* iconst: Attachment_DefaultFileName
  Имя файла вложения по умолчанию.
*/
Attachment_DefaultFileName constant varchar2(30) := 'filename.dat';

/* iconst: Attachment_DefaultType
  Тип файла вложения по умолчанию.
*/
Attachment_DefaultType constant varchar2(50) := BinaryData_MimeType;

/* iconst: AttachmentImage_DefaultType
  Тип изображения по умолчанию
*/
AttachmentImage_DefaultType constant varchar2(50) := ImageJPEGData_MimeType;




/* group: Переменные */

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName => Module_Name
  , objectName => 'pkg_Mail'
);



/* group: Функции */



/* group: Отправка писем */

/* ifunc: sendMailJava
  Отправляет письмо ( немедленно).
*/
procedure sendMailJava(
  sender varchar2
  , recipient varchar2
  , copyRecipient varchar2
  , subject varchar2
  , messageText clob
  , attachmentFileName varchar2
  , attachmentType varchar2
  , attachmentData blob
  , smtpServer varchar2
  , isHtml number
)
is
language java name '
Mail.send(
  java.lang.String
  , java.lang.String
  , java.lang.String
  , java.lang.String
  , oracle.sql.CLOB
  , java.lang.String
  , java.lang.String
  , oracle.sql.BLOB
  , java.lang.String
  , oracle.sql.NUMBER
)
';

/* proc: sendMail
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
)
is
begin
  sendMailJava(
    sender                => pkg_MailUtility.getEncodedAddressList( sender)
    , recipient           => pkg_MailUtility.getEncodedAddressList( recipient)
    , copyRecipient       => pkg_MailUtility.getEncodedAddressList(
                              copyRecipient
                            )
    , subject             => subject
    , messageText         => messageText
    , attachmentFileName  =>
        case when attachmentData is not null then
          coalesce( attachmentFileName, Attachment_DefaultFileName)
        end
    , attachmentType      =>
        case when attachmentData is not null then
          coalesce( attachmentType, Attachment_DefaultType)
        end
    , attachmentData      => attachmentData
    , smtpServer          => case when smtpServer is not null then
                               smtpServer
                             else
                               pkg_Common.getSmtpServer()
                             end
    , isHtml =>
        case when isHtml
           then 1
           else 0
        end
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при отправке письма ('
        || ' sender="' || sender || '"'
        || ', recipient="' || recipient || '"'
        || ', subject="' || subject || '"'
        || case when smtpServer is not null then
            ', smtpServer="' || smtpServer || '"'
          end
        || ').'
      )
    , true
  );
end sendMail;

/* ifunc: createAttachment
  Создает вложение.

  Параметры:
  messageId                   - Id сообщения, к которому добавляется вложение
  attachmentFileName          - имя файла вложения ( если null, то используется
                                значение из <Attachment_DefaultFileName>)
  attachmentType               - тип вложения ( если null, то используется
                                значение из <Attachment_DefaultType>)
  attachmentData              - данные вложения
  isImageContentId            - поле заголовока Content-ID имеет значение <image>,
                                disposition не присваивается тип вложения

  Возврат:
  Id созданного вложения
*/
function createAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob
  , isImageContentId integer := null
)
return integer
is

  -- Id вложения
  attachmentId ml_attachment.attachment_id%type;

begin
  insert into
    ml_attachment
  (
    message_id
    , file_name
    , content_type
    , attachment_data
    , is_image_content_id
  )
  values
  (
    messageId
    , coalesce( attachmentFileName, Attachment_DefaultFileName)
    , coalesce( attachmentType, Attachment_DefaultType)
    , attachmentData
    , isImageContentId
  )
  returning attachment_id into attachmentId;
  return attachmentId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании вложения.'
      )
    , true
  );
end createAttachment;

/* ifunc: sendMessage( INTERNAL)
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
  sourceMessageId             - Id сообщения, на которое посылается ответ
  expireDate                  - дата истечения срока жизни сообщения
  isHtml                      - создавать сообщение как HTML
                                ( 1 да, 0 нет ( по-умолчанию))
*/
function sendMessage(
  sender varchar2 := null
  , recipient varchar2 := null
  , copyRecipient varchar2 := null
  , subject varchar2 := null
  , messageText clob
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob := null
  , sourceMessageId integer
  , smtpServer varchar2 := null
  , expireDate date := null
  , isHtml integer := null
)
return integer
is

  -- Id созданного сообщения
  messageId ml_message.message_id%type;

  -- Id вложения
  attachmentId ml_attachment.attachment_id%type;



  /*
    Добавляет запись в таблицу сообщений.
  */
  procedure addMessage
  is

    msg ml_message%rowtype;

  begin
    msg.incoming_flag       := 0;
    msg.sender_text         := sender;
    msg.sender              := pkg_MailUtility.getEncodedAddressList( sender);
    msg.sender_address      := pkg_MailUtility.getAddress( msg.sender);
    msg.recipient_text      := recipient;
    msg.recipient           := pkg_MailUtility.getEncodedAddressList(
                                recipient
                              );
    msg.recipient_address   := pkg_MailUtility.getAddress( msg.recipient);
    msg.copy_recipient_text := copyRecipient;
    msg.copy_recipient      := pkg_MailUtility.getEncodedAddressList(
                                copyRecipient
                              );
    msg.message_state_code  := WaitSend_MessageStateCode;
    msg.send_date           := systimestamp;
    msg.subject             := subject;
    msg.message_text        := messageText;
    msg.source_message_id   := sourceMessageId;
    msg.smtp_server         := smtpServer;
    msg.expire_date         := expireDate;
    msg.is_html             := isHtml;
    insert into
      ml_message
    values
      msg
    returning message_id into messageId;
  end addMessage;



-- sendMessage
begin

  -- Добавляем сообщение
  addMessage();

  -- Добавляем вложение
  if attachmentData is not null then
    attachmentId := createAttachment(
      messageId             => messageId
      , attachmentFileName  => attachmentFileName
      , attachmentType      => attachmentType
      , attachmentData      => attachmentData
    );
    if attachmentId is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Вложение не создано.'
      );
    end if;
  elsif attachmentFileName is not null or attachmentType is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Отсутствуют данные вложения.'
    );
  end if;
  return messageId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании сообщения для отправки ('
        || ' sender="' || sender || '"'
        || ', recipient="' || recipient || '"'
        || ', subject="' || subject || '"'
        || case when sourceMessageId is not null then
            ', sourceMessageId=' || to_char( sourceMessageId)
          end
        || ').'
      )
    , true
  );
end sendMessage;

/* func: sendMessage
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
return integer
is
begin
  return
    sendMessage(
      sender                  => sender
      , recipient             => recipient
      , copyRecipient         => copyRecipient
      , subject               => subject
      , messageText           => messageText
      , attachmentFileName    => attachmentFileName
      , attachmentType        => attachmentType
      , attachmentData        => attachmentData
      , sourceMessageId       => null
      , smtpServer            => smtpServer
      , expireDate            => expireDate
    )
  ;
end sendMessage;

/* func: sendHtmlMessage
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
return integer
is
begin
  return
    sendMessage(
      sender                  => sender
      , recipient             => recipient
      , copyRecipient         => copyRecipient
      , subject               => subject
      , messageText           => htmlText
      , attachmentFileName    => null
      , attachmentType        => null
      , attachmentData        => null
      , sourceMessageId       => null
      , smtpServer            => smtpServer
      , expireDate            => expireDate
      , isHtml                => 1
    )
  ;
end sendHtmlMessage;

/* func: sendReplyMessage
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
return integer
is

  -- Данные исходного сообщения
  sourceSender ml_message.sender%type;
  sourceRecipientAddress ml_message.recipient_address%type;
  sourceCopyRecipient ml_message.copy_recipient%type;
  sourceSubject ml_message.subject%type;



  /*
    Получает параметры исходного сообщения.
  */
  procedure getSourceMessageParam
  is

  begin
    select
      ms.sender
      , ms.recipient_address
      , ms.copy_recipient
      , ms.subject
    into sourceSender, sourceRecipientAddress, sourceCopyRecipient
      , sourceSubject
    from
      ml_message ms
    where
      ms.message_id = sourceMessageId
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
        'Ошибка при получении параметров исходного сообщения ('
        || ' message_id=' || to_char( sourceMessageId)
        || ').' )
      , true
    );
  end getSourceMessageParam;



-- sendReplyMessage
begin
  if sourceMessageId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не задан Id исходного сообщения.'
    );
  end if;

  -- Получаем параметры исходного сообщения
  if sender is null or recipient is null or copyRecipient is null
      or subject is null
      then
    getSourceMessageParam();
  end if;
  return
    sendMessage(
      sender                  => coalesce( sender, sourceRecipientAddress)
      , recipient             => coalesce( recipient, sourceSender)
      , copyRecipient         => coalesce( copyRecipient, sourceCopyRecipient)
      , subject               =>
          coalesce( subject,
            case when sourceSubject is not null then
              'RE: ' || sourceSubject
            else
              '(no subject)'
            end
          )
      , messageText           => messageText
      , attachmentFileName    => attachmentFileName
      , attachmentType        => attachmentType
      , attachmentData        => attachmentData
      , sourceMessageId       => sourceMessageId
      , smtpServer            => smtpServer
      , expireDate            => expireDate
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании ответного сообщения для отправки ('
        || ' source_message_id=' || to_char( sourceMessageId)
        || ').'
      )
    , true
  );
end sendReplyMessage;

/* iproc: checkAddAttachment
  Проверка возмоности добавления вложения к сообщению.

  Параметры:
  messageId                   - Id сообщения, к которому добавляется вложение
*/
procedure checkAddAttachment(
  messageId integer
)
is

  -- Текущее состояние сообщения
  messageStateCode ml_message.message_state_code%type;

begin
  select
    ms.message_state_code
  into
    messageStateCode
  from
    ml_message ms
  where
    ms.message_id = messageId
  for update nowait
  ;

  if messageStateCode <> WaitSend_MessageStateCode then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Сообщение не находится в состоянии ожидания отправки.'
    );
  end if;
end checkAddAttachment;

/* func: addAttachment
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
*/
function addAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob
)
return integer
is

  -- Id вложения
  attachmentId ml_attachment.attachment_id%type;

begin
  checkAddAttachment( messageId);
  attachmentId := createAttachment(
    messageId             => messageId
    , attachmentFileName  => attachmentFileName
    , attachmentType      => attachmentType
    , attachmentData      => attachmentData
  );
  return attachmentId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при добавлении вложения для сообщения ('
        || ' messageId=' || to_char( messageId)
        || ', attachmentFileName="' || attachmentFileName || '"'
        || ').'
      )
    , true
  );
end addAttachment;

/* func: addHtmlImageAttachment
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
*/
function addHtmlImageAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , contentType varchar2 := null
  , image blob
)
return integer
is

  -- Id вложения
  attachmentId ml_attachment.attachment_id%type;

  -- Признак HTML-сообщения
  isHtml integer;

begin
  checkAddAttachment( messageId);
  if coalesce( isHtml, 0 ) <> 1 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Сообщение не является HTML-сообщением.'
    );
  end if;
  attachmentId := createAttachment(
    messageId             => messageId
    , attachmentFileName  => attachmentFileName
    , attachmentType      =>
       coalesce(
         contentType
         , AttachmentImage_DefaultType
           || '; name="' || attachmentFileName || '"'
       )
    , attachmentData      => image
    , isImageContentId => 1
  );
  return attachmentId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при добавлении изображения для HTML-сообщения ('
        || ' messageId=' || to_char( messageId)
        || ', attachmentFileName="' || attachmentFileName || '"'
        || ').'
      )
    , true
  );
end addHtmlImageAttachment;

/* proc: cancelSendMessage
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
*/
procedure cancelSendMessage(
  messageId integer
  , expireDate date := null
)
is
begin
  update
    ml_message ms
  set
    ms.message_state_code = SendCanceled_MessageStateCode
    , ms.expire_date = coalesce( expireDate, ms.expire_date)
  where
    ms.message_id = messageId
    and ms.message_state_code = WaitSend_MessageStateCode
  ;
  if SQL%ROWCOUNT = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Отсутствует ожидающее отправки сообщение.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при отмене отправки сообщения ('
        || ' messageId=' || to_char( messageId)
        || ', expireDate=' || to_char( expireDate, 'dd.mm.yyyy hh24:mi:ss')
        || ').'
      )
    , true
  );
end cancelSendMessage;



/* group: Получение и обработка писем */

/* func: fetchMessage
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
*/
function fetchMessage(
  url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , isGotMessageDeleted integer := null
)
return integer
is

  -- Автономная транзакция в связи с c необходимостью фиксировать изменения
  pragma autonomous_transaction;

  -- Число полученных сообщений
  nFetched integer;

  -- Id запроса на извлечение из ящика
  fetchRequestId ml_fetch_request.fetch_request_id%type;

begin
  insert into ml_fetch_request(
    url
    , password
    , recipient_address
    , is_got_message_deleted
    , batch_short_name
    , request_time
  )
  values(
    fetchMessage.url
    , fetchMessage.password
    , recipientAddress
    , coalesce( isGotMessageDeleted, 1)
    , pkg_MailInternal.getBatchShortName()
    , systimestamp
  )
  returning
    fetch_request_id
  into
    fetchRequestId
  ;
  commit;

  -- Ожидаем обработки запроса
  pkg_MailInternal.waitForFetchRequest(
    fetchRequestId => fetchRequestId
  );

  select
    result_message_count
  into
    nFetched
  from
    ml_fetch_request r
  where
    r.fetch_request_id = fetchRequestId;
  commit;
  return nFetched;
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении почты'
      )
    , true
  );
end fetchMessage;

/* ifunc: getMessage( INTERNAL)
  Ищет незаблокированное сообщение в статусе "Получено" и, если оно найдено,
  блокирует его, переводит в статус "Обработано" и возвращает Id сообщения для
  выполнения обработки.
  В случае, если в БД нет сообщений для обработки и был передан URL почтового
  ящика, будет выполнено получение писем из почтового ящика ( с помощью вызова
  fetchMessage).

  Параметры:
  senderAddress               - адрес отправителя ( возврат)
  sendDate                    - дата отправки ( возврат)
  subject                     - тема сообщения ( возврат)
  messageText                 - текст сообщнеия ( возврат)
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
  isGetMessageData            - определяет необходимость возврата данных
                                сообщения

  Возврат:
  Id сообщения для выполнения обработки ( null при отсутствии сообщений).
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
  , isGetMessageData boolean := true
)
return integer
is

  -- Адресат требуемых сообщений
  usedRecipientAddress ml_message.recipient_address%type;

  -- Id найденного сообщения
  messageId ml_message.message_id%type;

  -- Возможность получения сообщений из почтового ящика
  isAllowFetch boolean := url is not null;



  /*
    Пытается заблокировать сообщение для обработки.
  */
  procedure lockMessage(
    checkMessageId integer
  )
  is
  begin
    select
      ms.message_id
    into messageId
    from
      ml_message ms
    where
      ms.message_id = checkMessageId
      and ms.message_state_code = Received_MessageStateCode
    for update nowait;
  exception
    when NO_DATA_FOUND then
      null;
    when others then
      -- Игнорируем ошибку из-за блокировки
      if SQLCODE <> pkg_Error.ResourceBusyNowait then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , 'Ошибка при попытке блокировки сообщения ('
            || ' message_id=' || to_char( checkMessageId)
            || ').'
          , true
        );
      end if;
  end lockMessage;



  /*
    Устанавливает состояние обработки и, при необходимости, получает данные
    сообщения.
  */
  procedure setProcessedState
  is
  begin
    if not isGetMessageData then

      --Устанавливаем состояние обработки
      update
        ml_message ms
      set
        ms.message_state_code = Processed_MessageStateCode
        , ms.process_date = sysdate
        , ms.expire_date = coalesce( expireDate, ms.expire_date)
      where
        ms.message_id = messageId
      ;
    else

      --Устанавливаем состояние обработки и получаем данные сообщения
      update
        ml_message ms
      set
        ms.message_state_code = Processed_MessageStateCode
        , ms.process_date = sysdate
        , ms.expire_date = coalesce( expireDate, ms.expire_date)
      where
        ms.message_id = messageId
      returning
        ms.sender_address, ms.send_date, ms.subject, ms.message_text
      into
        senderAddress, sendDate, subject, messageText
      ;
    end if;
  end setProcessedState;



  /*
    Ищет незаблокированное сообщение для обработки.
  */
  procedure findMessage
  is

    cursor curMessage is
      select /*+ first_rows */
        ms.message_id
      from
        ml_message ms
      where
        ms.recipient_address = usedRecipientAddress
        and ms.message_state_code = Received_MessageStateCode
      order by
        ms.recipient_address
        , ms.message_state_code
        , ms.message_id
    ;

  begin
    for rec in curMessage loop
      lockMessage( rec.message_id);
      if messageId is not null then
        setProcessedState();
        exit;
      end if;
    end loop;
  end findMessage;



-- getMessage
begin

  -- Определяем адресата сообщения
  usedRecipientAddress :=
    case when recipientAddress is not null then
      recipientAddress
    else
      pkg_MailUtility.getMailboxAddress( url)
    end
  ;

  -- Цикл получения сообщения
  loop
    findMessage();
    exit when
      messageId is not null
      or not isAllowFetch
      or fetchMessage(
          url                     => url
          , password              => password
          , recipientAddress      => usedRecipientAddress
          , isGotMessageDeleted   => isGotMessageDeleted
        )
      = 0
    ;

    -- Получаем почту не более одного раза
    isAllowFetch := false;
  end loop;
  return messageId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении сообщения для обработки'
        || case when usedRecipientAddress is not null then
            ' по адресату "' || usedRecipientAddress || '"'
          end
        || '.'
      )
    , true
  );
end getMessage;

/* func: getMessage
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
*/
function getMessage(
  url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , isGotMessageDeleted integer := null
  , expireDate date := null
)
return integer
is

  -- Данные сообщения ( не заполняются)
  senderAddress ml_message.sender_address%type;
  sendDate ml_message.send_date%type;
  subject ml_message.subject%type;
  messageText ml_message.message_text%type;

begin
  return
    getMessage(
      senderAddress           => senderAddress
      , sendDate              => sendDate
      , subject               => subject
      , messageText           => messageText
      , url                   => url
      , password              => password
      , recipientAddress      => recipientAddress
      , isGotMessageDeleted   => isGotMessageDeleted
      , expireDate            => expireDate
      , isGetMessageData      => false
    );
end getMessage;

/* func: getMessage( out senderAddress)
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
*/
function getMessage(
  senderAddress out nocopy varchar2
  , url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , isGotMessageDeleted integer := null
  , expireDate date := null
)
return integer
is

  -- Данные сообщения
  sendDate ml_message.send_date%type;
  subject ml_message.subject%type;
  messageText ml_message.message_text%type;

begin
  return
    getMessage(
      senderAddress           => senderAddress
      , sendDate              => sendDate
      , subject               => subject
      , messageText           => messageText
      , url                   => url
      , password              => password
      , recipientAddress      => recipientAddress
      , isGotMessageDeleted   => isGotMessageDeleted
      , expireDate            => expireDate
      , isGetMessageData      => true
    );
end getMessage;

/* func: getMessage( out DATA)
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
return integer
is
begin
  return
    getMessage(
      senderAddress           => senderAddress
      , sendDate              => sendDate
      , subject               => subject
      , messageText           => messageText
      , url                   => url
      , password              => password
      , recipientAddress      => recipientAddress
      , isGotMessageDeleted   => isGotMessageDeleted
      , expireDate            => expireDate
      , isGetMessageData      => true
    );
end getMessage;

/* func: getMessage( out DATA, out ATTACHMENT)
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
return integer
is

  -- Id сообщения
  messageId ml_message.message_id%type;



  /*
    Получает данные вложения ( если оно присутствует).
  */
  procedure getAttachment
  is
  begin
    select
      atc.file_name
      , atc.content_type
      , atc.attachment_data
    into
      attachmentFileName
      , attachmentType
      , attachmentData
    from
      ml_attachment atc
    where
      atc.message_id = messageId
    ;
  exception
    when NO_DATA_FOUND then
      -- Игнорируем отсутствие вложения
      null;
    when TOO_MANY_ROWS then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Сообщение имеет более одного вложения ('
          || ' message_id=' || to_char( messageId)
          || ').'
      );
    when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Ошибка при получении данных вложения для сообщения ('
          || ' message_id=' || to_char( messageId)
          || ').'
        , true
      );
  end getAttachment;



-- getMessage
begin
  savepoint pkg_Mail_GetMessageAttach;

  -- Получаем сообщение
  messageId :=
    getMessage(
      senderAddress           => senderAddress
      , sendDate              => sendDate
      , subject               => subject
      , messageText           => messageText
      , url                   => url
      , password              => password
      , recipientAddress      => recipientAddress
      , isGotMessageDeleted   => isGotMessageDeleted
      , expireDate            => expireDate
      , isGetMessageData      => true
    )
  ;

  -- Получаем вложение
  if messageId is not null then
    getAttachment();
  end if;
  return messageId;
exception when others then
  rollback to pkg_Mail_GetMessageAttach;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении сообщения с вложением для обработки.'
      )
    , true
  );
end getMessage;

/* proc: setProcessError
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
*/
procedure setProcessError(
  messageId integer
  , errorCode integer
  , errorMessage varchar2
  , expireDate date := null
  , mailboxForDeleteFlag number := null
)
is
begin
  update
    ml_message ms
  set
    ms.message_state_code = ProcessError_MessageStateCode
    , ms.error_code = errorCode
    , ms.error_message = errorMessage
    , ms.expire_date = coalesce( expireDate, ms.expire_date)
    , ms.mailbox_for_delete_flag
        = coalesce( mailboxForDeleteFlag, ms.mailbox_for_delete_flag)
  where
    ms.message_id = messageId
    and ms.message_state_code in
      (
        Received_MessageStateCode
        , Processed_MessageStateCode
        , ProcessError_MessageStateCode
      )
  ;
  if SQL%ROWCOUNT = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Отсутствует сообщение в допустимом состоянии.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при установке ошибки обработки сообщения ('
        || ' messageId=' || to_char( messageId)
        || ', errorCode=' || to_char( errorCode)
        || ', errorMessage="' || substr( errorMessage, 1, 400) || '"'
        || ').'
      )
    , true
  );
end setProcessError;

/* proc: deleteMailboxMessage
  Устанавливает флаг удаления сообщения из почтового ящике. Фактически
  удаление будет выполненено при очередном получении сообщений из почтового
  ящика в случае наличия в нем данного сообщения.

  Параметры:
  messageId                   - Id сообщения
*/
procedure deleteMailboxMessage(
  messageId integer
)
is
begin
  update
    ml_message ms
  set
    ms.mailbox_for_delete_flag = 1
  where
    ms.message_id = messageId
  ;
  if sql%rowcount = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Сообщение не найдено.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при установке флага удаления сообщения из почтового ящика ('
        || ' messageId=' || to_char( messageId)
        || ').'
      )
    , true
  );
end deleteMailboxMessage;

end pkg_Mail;
/
