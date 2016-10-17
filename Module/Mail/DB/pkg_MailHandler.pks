create or replace package pkg_MailHandler is
/* package: pkg_MailHandler
  ���������� ��������� ��������� ������ Mail.
*/



/* group: ������� */



/* group: �������� ����� */

/* pfunc: sendMessage
  ���������� ��������� �������� ��������� � ���������� ����� ������������
  ���������.

  ���������:
  smtpServer                  - ��� ( ��� ip-�����) SMTP-�������
                                �������� null �������������� �
                                pkg_Common.getSmtpServer.
  maxMessageCount             - ����������� �� ���������� ������������ ���������
                                �� ���� ������ ���������. � ������ ��������
                                null, ����������� �� ������������.

  �������:
  ����� ������������ ���������.

  ���������:
  - � ���������� ��������� <body::sendMessageJava> ���������� ��������
    ���������� ���������� ����� ������� ������������� email-���������;

  ( <body::sendMessage>)
*/
function sendMessage(
  smtpServer varchar2 := null
  , maxMessageCount integer := null
)
return integer;

/* pfunc: sendHandler
  ���������� �������� �����.

  ���������:
  smtpServerList              - ������ ��� ( ��� ip-�������) SMTP-��������
                                ����� ",".
                                �������� null �������������� � pkg_Common.getSmtpServer.
  maxMessageCount             - ����������� �� ���������� ������������ ���������
                                �� ���� ������ ���������. � ������ ��������
                                null, ����������� �� ������������.

  ���������:
  - � ���������� ��������� <body::sendMessage> ���������� �������� ����������.

  ( <body::sendHandler>)
*/
procedure sendHandler(
  smtpServerList varchar2 := null
  , maxMessageCount integer := null
);



/* group: ��������� ����� */

/* pfunc: fetchMessageImmediate
  �������� ����� � ���������� ����� ���������� ��������� ( � ��� �� ������).

  ���������:
  errorMessage                - ��������� �� ������ ��������� ���������
                                ( �������)
  errorCode                   - ��� ��������� �� ������
                                ( �������)
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  password                    - ������ ��� ����������� � ��������� �����
                                ( ���� null, �� ������������ ������ �� url)
  recipientAddress            - ����� ����������, ��� ������� ����� �����������
                                ���������� ��������� ( ��� ���������� ����������
                                �� URL ��� user@domen)
  isGotMessageDeleted         - ������� �� �� ����� ���������� ���������
  fetchRequestId              - id ������� ���������� �� �����

  �������:
  ����� ���������� ���������

  ���������:
  - ������� ����������� � ���������� ����������;

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
  ��������� ������� �������� �� ���������� �� ������

  ���������:
  batchShortName              - ��������� �������� ������ �� ������������
                                ����������� �����
  fetchRequestId              - �������� ��� ��������� ������������ �������

  �������:
  ���������� ������������ ��������.

  ( <body::processFetchRequest>)
*/
function processFetchRequest(
  batchShortName varchar2 := null
  , fetchRequestId integer := null
)
return integer;

/* pproc: fetchHandler
  ���������� �������� �� ���������� �� ������

  ���������:
  checkRequestInterval        - �������� ��� �������� ������� �������� ���
                                ���������
  maxRequestCount             - ������������ ���������� ��������������
                                �������� �� ������
  batchShortName              - �������� ��� ��������� �������� ������ ��
                                ������������ ����������� �����

  ( <body::fetchHandler>)
*/
procedure fetchHandler(
  checkRequestInterval interval day to second
  , maxRequestCount integer := null
  , batchShortName varchar2 := null
);



/* group: ��������������� ������� */

/* pfunc: notifyError
  ����������� �� ������� ( �� e-mail) � ���������� ����� ��������� ������.

  ���������:
  sendLimit                   - ����� �������, � ������� �������� ������ ����
                                ����������� ������� �������� ��������� ( ���
                                �������� null ����� ������������ �������� ��
                                ���������)
  smtpServerList              - ������ ��� ( ��� ip-�������) SMTP-��������
                                ����� ",". ������ ������ ��������������
                                � pkg_Common.getSmtpServer.

  �������:
    - ���������� ������

  ( <body::notifyError>)
*/
function notifyError(
  sendLimit interval day to second := null
  , smtpServerList varchar2 := null
)
return integer;

/* pfunc: clearExpiredMessage
  ������� ��������� � �������� ������ ����� � ���������� ����� ���������
  ���������.

  ���������:
  checkDate                   - ���� �������� ( �� ��������� ������� ����)

  ���������:
  ���� ��������� ������ � ������� ( �� source_message_id), �� ��� ����� �������
  ������ ������ �� ���� �������� ( �.�. ����� � ���� ��������� � �������
  ������� ���� �����).
  ��������� ��������� ��������� ��� ��������� ����� ����� ��������� ���������
  ���������.

  ( <body::clearExpiredMessage>)
*/
function clearExpiredMessage(
  checkDate date := null
)
return integer;

/* pfunc: clearFetchRequest
  ������� ������� ���������� �� �����
  � ����� �������� �� �����������
  ����

  ���������:
  beforeDate                  - ����, �� ������� ������� �������

  ( <body::clearFetchRequest>)
*/
procedure clearFetchRequest(
  beforeDate date
);

end pkg_MailHandler;
/
