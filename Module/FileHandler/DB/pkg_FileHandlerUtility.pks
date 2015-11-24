create or replace package pkg_FileHandlerUtility is
/* package: pkg_FileHandlerUtility
  ����� ������ ������ FileHandler

  SVN root: Oracle/Module/FileHandler
*/

/* pfunc: GetBatchShortName
  ���������� ������������ ����� ������
  (<body::GetBatchShortName>)
*/
function GetBatchShortName(
  forcedBatchShortName varchar2 := null
)
return varchar2;

/* pproc: SetCreateCacheTextMask
  ������������ �������� ����� ��������� ������
  ��� ��������������� ����������� ����������
  (<body::SetCreateCacheTextMask>)
*/
procedure SetCreateCacheTextMask(
  newValue varchar2
);

/* pfunc: GetCreateCacheTextMask
  ��������� �������� ����� ��������� ������
  ��� ��������������� ����������� ����������
  (<body::GetCreateCacheTextMask>)
*/
function GetCreateCacheTextMask
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

/* pproc: ClearOldRequest
 ������� ������ ������������ ��������
 (<body::ClearOldRequest>)
*/
procedure ClearOldRequest(
  toDate date
);

end pkg_FileHandlerUtility;
/