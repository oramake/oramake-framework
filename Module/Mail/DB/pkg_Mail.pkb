create or replace package body pkg_Mail is
/* package body: pkg_Mail::body */

/* itype: TUrlString
  ��� ��� ������ � URL.
*/
subtype TUrlString is ml_fetch_request.url%type;

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

/* ivar: logger
  ������������ ������ � ������ Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => Module_Name
    , objectName => 'pkg_Mail'
  );

/* func: SendMailJava
  ���������� ������ ( ����������).
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
                                ������������ ������ �� pkg_Common.GetSmtpServer)
  isHTML                      - ���������� �� ������ ��� HTML;
                                ��-��������� ������ ������������ ��� ������� �����
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
    , logger.ErrorStack( '������ ��� �������� ������ ('
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
  �������� �������� ���������.
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
  �������� ����� � ���������� ����� ���������� ���������
  ( � ��� �� ������)

  ���������:
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, ��� ������� ����� �����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
  fetchRequestId              - id ������� ���������� �� �����
  isGotMessageDeleted         - ������� �� �� ����� ���������� ���������
  errorMessage                - ��������� �� ������ ��������� ���������
  errorCode                   - ��� ��������� �� ������
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

                                        --���������� ���������� � ����� �
                                        --���������� � �������� �������
  pragma autonomous_transaction;
                                        --����� ���������� ���������
  nFetched integer := null;
                                        --URL � ��������� �������
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
      '������ ��� ��������� �����'
      || case when clearUrl is not null then
          ' �� URL "' || clearUrl || '"'
         end
      || ': ' || errorMessage;
  end if;
  return nFetched;
end FetchMessageImmediate;

/* func: FetchMessageImmediate
  �������� ����� � ���������� ����� ���������� ���������
  ( � ��� �� ������)

  ���������:
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, ��� ������� ����� �����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
*/
function FetchMessageImmediate
(
 url varchar2
 , password varchar2 := null
 , recipientAddress varchar2 := null
)
return integer
is
                                       -- ���������� ����������� ���������
  nFetched integer;
                                       -- ������ �� ������
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
    , logger.ErrorStack( '������ ��� ���������� ���������')
    , true
  );
end FetchMessageImmediate;

/* func: FetchMessage
  �������� ����� � ���������� ����� ���������� ���������.

  ���������:
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, ��� ������� ����� �����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
*/
function FetchMessage
 (url varchar2
 , password varchar2 := null
 , recipientAddress varchar2 := null
 )
 return integer
 is

                                        -- ���������� ���������� � ����� �
                                        -- c �������������� �����������
                                        -- ���������
  pragma autonomous_transaction;
                                        -- ����� ���������� ���������
  nFetched integer;
                                        -- Id ������� �� ����������
                                        -- �� �����
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
                                       -- ������� ���������
                                       -- �������
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
    , logger.ErrorStack( '������ ��� ��������� �����')
    , true
  );
end FetchMessage;
/* func: GetMessage( INTERNAL)
  ���� ����������������� ��������� � ������� "��������" �, ���� ��� �������,
  ��������� ���, ��������� � ������ "����������" � ���������� Id ��������� ���
  ���������� ���������.
  � ������, ���� � �� ��� ��������� ��� ��������� � ��� ������� URL ���������
  �����, ����� ��������� ��������� ����� �� ��������� ����� ( � ������� ������
  FetchMessage).

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
  expireDate                  - ���� ��������� ����� �����, �������
                                ��������������� ��� ��������� ������� ���������
                                ( ���� null, �� �� ����������)
  isGetMessageData            - ���������� ������������� �������� ������
                                ���������
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

                                        --������� ��������� ���������
  usedRecipientAddress ml_message.recipient_address%type;
                                        --Id ���������� ���������
  messageId ml_message.message_id%type;
                                        --����������� ��������� ��������� ��
                                        --��������� �����
  isAllowFetch boolean := url is not null;



  procedure LockMessage(
    checkMessageId integer
  )
  is
  --�������� ������������� ��������� ��� ���������.

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
    when others then                    --���������� ������ ��-�� ����������
      if SQLCODE <> pkg_Error.ResourceBusyNowait then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , '������ ��� ������� ���������� ��������� ('
            || ' message_id=' || to_char( checkMessageId)
            || ').'
          , true
        );
      end if;
  end LockMessage;



  procedure SetProcessedState
  is
  --������������� ��������� ��������� �, ��� �������������, �������� ������
  --���������.

  --SetProcessedState
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
                                        --������������� ��������� ���������
                                        --� �������� ������ ���������
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
  --���� ����������������� ��������� ��� ���������.

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
                                        --���������� �������� ���������
  usedRecipientAddress :=
    case when recipientAddress is not null then
      recipientAddress
    else
      pkg_MailUtility.GetMailboxAddress( url)
    end
  ;
                                        --���� ��������� ���������
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
                                        --�������� ����� �� ����� ������ ����
    isAllowFetch := false;
  end loop;
  return messageId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��� ��������� ��������� ��� ���������'
      || case when usedRecipientAddress is not null then
          ' �� �������� "' || usedRecipientAddress || '"'
        end
      || '.' )
    , true
  );
end GetMessage;
/* func: GetMessage
  ���� ����������������� ��������� � ������� "��������" �, ���� ��� �������,
  ��������� ���, ��������� � ������ "����������" � ���������� Id ��������� ���
  ���������� ��������� ( ���� ������ �� ������� - ������������ null).
  � ������, ���� � �� ��� ��������� ��� ��������� � ��� ������� URL ���������
  �����, ����� ��������� ��������� ����� �� ��������� ����� ( � ������� ������
  FetchMessage).

  ���������:
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, �� �������� ����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
  expireDate                  - ���� ��������� ����� �����, �������
                                ��������������� ��� ��������� ������� ���������
                                ( ���� null, �� �� ����������)
*/
function GetMessage(
  url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , expireDate date := null
)
return integer
is

                                        --������ ��������� ( �� �����������)
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
  ���� ����������������� ��������� � ������� "��������" �, ���� ��� �������,
  ��������� ���, ��������� � ������ "����������" � ���������� Id ���������
  � �������� ����� ����������� ��� ���������� ��������� ( ���� ������ ��
  ������� - ������������ null).
  � ������, ���� � �� ��� ��������� ��� ��������� � ��� ������� URL ���������
  �����, ����� ��������� ��������� ����� �� ��������� ����� ( � ������� ������
  FetchMessage).

  ���������:
  senderAddress               - ����� ����������� ( �������)
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, �� �������� ����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
  expireDate                  - ���� ��������� ����� �����, �������
                                ��������������� ��� ��������� ������� ���������
                                ( ���� null, �� �� ����������)
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

                                        --������ ���������
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
  ���� ����������������� ��������� � ������� "��������" �, ���� ��� �������,
  ��������� ���, ��������� � ������ "����������" � ���������� Id � ������
  ��������� ��� ���������� ��������� ( ���� ������ �� ������� - ������������
  null).
  � ������, ���� � �� ��� ��������� ��� ��������� � ��� ������� URL ���������
  �����, ����� ��������� ��������� ����� �� ��������� ����� ( � ������� ������
  FetchMessage).

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
  expireDate                  - ���� ��������� ����� �����, �������
                                ��������������� ��� ��������� ������� ���������
                                ( ���� null, �� �� ����������)
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
  ���� ����������������� ��������� � ������� "��������" �, ���� ��� �������,
  ��������� ���, ��������� � ������ "����������" � ���������� Id � ������
  ��������� ��� ���������� ��������� ( ���� ������ �� ������� - ������������
  null).
  ���� ��������� ����� ��������, �� ����� ������������ ������ �������� (
  ���� ����� ������ �������� - ������������� ����������).
  � ������, ���� � �� ��� ��������� ��� ��������� � ��� ������� URL ���������
  �����, ����� ��������� ��������� ����� �� ��������� ����� ( � ������� ������
  FetchMessage).

  ���������:
  senderAddress               - ����� ����������� ( �������)
  sendDate                    - ���� �������� ( �������)
  subject                     - ���� ��������� ( �������)
  messageText                 - ����� ��������� ( �������)
  attachmentFileName          - ��� ����� �������� ( �������)
  attachmentType              - ��� �������� ( �������)
  attachmentData              - ������ �������� ( �������)
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, �� �������� ����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
  expireDate                  - ���� ��������� ����� �����, �������
                                ��������������� ��� ��������� ������� ���������
                                ( ���� null, �� �� ����������)
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

                                        --Id ���������
  messageId ml_message.message_id%type;



  procedure GetAttachment
  is
  --�������� ������ �������� ( ���� ��� ������������).

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
    when NO_DATA_FOUND then             --���������� ���������� ��������
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
  end GetAttachment;



--GetMessage
begin
  savepoint pkg_Mail_GetMessageAttach;
                                        --�������� ���������
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
                                        --�������� ��������
  if messageId is not null then
    GetAttachment();
  end if;
  return messageId;
exception when others then
  rollback to pkg_Mail_GetMessageAttach;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ��� ��������� ��������� � ��������� ��� ���������.'
      )
    , true
  );
end GetMessage;
/* proc: SetProcessError
  ������������� ������ ��������� ���������.

  ���������:
  messageId                   - Id ���������
  errorCode                   - ��� ������
  errorMessage                - ��������� �� ������
  expireDate                  - ���� ��������� ����� ����� ( ���� null, ��
                                �� ����������)
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
      , '����������� ��������� � ���������� ���������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��� ��������� ������ ��������� ��������� ('
      || ' message_id=' || to_char( messageId)
      || ', error_code=' || to_char( errorCode)
      || ', error_message="' || substr( errorMessage, 1, 400) || '"'
      || ').' )
    , true
  );
end SetProcessError;
/* func: CreateAttachment
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
function CreateAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob
  , isImageContentId integer := null
)
return integer
is

                                        --Id ��������
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
    , logger.ErrorStack( '������ ��� �������� ��������.' )
    , true
  );
end CreateAttachment;
/* func: SendMessage( INTERNAL)
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
  isHTML                      - ��������� ��������� ��� HTML ( 1-��,0-��� )
                              ��-��������� ���
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

                                        --Id ���������� ���������
  messageId ml_message.message_id%type;
                                        --Id ��������
  attachmentId ml_attachment.attachment_id%type;




  procedure AddMessage
  is
  --��������� ������ � ������� ���������.

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
                                        --��������� ���������
  AddMessage;
                                        --��������� ��������
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
    , logger.ErrorStack( '������ ��� �������� ��������� ��� �������� ('
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
                              --����� �������� �������
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
                              --����� �������� �������
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

  ���������:
  � ������ ���������� �������� � ���������� sender, recipient, copyRecipient �
  subject ����� �������������� ������ ��������� ������ � �������������, ���
  ����������� ������ �������� ������� �� ����.
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

                                        --������ ��������� ���������
  sourceSender ml_message.sender%type;
  sourceRecipientAddress ml_message.recipient_address%type;
  sourceCopyRecipient ml_message.copy_recipient%type;
  sourceSubject ml_message.subject%type;



  procedure GetSourceMessageParam
  is
  --�������� ��������� ��������� ���������.

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
        '������ ��� ��������� ���������� ��������� ��������� ('
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
      , '�� ����� Id ��������� ���������.'
    );
  end if;
                                        --�������� ��������� ��������� ���������
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
      '������ ��� �������� ��������� ��������� ��� �������� ('
      || ' source_message_id=' || to_char( sourceMessageId)
      || ').' )
    , true
  );
end SendReplyMessage;

/* proc: CheckAddAttachment
  �������� ���������� ���������� �������� � ���������.

  ���������:
  messageId                   - Id ���������, � �������� ����������� ��������
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
    , '������ �������� ����������� ���������� �������� ('
      || ' messageId=' || to_char( messageId)
      || ').'
    , true
  );
end CheckAddAttachment;

/* func: AddAttachment
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
function AddAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , attachmentType varchar2 := null
  , attachmentData blob
)
return integer
is

                                        --Id ��������
  attachmentId ml_attachment.attachment_id%type;
                                        --������� ��������� ���������
  messageStateCode ml_message.message_state_code%type;
begin
                                        -- �������� ����������� ����������
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
    , logger.ErrorStack( '������ ��� ���������� �������� ��� ��������� ('
      || ' messageId=' || to_char( messageId)
      || ', attachmentFileName="' || attachmentFileName || '"'
      || ').' )
    , true
  );
end AddAttachment;
/* func: AddHTMLImageAttachment
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
function AddHTMLImageAttachment(
  messageId integer
  , attachmentFileName varchar2 := null
  , contentType varchar2 := null
  , image blob
)
return integer
is

                                        -- Id ��������
  attachmentId ml_attachment.attachment_id%type;
                                        --������� ��������� ���������
  messageStateCode ml_message.message_state_code%type;
                                        -- ������� HTML-���������
  isHTML integer;
begin
                                        -- �������� ����������� ����������
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
      , '��������� �� ��������� � ��������� �������� ��������.'
    );
  end if;
  if coalesce( isHTML, 0 ) <> 1 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��������� �� �������� HTML-����������.'
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
      '������ ��� ���������� ����������� ��� HTML-��������� ('
      || ' messageId=' || to_char( messageId)
      || ', attachmentFileName="' || attachmentFileName || '"'
      || ').' )
    , true
  );
end AddHTMLImageAttachment;
/* proc: CancelSendMessage
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
      , '����������� ��������� �������� ���������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��� ������ �������� ��������� ('
      || ' messageId=' || to_char( messageId)
      || ', expireDate=' || to_char( expireDate, 'dd.mm.yyyy hh24:mi:ss')
      || ').' )
    , true
  );
end CancelSendMessage;


end pkg_Mail;
/
