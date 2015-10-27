create or replace package pkg_ProcessMonitorUtility is
/* package: pkg_ProcessMonitorUtility
  ����� ������ ������ ProcessMonitor.

  SVN root: Oracle/Module/ProcessMonitor
*/



/* group: ������� */



/* pfunc: getOperatorId
  ��������� id �������� ���������
  ( <body::getOperatorId>)
*/
function getOperatorId
return integer;

/* pproc: oraKill
  ���������� orakill ��� ������
  ( <body::oraKill>)
*/
procedure oraKill(
  sid integer
  , serial# integer
);

/* pproc: abortBatch
  ��������� ���������� ������ �������
  ( <body::abortBatch>)
*/
procedure abortBatch(
  batchId integer
  , sid integer
  , serial# integer
);

/* pfunc: getRegisteredSession
  ��������� id ������������������ ������.
  � ������, ���� ������ �� ���� ����������������,
  �� ������������ ������
  ( <body::getRegisteredSession>)
*/
function getRegisteredSession(
  sid integer
  , serial# integer
) return integer;

/* pproc: addAction
  ���������� ���������������� ��������
  ��� ������
  ( <body::addAction>)
*/
procedure addAction(
  registeredSessionId integer
  , dateTime date
  , actionCode varchar2
  , emailRecipient varchar2 := null
  , emailSubject varchar2 := null
);

/* pproc: deleteAction
  �������� ���������������� ��������
  ��� ������
  ( <body::deleteAction>)
*/
procedure deleteAction(
  registeredSessionId integer
  , dateTime date
  , actionCode varchar2
);

/* pproc: clearRegisteredSession
  ������ ����������� ������������������ ������
  ( <body::clearRegisteredSession>)
*/
procedure clearRegisteredSession;

/* pproc: completeAction
  �������� �������� ��� �����������
  ( <body::completeAction>)
*/
procedure completeAction(
  registeredSessionId integer
  , dateTime date
  , actionCode varchar2
);

/* pfunc: getDefaultTraceCopyPath
  ��������� ���������� ��� ����������� ������
  ��-���������
  ( <body::getDefaultTraceCopyPath>)
*/
function getDefaultTraceCopyPath
return varchar2;


end pkg_ProcessMonitorUtility;
/
