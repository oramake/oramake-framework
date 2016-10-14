create or replace package pkg_Mail is
/* package: pkg_Mail
  ������������ ����� ������ Mail.
*/

/* const: Module_Name
  �������� ������, � �������� ��������� �����
*/
Module_Name constant varchar2(30) := 'Mail';

/* Group: ���� ��������� ��������� */

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

/* Group: MIME-���� ������ */

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

/* Group: Functions public */

/* pproc: SendMail
  ���������� ������ ( ����������) ( <body::SendMail>).
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
  �������� ����� � ���������� ����� ���������� ���������
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
  �������� ����� � ���������� ����� ���������� ���������
  ( <body::FetchMessageImmediate>)
*/
function FetchMessageImmediate
 (url varchar2
 , password varchar2 := null
 , recipientAddress varchar2 := null
)
return integer;

/* pfunc: FetchMessage
  �������� �������� ��������� ( <body::FetchMessage>).
*/
function FetchMessage
 (url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
 )
 return integer;
/* pfunc: GetMessage
  ���������� Id ��������� ��� ��������� ( <body::GetMessage>).
*/
function GetMessage(
  url varchar2
  , password varchar2 := null
  , recipientAddress varchar2 := null
  , expireDate date := null
)
return integer;
/* pfunc: GetMessage( out SenderAddress)
  ���������� ��������� ��� ���������
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
  ���������� ��������� ��� ��������� ( <body::GetMessage( out DATA)>).
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
  ���������� ��������� � �������� ( ���� ����) ��� ���������
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
  ������������� ������ ��������� ��������� ( <body::SetProcessError>).
*/
procedure SetProcessError(
  messageId integer
  , errorCode integer
  , errorMessage varchar2
  , expireDate date := null
);
/* pfunc: SendMessage
  ������� ��������� ��� �������� ( <body::SendMessage>).
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
  ������� ��������� � ���� HTML.
  �������� ��������� ����� ��������� ����� ( � � ������) �������� ����������.
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
  ������� �������� ��������� ��� �������� ( <body::SendReplyMessage>).
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
  ��������� �������� � ��������� ��� ��������
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
  ��������� ����������� � HTML-��������� ��� ��������.
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
  �������� �������� ��������� ( <body::CancelSendMessage>).
*/
procedure CancelSendMessage(
  messageId integer
  , expireDate date := null
);


end pkg_Mail;
/
