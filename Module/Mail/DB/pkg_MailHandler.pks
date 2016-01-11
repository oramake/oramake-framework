create or replace package pkg_MailHandler is
/* package: pkg_MailHandler
  ���������� ��������� ��������� ������ Mail.
*/

/* pfunc: NotifyError
  ����������� �� ������� ( <body::NotifyError>).
*/
function NotifyError(
  sendLimit interval day to second := null
  , smtpServerList varchar2 := null
)
return integer;

/* pfunc: ClearExpiredMessage
  ������� ��������� � �������� ������ ����� ( <body::ClearExpiredMessage>).
*/
function ClearExpiredMessage(
  checkDate date := null
)
return integer;

/* pfunc: ClearFetchRequest
  ������� ������� ���������� �� ����� 
  (<body::ClearFetchRequest>)
*/
procedure ClearFetchRequest(
  beforeDate date
);

/* pfunc: SendMessage
  ���������� ��������� �������� ��������� ( <body::SendMessage>).
*/
function SendMessage(
  smtpServer varchar2 := null
  , maxMessageCount integer := null
)
return integer;

/* pfunc: SendHandler
  ���������� �������� ����� ( <body::SendHandler>).
*/
procedure SendHandler(
  smtpServerList varchar2 := null
  , maxMessageCount integer := null
);

/* pfunc: ProcessFetchRequest
  ��������� ������� �������� �� ���������� �� ������
  (<body::ProcessFetchRequest>)
*/
function ProcessFetchRequest(
  batchShortName varchar2 := null
  , fetchRequestId integer := null
)
return integer;

/* pproc: FetchHandler
  ���������� �������� �� ���������� �� ������
  (<body::FetchHandler>)
*/
procedure FetchHandler(
  checkRequestInterval interval day to second
  , maxRequestCount integer := null
  , batchShortName varchar2 := null
);

end pkg_MailHandler;
/
