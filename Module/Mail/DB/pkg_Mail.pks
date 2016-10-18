create or replace package pkg_Mail is
/* package: pkg_Mail
  ������������ ����� ������ Mail.
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����
*/
Module_Name constant varchar2(30) := 'Mail';



/* group: ���� ��������� ��������� */

/* const: Received_MessageStateCode
  ��� ��������� ��������� "��������"
*/
Received_MessageStateCode constant varchar2(10) := 'R';

/* const: Nested_MessageStateCode
  ��� ��������� ��������� "���������"
*/
Nested_MessageStateCode constant varchar2(10) := 'N';

/* const: Processed_MessageStateCode
  ��� ��������� ��������� "����������"
*/
Processed_MessageStateCode constant varchar2(10) := 'P';

/* const: ProcessError_MessageStateCode
  ��� ��������� ��������� "������ ���������"
*/
ProcessError_MessageStateCode constant varchar2(10) := 'PE';

/* const: WaitSend_MessageStateCode
  ��� ��������� ��������� "������� ��������"
*/
WaitSend_MessageStateCode constant varchar2(10) := 'WS';

/* const: SendCanceled_MessageStateCode
  ��� ��������� ��������� "�������� ��������".
  ������������ ��� ������ �������� ��������� �������� ���������.
*/
SendCanceled_MessageStateCode constant varchar2(10) := 'SC';

/* const: Send_MessageStateCode
  ��� ��������� ��������� "����������"
*/
Send_MessageStateCode constant varchar2(10) := 'S';

/* const: SendError_MessageStateCode
  ��� ��������� ��������� "������ ��������"
*/
SendError_MessageStateCode constant varchar2(10) := 'SE';



/* group: MIME-���� ������ */

/* const: PlainText_MimeType
  �������� MIME-���� ��� ��������� ������
*/
PlainText_MimeType constant varchar2(40) := 'text/plain';

/* const: BinaryData_MimeType
  �������� MIME-���� ��� �������� ������
*/
BinaryData_MimeType constant varchar2(40) := 'application/octet-stream';

/* const: ImageJPEGData_MimeType
  �������� MIME-���� ��� ����������� JPEG
*/
ImageJPEGData_MimeType constant varchar2(40) := 'image/jpeg';



/* group: ������� */



/* group: �������� ����� */

/* pproc: sendMail
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

  ( <body::cancelSendMessage>)
*/
procedure cancelSendMessage(
  messageId integer
  , expireDate date := null
);



/* group: ��������� � ��������� ����� */

/* pfunc: fetchMessage
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
  ������������� ���� �������� ��������� �� ��������� �����. ����������
  �������� ����� ����������� ��� ��������� ��������� ��������� �� ���������
  ����� � ������ ������� � ��� ������� ���������.

  ���������:
  messageId                   - Id ���������

  ( <body::deleteMailboxMessage>)
*/
procedure deleteMailboxMessage(
  messageId integer
);

end pkg_Mail;
/
