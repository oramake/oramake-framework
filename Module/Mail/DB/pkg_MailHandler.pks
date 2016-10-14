create or replace package pkg_MailHandler is
/* package: pkg_MailHandler
  ���������� ��������� ��������� ������ Mail.
*/



/* group: ������� */

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

end pkg_MailHandler;
/
