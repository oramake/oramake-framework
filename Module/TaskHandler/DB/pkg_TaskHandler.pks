create or replace package pkg_TaskHandler is
/* package: pkg_TaskHandler
  ������������ ����� ������ TaskHandler.

  SVN root: Oracle/Module/TaskHandler
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'TaskHandler';

/* const: Stop_Command
  �������, ���������� ��� ���������� ������ �����������.
*/
Stop_Command constant varchar2(50) := 'stop';



/* group: ������� */



/* group: �������� � ��������� ������� */

/* pfunc: toSecond
  ���������� ������������ ��������� � ��������
  ( <body::toSecond>).
*/
function toSecond(
  timeInterval interval day to second
)
return number;

/* pfunc: getTimeout
  ���������� �������� �������� ( � ��������)
  ( <body::getTimeout>).
*/
function getTimeout(
  baseTimeout number
  , limitTime timestamp with time zone
)
return number;

/* pfunc: getTime
  ��������� ������� ����� � ��������
  ( <body::getTime>).
*/
function getTime
return number;

/* pfunc: timeDiff
  ���������� ������������ ���������� �������� � ��������
  ( <body::timeDiff>).
*/
function timeDiff(
  newTime number
  , oldTime number
)
return number;

/* pfunc: nextTime
  ���������� ��������� �������� � ���������� �������
  ( <body::nextTime>).
*/
function nextTime(
  checkTime in out nocopy number
  , timeout number
)
return boolean;



/* group: �������������� � ��������� */

/* pproc: setAction
  ������������� ���������� � ����������� ��������
  ( <body::setAction>).
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2 := null
  , limitTime timestamp with time zone := null
);

/* pproc: setAction( LIMIT_SECOND)
  ������������� ���������� � ����������� ��������
  ( <body::setAction( LIMIT_SECOND)>).
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2 := null
  , limitSecond integer
);

/* pproc: initTask
  �������������� ������
  ( <body::initTask>).
*/
procedure initTask(
  moduleName varchar2
  , processName varchar2
);

/* pproc: cleanTask
  ��������� ������� ��� ���������� ������
  ( <body::cleanTask>).
*/
procedure cleanTask(
  riseException boolean := null
);



/* group: ������ � �������� */

/* pproc: createPipe
  ������� �����
  ( <body::createPipe>).
*/
procedure createPipe(
  pipeName varchar2
);

/* pproc: removePipe
  ������� �����
  ( <body::removePipe>).
*/
procedure removePipe(
  pipeName varchar2
);

/* pproc: sendMessage
  �������� ��������� � �����
  ( <body::sendMessage>).
*/
procedure sendMessage(
  pipeName varchar2
  , timeout integer := null
  , maxPipeSize integer := null
);

/* pfunc: sendMessage( STATUS)
  �������� ��������� � ����� � ���������� ���������
  ( <body::sendMessage( STATUS)>).
*/
function sendMessage(
  pipeName varchar2
  , timeout integer := null
  , maxPipeSize integer := null
)
return integer;

/* pfunc: receiveMessage
  ��������� ������� ��������� � ������
  ( <body::receiveMessage>).
*/
function receiveMessage(
  pipeName varchar2
  , timeout number := null
)
return boolean;



/* group: ��������/��������� ������ */

/* pfunc: sendCommand
  �������� ������� ��������� ������
  ( <body::sendCommand>).
*/
function sendCommand(
  sessionSid number
  , sessionSerial number
)
return boolean;

/* pproc: sendStopCommand
  �������� ������� ���������
  ( <body::sendStopCommand>).
*/
procedure sendStopCommand(
  sessionSid number := null
  , sessionSerial number := null
  , moduleName varchar2 := null
);

/* pfunc: getCommand
  �������� �������� ��������� �������
  ( <body::getCommand>).
*/
function getCommand(
  command out varchar2
  , timeout number := null
)
return boolean;

/* pproc: initHandler
  �������������� ����������
  ( <body::initHandler>).
*/
procedure initHandler(
  moduleName varchar2
  , processName varchar2
);

/* pproc: cleanHandler
  ��������� ������� ��� ���������� ������ �����������
  ( <body::cleanHandler>).
*/
procedure cleanHandler(
  riseException boolean := null
);

/* group: ���������� */


/* proc: setLock
 ������������� ������������ ���������� ��� ������������ ����������
 ( <body::setLock>).
*/
procedure setLock(
  lockName varchar2
  , waitSecond integer := null
);

end pkg_TaskHandler;
/
