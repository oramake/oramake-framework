create or replace package pkg_MailInternal is
/* package: pkg_MailInternal
  ���������� ���������-������� ������ Mail
*/



/* group: ��������� */

/* group: ��������� �������� */

/* const: Wait_RequestStateCode
  ��� ��������� "�������� ���������"
*/
Wait_RequestStateCode constant varchar2(10) := 'WAIT';

/* const: Error_RequestStateCode
  ��� ��������� "������ ���������"
*/
Error_RequestStateCode constant varchar2(10) := 'ERROR';

/* const: Processed_RequestStateCode
  ��� ��������� "������� ���������"
*/
Processed_RequestStateCode constant varchar2(10) := 'PROCESSED';



/* group: ������� */

/* pproc: logJava
  ������������ ��������� ������������
  ��� ������������� � Java

  ���������:
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������

  ( <body::logJava>)
*/
procedure logJava(
  levelCode varchar2
  , messageText varchar2
);

/* pfunc: getBatchShortName
  ���������� ������������ ����� ������

  ���������:
  forcedBatchShortName        - ��������������� ������������ �����

  �������:
  ��� ������������ �����.

  ( <body::getBatchShortName>)
*/
function getBatchShortName(
  forcedBatchShortName varchar2 := null
)
return varchar2;

/* pproc: initCheckTime
  ������������� �������� ����������� �������� � ������

  ( <body::initCheckTime>)
*/
procedure initCheckTime;

/* pproc: initRequestCheckTime
  ������������� �������� ����������� ������ � ��������

  ( <body::initRequestCheckTime>)
*/
procedure initRequestCheckTime;

/* pproc: initHandler
  ������������� �����������.

  ���������:
  processName                 - ��� ��������

  ( <body::initHandler>)
*/
procedure initHandler(
  processName varchar2
);

/* pfunc: waitForCommand
  ������� �������, ���������� ����� pipe
  � ������ ���� ��������� ����� ��������� �������
  � ������ <lastCommandCheck>.

  ���������:
  command                     - ������� ��� ��������
  checkRequestTimeOut         - �������� ��� �������� �������� �������
                                ���� ����� �������� �������� �������
                                ����������� �� ������ ����������
                                (<body::lastRequestCheck>).

  �������:
  �������� �� �������.

  ( <body::waitForCommand>)
*/
function waitForCommand(
  command varchar2
  , checkRequestTimeOut integer := null
)
return boolean;

/* pfunc: nextRequestTime
  ���������� ��������� �������� ��� �������� ������� ��������.
  ����������� ���������� <body::lastRequestCheck>.

  ��������:
  checkRequestTimeOut         - ������� �������� �������( � ��������)

  �������:
  ��������� �� ����� ��������� ������.

  ( <body::nextRequestTime>)
*/
function nextRequestTime(
  checkRequestTimeOut number
)
return boolean;

/* pproc: waitForFetchRequest
  �������� ������� ���������� ���������

  ���������:
  fetchRequestId              - Id �������

  ( <body::waitForFetchRequest>)
*/
procedure waitForFetchRequest(
  fetchRequestId integer
);

end pkg_MailInternal;
/
