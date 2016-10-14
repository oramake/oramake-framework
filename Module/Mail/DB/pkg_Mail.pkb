create or replace package body pkg_Mail is
/* package body: pkg_Mail::body */

/* itype: TUrlString
  Тип для строки с URL.
*/
subtype TUrlString is ml_fetch_request.url%type;

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

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => Module_Name
    , objectName => 'pkg_Mail'
  );

/* func: SendMailJava
  Отправляет письмо ( немедленно).
*/
procedure SendMailJava(
  sender varchar2
  , recipient varchar2
  , copyRecipient varchar2
  , subject varchar2
  , messageText clob
  , attachmentFileName varchar2
  , attachmentType varchar2
  , attachmentData blob
  , smtpServer varchar2
  , isHTML number
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
/* proc: SendMail
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
                                используется сервер из pkg_Common.GetSmtpServer)
  isHTML                      - отправлять ли письмо как HTML;
                                по-умолчанию письмо отправляется как обычный текст
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
)
is

--SendMail
begin
  SendMailJava(
    sender                => pkg_MailUtility.GetEncodedAddressList( sender)
    , recipient           => pkg_MailUtility.GetEncodedAddressList( recipient)
    , copyRecipient       => pkg_MailUtility.GetEncodedAddressList(
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
                               pkg_Common.GetSmtpServer
                             end
    , isHTML =>
        case when isHTML
           then 1
           else 0
        end
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка при отправке письма ('
      || ' sender="' || sender || '"'
      || ', recipient="' || recipient || '"'
      || ', subject="' || subject || '"'
      || case when smtpServer is not null then
          ', smtpServer="' || smtpServer || '"'
        end
      || ').' )
    , true
  );
end SendMail;
/* func: FetchMessageJava
  Получает почтовые сообщения.
*/
function FetchMessageJava
 (url varchar2
 , recipientAddress varchar2
 , isGotMessageDeleted number
 , fetchRequestId number
 , errorMessage in out varchar2
 )
 return number
 is
language java name '
Mail.fetchMessage(
  java.lang.String
  , java.lang.String
  , oracle.sql.NUMBER
  , java.math.BigDecimal
  , java.lang.String[]
)
return oracle.sql.NUMBER
';
/* func: FetchMessageImmediate(out error)
  Получает почту и возвращает число полученных сообщений
  ( в том же сеансе)

  Параметры:
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  password                    - пароль для подключения к почтовому ящику
                                ( если null, то используется пароль из url)
  recipientAddress            - адрес получателя, под которым будут сохраняться
                                полученные сообщения ( при отсутствии выделяется
                                из URL как user@domen)
  fetchRequestId              - id запроса извлечения из ящика
  isGotMessageDeleted         - удалять ли из ящика полученные сообщения
  errorMessage                - сообщение об ошибке получения сообщений
  errorCode                   - код сообщения об ошибке
*/
function FetchMessageImmediate
(
 url varchar2
 , password varchar2 := null
 , recipientAddress varchar2 := null
 , isGotMessageDeleted integer := null
 , fetchRequestId integer := null
 , errorMessage in out varchar2
 , errorCode in out integer
)
return integer
is

                                        --Автономная транзакция в связи с
                                        --обращением к внешнему сервису
  pragma autonomous_transaction;
                                        --Число полученных сообщений
  nFetched integer := null;
                                        --URL с удаленным паролем
  clearUrl TUrlString;

--FetchMessage

  procedure TryFetchMessage
  is
  -- TryFetchMessage
  begin
    nFetched := FetchMessageJava(
      url =>
      case when password is not null then
        pkg_MailUtility.ChangeUrlPassword( url, password)
      else
        url
      end
      , recipientAddress => recipientAddress
      , isGotMessageDeleted => isGotMessageDeleted
      , fetchRequestId => fetchRequestId
      , errorMessage => errorMessage
    );
    errorCode := null;
  exception when others then
    errorCode := sqlcode;
    errorMessage := logger.GetErrorStack();
  end TryFetchMessage;

begin
  clearUrl := pkg_MailUtility.ChangeUrlPassword( url, null);
  TryFetchMessage;
  if length( errorMessage) > 0 then
    errorMessage :=
      'Ошибка при получении почты'
      || case when clearUrl is not null then
          ' по URL "' || clearUrl || '"'
         end
      || ': ' || errorMessage;
  end if;
  return nFetched;
end FetchMessageImmediate;

/* func: FetchMessageImmediate
  Получает почту и возвращает число полученных сообщений
  ( в том же сеансе)

  Параметры:
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  password                    - пароль для подключения к почтовому ящику
                                ( если null, то используется пароль из url)
  recipientAddress            - адрес получателя, под которым будут сохраняться
                                полученные сообщения ( при отсутствии выделяется
                                из URL как user@domen)
*/
function FetchMessageImmediate
(
 url varchar2
 , password varchar2 := null
 , recipientAddress varchar2 := null
)
return integer
is
                                       -- Количество извлечённых сообщений
  nFetched integer;
                                       -- Данные об ошибке
  errorMessage varchar2( 4000);
  errorCode integer;
begin
  nFetched :=
    FetchMessageImmediate(
      url => url
      , password => password
      , recipientAddress => recipientAddress
      , errorMessage => errorMessage
      , errorCode => errorCode
    );
  if trim( errorMessage) is not null then
    raise_application_error(
      pkg_Error.ProcessError
      , errorMessage
    );
  end if;
  return nFetched;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка при извлечении сообщений')
    , true
  );
end FetchMessageImmediate;

/* func: FetchMessage
  Получает почту и возвращает число полученных сообщений.

  Параметры:
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  password                    - пароль для подключения к почтовому ящику
                                ( если null, то используется пароль из url)
  recipientAddress            - адрес получателя, под которым будут сохраняться
                                полученные сообщения ( при отсутствии выделяется
                                из URL как user@domen)
*/
function FetchMessage
 (url varchar2
 , password varchar2 := null
 , recipientAddress varchar2 := null
 )
 return integer
 is

                                        -- Автономная транзакция в связи с
                                        -- c необходимостью фиксировать
                                        -- изменения
  pragma autonomous_transaction;
                                        -- Число полученных сообщений
  nFetched integer;
                                        -- Id запроса на извлечение
                                        -- из ящика
  fetchRequestId ml_fetch_request.fetch_request_id%type;
--FetchMessage
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
    FetchMessage.url
    , FetchMessage.password
    , recipientAddress
    , pkg_MailInternal.GetIsGotMessageDeleted
    , pkg_MailInternal.GetBatchShortName
    , systimestamp
  )
  returning
    fetch_request_id
  into
    fetchRequestId;
  commit;
                                       -- Ожидаем обработки
                                       -- запроса
  pkg_MailInternal.WaitForFetchRequest(
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
    , logger.ErrorStack( 'Ошибка при получении почты')
    , true
  );
end FetchMessage;
/* func: GetMessage( INTERNAL)
  Ищет незаблокированное сообщение в статусе "Получено" и, если оно найдено,
  блокирует его, переводит в статус "Обработано" и возвращает Id сообщения для
  выполнения обработки.
  В случае, если в БД нет сообщений для обработки и был передан URL почтового
  ящика, будет выполнено получение писем из почтового ящика ( с помощью вызова
  FetchMessage).

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
  expireDate                  - дата истечения срока жизни, которая
                                устанавливается при изменении статуса сообщения
                                ( если null, то не изменяется)
  isGetMessageData            - определяет необходимость возврата данных
                                сообщения
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
  , isGetMessageData boolean := true
)
return integer
is

                                        --Адресат требуемых сообщений
  usedRecipientAddress ml_message.recipient_address%type;
                                        --Id найденного сообщения
  messageId ml_message.message_id%type;
                                        --Возможность получения сообщений из
                                        --почтового ящика
  isAllowFetch boolean := url is not null;



  procedure LockMessage(
    checkMessageId integer
  )
  is
  --Пытается заблокировать сообщение для обработки.

  --LockMessage
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
    when others then                    --Игнорируем ошибку из-за блокировки
      if SQLCODE <> pkg_Error.ResourceBusyNowait then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , 'Ошибка при попытке блокировки сообщения ('
            || ' message_id=' || to_char( checkMessageId)
            || ').'
          , true
        );
      end if;
  end LockMessage;



  procedure SetProcessedState
  is
  --Устанавливает состояние обработки и, при необходимости, получает данные
  --сообщения.

  --SetProcessedState
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
                                        --Устанавливаем состояние обработки
                                        --и получаем данные сообщения
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
  end SetProcessedState;



  procedure FindMessage
  is
  --Ищет незаблокированное сообщение для обработки.

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

  --FindMessage
  begin
    for rec in curMessage loop
      LockMessage( rec.message_id);
      if messageId is not null then
        SetProcessedState;
        exit;
      end if;
    end loop;
  end FindMessage;



--GetMessage
begin
                                        --Определяем адресата сообщения
  usedRecipientAddress :=
    case when recipientAddress is not null then
      recipientAddress
    else
      pkg_MailUtility.GetMailboxAddress( url)
    end
  ;
                                        --Цикл получения сообщения
  loop
    FindMessage;
    exit when
      messageId is not null
      or not isAllowFetch
      or FetchMessage(
          url                 => url
          , password          => password
          , recipientAddress  => usedRecipientAddress
        )
      = 0
    ;
                                        --Получаем почту не более одного раза
    isAllowFetch := false;
  end loop;
  return messageId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка при получении сообщения для обработки'
      || case when usedRecipientAddress is not null then
          ' по адресату "' || usedRecipientAddress || '"'
        end
      || '.' )
    , true
  );
end GetMessage;
/* func: GetMessage
  Ищет незаблокированное сообщение в статусе "Получено" и, если оно найдено,
  блокирует его, переводит в статус "Обработано" и возвращает Id сообщения для
  выполнения обработки ( если ничего не найдено - возвращается null).
  В случае, если в БД нет сообщений для обработки и был передан URL почтового
  ящика, будет выполнено получение писем из почтового ящика ( с помощью вызова
  FetchMessage).

  Параметры:
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  password                    - пароль для подключения к почтовому ящику
                                ( если null, то используется пароль из url)
  recipientAddress            - адрес получателя, по которому выбираются
                                полученные сообщения ( при отсутствии выделяется
                                из URL как user@domen)
  expireDate                  - дата истечения срока жизни, которая
                                устанавливается при изменении статуса сообщения
                                ( если null, то не изменяется)
*/
function GetMessage(
  url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , expireDate date := null
)
return integer
is

                                        --Данные сообщения ( не заполняются)
  senderAddress ml_message.sender_address%type;
  sendDate ml_message.send_date%type;
  subject ml_message.subject%type;
  messageText ml_message.message_text%type;

--GetMessage
begin
  return
    GetMessage(
      senderAddress       => senderAddress
      , sendDate          => sendDate
      , subject           => subject
      , messageText       => messageText
      , url               => url
      , password          => password
      , recipientAddress  => recipientAddress
      , expireDate        => expireDate
      , isGetMessageData  => false
    );
end GetMessage;
/* func: GetMessage( out SenderAddress)
  Ищет незаблокированное сообщение в статусе "Получено" и, если оно найдено,
  блокирует его, переводит в статус "Обработано" и возвращает Id сообщения
  и почтовый адрес отправителя для выполнения обработки ( если ничего не
  найдено - возвращается null).
  В случае, если в БД нет сообщений для обработки и был передан URL почтового
  ящика, будет выполнено получение писем из почтового ящика ( с помощью вызова
  FetchMessage).

  Параметры:
  senderAddress               - адрес отправителя ( возврат)
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  password                    - пароль для подключения к почтовому ящику
                                ( если null, то используется пароль из url)
  recipientAddress            - адрес получателя, по которому выбираются
                                полученные сообщения ( при отсутствии выделяется
                                из URL как user@domen)
  expireDate                  - дата истечения срока жизни, которая
                                устанавливается при изменении статуса сообщения
                                ( если null, то не изменяется)
*/
function GetMessage(
  senderAddress out nocopy varchar2
  , url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , expireDate date := null
)
return integer
is

                                        --Данные сообщения
  sendDate ml_message.send_date%type;
  subject ml_message.subject%type;
  messageText ml_message.message_text%type;

--GetMessage
begin
  return
    GetMessage(
      senderAddress       => senderAddress
      , sendDate          => sendDate
      , subject           => subject
      , messageText       => messageText
      , url               => url
      , password          => password
      , recipientAddress  => recipientAddress
      , expireDate        => expireDate
      , isGetMessageData  => true
    );
end GetMessage;
/* func: GetMessage( out DATA)
  Ищет незаблокированное сообщение в статусе "Получено" и, если оно найдено,
  блокирует его, переводит в статус "Обработано" и возвращает Id и данные
  сообщение для выполнения обработки ( если ничего не найдено - возвращается
  null).
  В случае, если в БД нет сообщений для обработки и был передан URL почтового
  ящика, будет выполнено получение писем из почтового ящика ( с помощью вызова
  FetchMessage).

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
  expireDate                  - дата истечения срока жизни, которая
                                устанавливается при изменении статуса сообщения
                                ( если null, то не изменяется)
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
return integer
is

--GetMessage
begin
  return
    GetMessage(
      senderAddress       => senderAddress
      , sendDate          => sendDate
      , subject           => subject
      , messageText       => messageText
      , url               => url
      , password          => password
      , recipientAddress  => recipientAddress
      , expireDate        => expireDate
      , isGetMessageData  => true
    );
end GetMessage;
/* func: GetMessage( out DATA, out ATTACHMENT)
  Ищет незаблокированное сообщение в статусе "Получено" и, если оно найдено,
  блокирует его, переводит в статус "Обработано" и возвращает Id и данные
  сообщение для выполнения обработки ( если ничего не найдено - возвращается
  null).
  Если сообщение имеет вложение, то также возвращаются данные вложения (
  если более одного вложения - выбрасывается исключение).
  В случае, если в БД нет сообщений для обработки и был передан URL почтового
  ящика, будет выполнено получение писем из почтового ящика ( с помощью вызова
  FetchMessage).

  Параметры:
  senderAddress               - адрес отправителя ( возврат)
  sendDate                    - дата отправки ( возврат)
  subject                     - тема сообщения ( возврат)
  messageText                 - текст сообщнеия ( возврат)
  attachmentFileName          - имя файла вложения ( возврат)
  attachmentType              - тип вложения ( возврат)
  attachmentData              - данные вложения ( возврат)
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  password                    - пароль для подключения к почтовому ящику
                                ( если null, то используется пароль из url)
  recipientAddress            - адрес получателя, по которому выбираются
                                полученные сообщения ( при отсутствии выделяется
                                из URL как user@domen)
  expireDate                  - дата истечения срока жизни, которая
                                устанавливается при изменении статуса сообщения
                                ( если null, то не изменяется)
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
return integer
is

                                        --Id сообщения
  messageId ml_message.message_id%type;



  procedure GetAttachment
  is
  --Получает данные вложения ( если оно присутствует).

  --GetAttachment
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
    when NO_DATA_FOUND then             --Игнорируем отсутствие вложения
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
  end GetAttachment;



--GetMessage
begin
  savepoint pkg_Mail_GetMessageAttach;
                                        --Получаем сообщение
  messageId :=
    GetMessage(
      senderAddress       => senderAddress
      , sendDate          => sendDate
      , subject           => subject
      , messageText       => messageText
      , url               => url
      , password          => password
      , recipientAddress  => recipientAddress
      , expireDate        => expireDate
      , isGetMessageData  => true
    );
                                        --Получаем вложение
  if messageId is not null then
    GetAttachment();
  end if;
  return messageId;
exception when others then
  rollback to pkg_Mail_GetMessageAttach;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка при получении сообщения с вложением для обработки.'
      )
    , true
  );
end GetMessage;
/* proc: SetProcessError
  Устанавливает ошибку обработки сообщения.

  Параметры:
  messageId                   - Id сообщения
  errorCode                   - код ошибки
  errorMessage                - сообщение об ошибке
  expireDate                  - дата истечения срока жизни ( если null, то
                                не изменяется)
*/
procedure SetProcessError(
  messageId integer
  , errorCode integer
  , errorMessage varchar2
  , expireDate date := null
)
is

--SetProcessError
begin
  update
    ml_message ms
  set
    ms.message_state_code = ProcessError_MessageStateCode
    , ms.error_code = errorCode
    , ms.error_message = errorMessage
    , ms.expire_date = coalesce( expireDate, ms.expire_date)
  where
    ms.message_id = messageId
    and ms.message_state_code in
      (
        Received_MessageStateCode
        , Processed_MessageStateCode
        , ProcessError_MessageStateCode
        , WaitSend_MessageStateCode
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
    , logger.ErrorStack( 'Ошибка при установке ошибки обработки сообщения ('
      || ' message_id=' || to_char( messageId)
      || ', error_code=' || to_char( errorCode)
      || ', error_message="' || substr( errorMessage, 1, 400) || '"'
      || ').' )
    , true
  );
end SetProcessError;
/* func: CreateAttachment
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
function CreateAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob
  , isImageContentId integer := null
)
return integer
is

                                        --Id вложения
  attachmentId ml_attachment.attachment_id%type;

--CreateAttachment
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
    , logger.ErrorStack( 'Ошибка при создании вложения.' )
    , true
  );
end CreateAttachment;
/* func: SendMessage( INTERNAL)
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
  isHTML                      - создавать сообщение как HTML ( 1-да,0-нет )
                              по-умолчанию нет
*/
function SendMessage(
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
  , isHTML integer := null
)
return integer
is

                                        --Id созданного сообщения
  messageId ml_message.message_id%type;
                                        --Id вложения
  attachmentId ml_attachment.attachment_id%type;




  procedure AddMessage
  is
  --Добавляет запись в таблицу сообщений.

    msg ml_message%rowtype;

  --AddMessage
  begin
    msg.sender_text         := sender;
    msg.sender              := pkg_MailUtility.GetEncodedAddressList( sender);
    msg.sender_address      := pkg_MailUtility.GetAddress( msg.sender);
    msg.recipient_text      := recipient;
    msg.recipient           := pkg_MailUtility.GetEncodedAddressList(
                                recipient
                              );
    msg.recipient_address   := pkg_MailUtility.GetAddress( msg.recipient);
    msg.copy_recipient_text := copyRecipient;
    msg.copy_recipient      := pkg_MailUtility.GetEncodedAddressList(
                                copyRecipient
                              );
    msg.message_state_code  := WaitSend_MessageStateCode;
    msg.send_date           := systimestamp;
    msg.subject             := subject;
    msg.message_text        := messageText;
    msg.source_message_id   := sourceMessageId;
    msg.smtp_server         := smtpServer;
    msg.expire_date         := expireDate;
    msg.is_html             := isHTML;
    insert into
      ml_message
    values
      msg
    returning message_id into messageId;
  end AddMessage;


--SendMessage
begin
                                        --Добавляем сообщение
  AddMessage;
                                        --Добавляем вложение
  if attachmentData is not null then
    attachmentId := CreateAttachment(
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
    , logger.ErrorStack( 'Ошибка при создании сообщения для отправки ('
      || ' sender="' || sender || '"'
      || ', recipient="' || recipient || '"'
      || ', subject="' || subject || '"'
      || case when sourceMessageId is not null then
          ', sourceMessageId=' || to_char( sourceMessageId)
        end
      || ').' )
    , true
  );
end SendMessage;
/* func: SendMessage
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
return integer
is

--SendMessage
begin
                              --Вызов основной функции
  return
    SendMessage(
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
end SendMessage;

/* func: SendHTMLMessage
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
return integer
is

--SendMessage
begin
                              --Вызов основной функции
  return
    SendMessage(
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
      , isHTML                => 1
    )
  ;
end SendHTMLMessage;

/* func: SendReplyMessage
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

  Замечание:
  в случае отсутствия значений у параметров sender, recipient, copyRecipient и
  subject будут использоваться данные исходного письма в предположении, что
  формируемое письмо является ответом на него.
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
return integer
is

                                        --Данные исходного сообщения
  sourceSender ml_message.sender%type;
  sourceRecipientAddress ml_message.recipient_address%type;
  sourceCopyRecipient ml_message.copy_recipient%type;
  sourceSubject ml_message.subject%type;



  procedure GetSourceMessageParam
  is
  --Получает параметры исходного сообщения.

  --GetSourceMessageParam
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
      , logger.ErrorStack(
        'Ошибка при получении параметров исходного сообщения ('
        || ' message_id=' || to_char( sourceMessageId)
        || ').' )
      , true
    );
  end GetSourceMessageParam;



--SendReplyMessage
begin
  if sourceMessageId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не задан Id исходного сообщения.'
    );
  end if;
                                        --Получаем параметры исходного сообщения
  if sender is null or recipient is null or copyRecipient is null
      or subject is null
      then
    GetSourceMessageParam;
  end if;
  return
    SendMessage(
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
    , logger.ErrorStack(
      'Ошибка при создании ответного сообщения для отправки ('
      || ' source_message_id=' || to_char( sourceMessageId)
      || ').' )
    , true
  );
end SendReplyMessage;

/* proc: CheckAddAttachment
  Проверка возмоности добавления вложения к сообщению.

  Параметры:
  messageId                   - Id сообщения, к которому добавляется вложение
*/
procedure CheckAddAttachment(
  messageId integer
)
is

begin
  null;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка проверки возможности добавления вложения ('
      || ' messageId=' || to_char( messageId)
      || ').'
    , true
  );
end CheckAddAttachment;

/* func: AddAttachment
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
function AddAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob
)
return integer
is

                                        --Id вложения
  attachmentId ml_attachment.attachment_id%type;
                                        --Текущее состояние сообщения
  messageStateCode ml_message.message_state_code%type;
begin
                                        -- Проверка возможности добавления
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
  attachmentId := CreateAttachment(
    messageId             => messageId
    , attachmentFileName  => attachmentFileName
    , attachmentType      => attachmentType
    , attachmentData      => attachmentData
  );
  return attachmentId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка при добавлении вложения для сообщения ('
      || ' messageId=' || to_char( messageId)
      || ', attachmentFileName="' || attachmentFileName || '"'
      || ').' )
    , true
  );
end AddAttachment;
/* func: AddHTMLImageAttachment
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
function AddHTMLImageAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , contentType varchar2 := null
  , image blob
)
return integer
is

                                        -- Id вложения
  attachmentId ml_attachment.attachment_id%type;
                                        --Текущее состояние сообщения
  messageStateCode ml_message.message_state_code%type;
                                        -- Признак HTML-сообщения
  isHTML integer;
begin
                                        -- Проверка возможности добавления
  select
    ms.message_state_code
    , ms.is_html
  into
    messageStateCode
    , isHTML
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
  if coalesce( isHTML, 0 ) <> 1 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Сообщение не является HTML-сообщением.'
    );
  end if;
  attachmentId := CreateAttachment(
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
    , logger.ErrorStack(
      'Ошибка при добавлении изображения для HTML-сообщения ('
      || ' messageId=' || to_char( messageId)
      || ', attachmentFileName="' || attachmentFileName || '"'
      || ').' )
    , true
  );
end AddHTMLImageAttachment;
/* proc: CancelSendMessage
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
procedure CancelSendMessage(
  messageId integer
  , expireDate date := null
)
is

--CancelSendMessage
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
    , logger.ErrorStack( 'Ошибка при отмене отправки сообщения ('
      || ' messageId=' || to_char( messageId)
      || ', expireDate=' || to_char( expireDate, 'dd.mm.yyyy hh24:mi:ss')
      || ').' )
    , true
  );
end CancelSendMessage;


end pkg_Mail;
/
