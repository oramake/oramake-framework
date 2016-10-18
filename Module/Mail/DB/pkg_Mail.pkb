create or replace package body pkg_Mail is
/* package body: pkg_Mail::body */



/* group: ��������� */

/* iconst: Attachment_DefaultFileName
  ��� ����� �������� �� ���������.
*/
Attachment_DefaultFileName constant varchar2(30) := 'filename.dat';

/* iconst: Attachment_DefaultType
  ��� ����� �������� �� ���������.
*/
Attachment_DefaultType constant varchar2(50) := BinaryData_MimeType;

/* iconst: AttachmentImage_DefaultType
  ��� ����������� �� ���������
*/
AttachmentImage_DefaultType constant varchar2(50) := ImageJPEGData_MimeType;




/* group: ���������� */

/* ivar: logger
  ������������ ������ � ������ Logging
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName => Module_Name
  , objectName => 'pkg_Mail'
);



/* group: ������� */



/* group: �������� ����� */

/* ifunc: sendMailJava
  ���������� ������ ( ����������).
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
  ���������� ������ ( ����������).

  ���������:
  sender                      - ����� �����������
  recipient                   - ������ �����������
  copyRecipient               - ������ ����������� �����
  subject                     - ���� ������
  messageText                 - ����� ������
  attachmentFileName          - ��� ����� ��������
  attachmentType              - ��� ��������
  attachmentData              - ������ ��������
  smtpServer                  - ��� ( ��� ip-�����) SMTP-������� ( �� ���������
                                ������������ ������ �� pkg_Common.getSmtpServer)
  isHtml                      - ���������� �� ������ ��� HTML;
                                ��-��������� ������ ������������ ��� ������� �����
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
        '������ ��� �������� ������ ('
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
  ������� ��������.

  ���������:
  messageId                   - Id ���������, � �������� ����������� ��������
  attachmentFileName          - ��� ����� �������� ( ���� null, �� ������������
                                �������� �� <Attachment_DefaultFileName>)
  attachmentType               - ��� �������� ( ���� null, �� ������������
                                �������� �� <Attachment_DefaultType>)
  attachmentData              - ������ ��������
  isImageContentId            - ���� ���������� Content-ID ����� �������� <image>,
                                disposition �� ������������� ��� ��������

  �������:
  Id ���������� ��������
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

  -- Id ��������
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
        '������ ��� �������� ��������.'
      )
    , true
  );
end createAttachment;

/* ifunc: sendMessage( INTERNAL)
  ������� ��������� ��� �������� � ���������� ��� Id.
  �������� ��������� ����� ��������� ����� ( � � ������) �������� ����������.

  ���������:
  sender                      - ����� �����������
  recipient                   - ������ �����������
  copyRecipient               - ������ ����������� �����
  subject                     - ���� ������
  messageText                 - ����� ������
  attachmentFileName          - ��� ����� ��������
  attachmentType              - ��� ��������
  attachmentData              - ������ ��������
  sourceMessageId             - Id ���������, �� ������� ���������� �����
  expireDate                  - ���� ��������� ����� ����� ���������
  isHtml                      - ��������� ��������� ��� HTML
                                ( 1 ��, 0 ��� ( ��-���������))
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

  -- Id ���������� ���������
  messageId ml_message.message_id%type;

  -- Id ��������
  attachmentId ml_attachment.attachment_id%type;



  /*
    ��������� ������ � ������� ���������.
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

  -- ��������� ���������
  addMessage();

  -- ��������� ��������
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
        , '�������� �� �������.'
      );
    end if;
  elsif attachmentFileName is not null or attachmentType is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '����������� ������ ��������.'
    );
  end if;
  return messageId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ��������� ��� �������� ('
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
  ������� ��������� ��� �������� � ���������� ��� Id.
  �������� ��������� ����� ��������� ����� ( � � ������) �������� ����������.

  ���������:
  sender                      - ����� �����������
  recipient                   - ������ �����������
  copyRecipient               - ������ ����������� �����
  subject                     - ���� ������
  messageText                 - ����� ������
  attachmentFileName          - ��� ����� ��������
  attachmentType              - ��� ��������
  attachmentData              - ������ ��������
  expireDate                  - ���� ��������� ����� ����� ���������

  �������:
  Id ���������.
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
  ������� ��������� ��� HTML.
  �������� ��������� ����� ��������� ����� ( � � ������) �������� ����������.

  ���������:
  sender                      - ����� �����������
  recipient                   - ������ �����������
  copyRecipient               - ������ ����������� �����
  subject                     - ���� ������
  htmlText                    - html-����� ������
  attachmentFileName          - ��� ����� ��������
  attachmentType              - ��� ��������
  attachmentData              - ������ ��������
  expireDate                  - ���� ��������� ����� ����� ���������

  �������:
  Id ���������.
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
  ������� �������� ��������� ��� �������� � ���������� ��� Id.
  �������� ��������� ����� ��������� ����� ( � � ������) �������� ����������.

  ���������:
  sourceMessageId             - Id ���������, �� ������� ���������� �����
  sender                      - ����� �����������
  recipient                   - ������ �����������
  copyRecipient               - ������ ����������� �����
  subject                     - ���� ������
  messageText                 - ����� ������
  attachmentFileName          - ��� ����� ��������
  attachmentType              - ��� ��������
  attachmentData              - ������ ��������
  expireDate                  - ���� ��������� ����� ����� ���������

  �������:
  Id ���������.

  ���������:
  � ������ ���������� �������� � ���������� sender, recipient, copyRecipient �
  subject ����� �������������� ������ ��������� ������ � �������������, ���
  ����������� ������ �������� ������� �� ����.
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

  -- ������ ��������� ���������
  sourceSender ml_message.sender%type;
  sourceRecipientAddress ml_message.recipient_address%type;
  sourceCopyRecipient ml_message.copy_recipient%type;
  sourceSubject ml_message.subject%type;



  /*
    �������� ��������� ��������� ���������.
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
        '������ ��� ��������� ���������� ��������� ��������� ('
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
      , '�� ����� Id ��������� ���������.'
    );
  end if;

  -- �������� ��������� ��������� ���������
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
        '������ ��� �������� ��������� ��������� ��� �������� ('
        || ' source_message_id=' || to_char( sourceMessageId)
        || ').'
      )
    , true
  );
end sendReplyMessage;

/* iproc: checkAddAttachment
  �������� ���������� ���������� �������� � ���������.

  ���������:
  messageId                   - Id ���������, � �������� ����������� ��������
*/
procedure checkAddAttachment(
  messageId integer
)
is

  -- ������� ��������� ���������
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
      , '��������� �� ��������� � ��������� �������� ��������.'
    );
  end if;
end checkAddAttachment;

/* func: addAttachment
  ��������� �������� � ��������� ��� ��������.
  ��� ���������� ��������� ����������� � �����������, ��� ��� ��������� �
  ��������� <WaitSend_MessageStateCode>, ����� ������������� ����������.

  ���������:
  messageId                   - Id ���������, � �������� ����������� ��������
  attachmentFileName          - ��� ����� �������� ( ���� null, �� ������������
                                �������� �� <Attachment_DefaultFileName>)
  attachmentType              - ��� �������� ( ���� null, �� ������������
                                �������� �� <Attachment_DefaultType>)
  attachmentData              - ������ ��������

  �������:
  Id ������������ ��������
*/
function addAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob
)
return integer
is

  -- Id ��������
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
        '������ ��� ���������� �������� ��� ��������� ('
        || ' messageId=' || to_char( messageId)
        || ', attachmentFileName="' || attachmentFileName || '"'
        || ').'
      )
    , true
  );
end addAttachment;

/* func: addHtmlImageAttachment
  ��������� ����������� � HTML-��������� ��� ��������.
  ��� ���������� ��������� ����������� � �����������, ��� ��� ��������� �
  ��������� <WaitSend_MessageStateCode> � ��, ��� ��� HTML-���������,
  ����� ������������� ����������.

  ���������:
  messageId                   - Id ���������, � �������� ����������� ��������
  attachmentFileName          - ��� ����� �������� ( ���� null, �� ������������
                                �������� �� <Attachment_DefaultFileName>)
  contentType                 - ��� �������� ( ���� null, �� ������������
                                �������� �� <AttachmentImage_DefaultType>
                                ���� ������ ";" ���� name="<attachmentFileName>" )
  image                         - ������ �����������

  �������:
  Id ������������ ��������
*/
function addHtmlImageAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , contentType varchar2 := null
  , image blob
)
return integer
is

  -- Id ��������
  attachmentId ml_attachment.attachment_id%type;

  -- ������� HTML-���������
  isHtml integer;

begin
  checkAddAttachment( messageId);
  if coalesce( isHtml, 0 ) <> 1 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��������� �� �������� HTML-����������.'
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
        '������ ��� ���������� ����������� ��� HTML-��������� ('
        || ' messageId=' || to_char( messageId)
        || ', attachmentFileName="' || attachmentFileName || '"'
        || ').'
      )
    , true
  );
end addHtmlImageAttachment;

/* proc: cancelSendMessage
  �������� �������� ���������.
  ��������� ��������� ��� ���� ���������� � <WaitSend_MessageStateCode> ��
  <SendCanceled_MessageStateCode>.

  ���������:
  messageId                   - Id ���������
  expireDate                  - ���� ��������� ����� ����� ( ���� null, ��
                                �� ����������)

  ���������:
  - � ������ ���������� ��������� � ��������� <WaitSend_MessageStateCode>
    ������������� ����������;
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
      , '����������� ��������� �������� ���������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ �������� ��������� ('
        || ' messageId=' || to_char( messageId)
        || ', expireDate=' || to_char( expireDate, 'dd.mm.yyyy hh24:mi:ss')
        || ').'
      )
    , true
  );
end cancelSendMessage;



/* group: ��������� � ��������� ����� */

/* func: fetchMessage
  �������� ����� � ���������� ����� ���������� ���������.

  ���������:
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, ��� ������� ����� �����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
  isGotMessageDeleted         - ������� �� �� ����� ���������� ���������
                                ( 1 �� ( �� ���������), 0 ���)

  �������:
  ����� ���������� ���������

  ���������:
  - ������� ����������� � ���������� ����������;
*/
function fetchMessage(
  url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , isGotMessageDeleted integer := null
)
return integer
is

  -- ���������� ���������� � ����� � c �������������� ����������� ���������
  pragma autonomous_transaction;

  -- ����� ���������� ���������
  nFetched integer;

  -- Id ������� �� ���������� �� �����
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

  -- ������� ��������� �������
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
        '������ ��� ��������� �����'
      )
    , true
  );
end fetchMessage;

/* ifunc: getMessage( INTERNAL)
  ���� ����������������� ��������� � ������� "��������" �, ���� ��� �������,
  ��������� ���, ��������� � ������ "����������" � ���������� Id ��������� ���
  ���������� ���������.
  � ������, ���� � �� ��� ��������� ��� ��������� � ��� ������� URL ���������
  �����, ����� ��������� ��������� ����� �� ��������� ����� ( � ������� ������
  fetchMessage).

  ���������:
  senderAddress               - ����� ����������� ( �������)
  sendDate                    - ���� �������� ( �������)
  subject                     - ���� ��������� ( �������)
  messageText                 - ����� ��������� ( �������)
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, �� �������� ����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
  isGotMessageDeleted         - ������� �� �� ����� ���������� ���������
                                ( 1 �� ( �� ���������), 0 ���)
  expireDate                  - ���� ��������� ����� �����, �������
                                ��������������� ��� ��������� ������� ���������
                                ( ���� null, �� �� ����������)
  isGetMessageData            - ���������� ������������� �������� ������
                                ���������

  �������:
  Id ��������� ��� ���������� ��������� ( null ��� ���������� ���������).
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

  -- ������� ��������� ���������
  usedRecipientAddress ml_message.recipient_address%type;

  -- Id ���������� ���������
  messageId ml_message.message_id%type;

  -- ����������� ��������� ��������� �� ��������� �����
  isAllowFetch boolean := url is not null;



  /*
    �������� ������������� ��������� ��� ���������.
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
      -- ���������� ������ ��-�� ����������
      if SQLCODE <> pkg_Error.ResourceBusyNowait then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , '������ ��� ������� ���������� ��������� ('
            || ' message_id=' || to_char( checkMessageId)
            || ').'
          , true
        );
      end if;
  end lockMessage;



  /*
    ������������� ��������� ��������� �, ��� �������������, �������� ������
    ���������.
  */
  procedure setProcessedState
  is
  begin
    if not isGetMessageData then

      --������������� ��������� ���������
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

      --������������� ��������� ��������� � �������� ������ ���������
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
    ���� ����������������� ��������� ��� ���������.
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

  -- ���������� �������� ���������
  usedRecipientAddress :=
    case when recipientAddress is not null then
      recipientAddress
    else
      pkg_MailUtility.getMailboxAddress( url)
    end
  ;

  -- ���� ��������� ���������
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

    -- �������� ����� �� ����� ������ ����
    isAllowFetch := false;
  end loop;
  return messageId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ��������� ��� ���������'
        || case when usedRecipientAddress is not null then
            ' �� �������� "' || usedRecipientAddress || '"'
          end
        || '.'
      )
    , true
  );
end getMessage;

/* func: getMessage
  ���� ����������������� ��������� � ������� "��������" �, ���� ��� �������,
  ��������� ���, ��������� � ������ "����������" � ���������� Id ��������� ���
  ���������� ���������.
  � ������, ���� � �� ��� ��������� ��� ��������� � ��� ������� URL ���������
  �����, ����� ��������� ��������� ����� �� ��������� ����� ( � ������� ������
  <fetchMessage>).

  ���������:
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, �� �������� ����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
  isGotMessageDeleted         - ������� �� �� ����� ���������� ���������
                                ( 1 �� ( �� ���������), 0 ���)
  expireDate                  - ���� ��������� ����� �����, �������
                                ��������������� ��� ��������� ������� ���������
                                ( ���� null, �� �� ����������)

  �������:
  Id ��������� ��� ���������� ��������� ( null ��� ���������� ���������).
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

  -- ������ ��������� ( �� �����������)
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
  ���� ����������������� ��������� � ������� "��������" �, ���� ��� �������,
  ��������� ���, ��������� � ������ "����������" � ���������� Id ���������
  � �������� ����� ����������� ��� ���������� ���������.
  � ������, ���� � �� ��� ��������� ��� ��������� � ��� ������� URL ���������
  �����, ����� ��������� ��������� ����� �� ��������� ����� ( � ������� ������
  <fetchMessage>).

  ���������:
  senderAddress               - ����� �����������
                                ( �������)
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, �� �������� ����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
  isGotMessageDeleted         - ������� �� �� ����� ���������� ���������
                                ( 1 �� ( �� ���������), 0 ���)
  expireDate                  - ���� ��������� ����� �����, �������
                                ��������������� ��� ��������� ������� ���������
                                ( ���� null, �� �� ����������)

  �������:
  Id ��������� ��� ���������� ��������� ( null ��� ���������� ���������).
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

  -- ������ ���������
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
  ���� ����������������� ��������� � ������� "��������" �, ���� ��� �������,
  ��������� ���, ��������� � ������ "����������" � ���������� Id � ������
  ��������� ��� ���������� ���������.
  � ������, ���� � �� ��� ��������� ��� ��������� � ��� ������� URL ���������
  �����, ����� ��������� ��������� ����� �� ��������� ����� ( � ������� ������
  <fetchMessage>).

  ���������:
  senderAddress               - ����� �����������
                                ( �������)
  sendDate                    - ���� ��������
                                ( �������)
  subject                     - ���� ���������
                                ( �������)
  messageText                 - ����� ���������
                                ( �������)
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, �� �������� ����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
  isGotMessageDeleted         - ������� �� �� ����� ���������� ���������
                                ( 1 �� ( �� ���������), 0 ���)
  expireDate                  - ���� ��������� ����� �����, �������
                                ��������������� ��� ��������� ������� ���������
                                ( ���� null, �� �� ����������)
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
  ���� ����������������� ��������� � ������� "��������" �, ���� ��� �������,
  ��������� ���, ��������� � ������ "����������" � ���������� Id � ������
  ��������� ��� ���������� ���������.
  ���� ��������� ����� ��������, �� ����� ������������ ������ �������� (
  ���� ����� ������ �������� - ������������� ����������).
  � ������, ���� � �� ��� ��������� ��� ��������� � ��� ������� URL ���������
  �����, ����� ��������� ��������� ����� �� ��������� ����� ( � ������� ������
  <fetchMessage>).

  ���������:
  senderAddress               - ����� �����������
                                ( �������)
  sendDate                    - ���� ��������
                                ( �������)
  subject                     - ���� ���������
                                ( �������)
  messageText                 - ����� ���������
                                ( �������)
  attachmentFileName          - ��� ����� ��������
                                ( �������)
  attachmentType              - ��� ��������
                                ( �������)
  attachmentData              - ������ ��������
                                ( �������)
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, �� �������� ����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
  isGotMessageDeleted         - ������� �� �� ����� ���������� ���������
                                ( 1 �� ( �� ���������), 0 ���)
  expireDate                  - ���� ��������� ����� �����, �������
                                ��������������� ��� ��������� ������� ���������
                                ( ���� null, �� �� ����������)

  �������:
  Id ��������� ��� ���������� ��������� ( null ��� ���������� ���������).
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

  -- Id ���������
  messageId ml_message.message_id%type;



  /*
    �������� ������ �������� ( ���� ��� ������������).
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
      -- ���������� ���������� ��������
      null;
    when TOO_MANY_ROWS then
      raise_application_error(
        pkg_Error.ProcessError
        , '��������� ����� ����� ������ �������� ('
          || ' message_id=' || to_char( messageId)
          || ').'
      );
    when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '������ ��� ��������� ������ �������� ��� ��������� ('
          || ' message_id=' || to_char( messageId)
          || ').'
        , true
      );
  end getAttachment;



-- getMessage
begin
  savepoint pkg_Mail_GetMessageAttach;

  -- �������� ���������
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

  -- �������� ��������
  if messageId is not null then
    getAttachment();
  end if;
  return messageId;
exception when others then
  rollback to pkg_Mail_GetMessageAttach;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ��������� � ��������� ��� ���������.'
      )
    , true
  );
end getMessage;

/* proc: setProcessError
  ������������� ������ ��������� ���������.

  ���������:
  messageId                   - Id ���������
  errorCode                   - ��� ������
  errorMessage                - ��������� �� ������
  expireDate                  - ���� ��������� ����� �����
                                ( ���� null, �� �� ����������)
  mailboxForDeleteFlag        - ���� ������������� �������� ��������� ��
                                ��������� ����� � ������ ��� �������
                                ( 1 �������, 0 �� �������)
                                ( ���� null, �� �� ����������)
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
      , '����������� ��������� � ���������� ���������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ������ ��������� ��������� ('
        || ' messageId=' || to_char( messageId)
        || ', errorCode=' || to_char( errorCode)
        || ', errorMessage="' || substr( errorMessage, 1, 400) || '"'
        || ').'
      )
    , true
  );
end setProcessError;

/* proc: deleteMailboxMessage
  ������������� ���� �������� ��������� �� ��������� �����. ����������
  �������� ����� ����������� ��� ��������� ��������� ��������� �� ���������
  ����� � ������ ������� � ��� ������� ���������.

  ���������:
  messageId                   - Id ���������
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
      , '��������� �� �������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ����� �������� ��������� �� ��������� ����� ('
        || ' messageId=' || to_char( messageId)
        || ').'
      )
    , true
  );
end deleteMailboxMessage;

end pkg_Mail;
/
