create or replace package pkg_MailInternal is
/* package: pkg_MailInternal
  ���������� ���������-������� ������ Mail
*/

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

/* group: ��������� � ������� */

/* pfunc: GetIsGotMessageDeleted
  ������� ����� <body::isGotMessageDeleted>.
  (<body::GetIsGotMessageDeleted>)
*/
function GetIsGotMessageDeleted
return integer;

/* pproc: SetIsGotMessageDeleted
  ��������� ����� <body::isGotMessageDeleted>.
  (<body::SetIsGotMessageDeleted>)
*/
procedure SetIsGotMessageDeleted(
  isGotMessageDeleted integer
);

/* pproc: LogJava
  ������������ ��������� � ������ Logging
  ��� ������������� � Java
  (<body::LogJava>).
*/
procedure LogJava(
  levelCode varchar2
  , messageText varchar2
);

/* pfunc: GetBatchShortName
  ���������� ������������ ����� ������
  (<body::GetBatchShortName>)
*/
function GetBatchShortName(
  forcedBatchShortName varchar2 := null
)
return varchar2;

/* pproc: InitCheckTime
  ������������� �������� ����������� �������� � ������
  (<body::InitCheckTime>)
*/
procedure InitCheckTime;

/* pproc: InitRequestCheckTime
  ������������� �������� ����������� ��������
  (<body::InitRequestCheckTime>)
*/
procedure InitRequestCheckTime;

/* pproc: InitHandler
  ������������� �����������
  (<body::InitHandler>)
*/
procedure InitHandler(
  processName varchar2
);

/* pfunc: WaitForCommand
  ������� �������, ���������� ����� pipe
  (<body::WaitForCommand>)
*/
function WaitForCommand(
  command varchar2
  , checkRequestTimeOut integer := null
)
return boolean;

/* pfunc: NextRequestTime
  ���������� ��������� �������� ��� ��������
  ������� ��������
  (<body::NextRequestTime>)
*/
function NextRequestTime(
  checkRequestTimeOut number
)
return boolean;

/* pproc: WaitForFetchRequest
  �������� ������� ���������� ���������
  (<body::WaitForFetchRequest>)
*/
procedure WaitForFetchRequest(
  fetchRequestId integer
);

end pkg_MailInternal;
/
