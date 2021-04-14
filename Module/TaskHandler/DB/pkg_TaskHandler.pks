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
  ���������� ������������ ��������� � ��������.

  ���������:
  timeInterval                - �������� ��������� ��������

  ( <body::toSecond>)
*/
function toSecond(
  timeInterval interval day to second
)
return number;

/* pfunc: getTimeout
  ���������� �������� �������� ( � ��������) �� ������ �������� ��������
  � ���������� ������� ( � ������, ���� ��������� ����� ��������� ��
  �� ��������� �������� ��������, �� ������������ ������� �� ����������
  �������).

  ���������:
  baseTimeout               - ������� ������� ( � ��������)
  limitTime                 - ��������� �����

  ���������:
  ���� ��������� ����� ���������� ��� null, ������������ null.

  ( <body::getTimeout>)
*/
function getTimeout(
  baseTimeout number
  , limitTime timestamp with time zone
)
return number;

/* pfunc: getTime
  ��������� ������� ����� � �������� ( � ������������� ������� � ��������� ��
  ����� ����� �������).

  ���������: ������� ����� ������������ ����� ������������ �������� �������
  ( ��������� ���� - �������).

  ( <body::getTime>)
*/
function getTime
return number;

/* pfunc: timeDiff
  ���������� ������������ ���������� ������� � ��������.

  ���������:
  newTime                     - ��������� ������ �������
                                ( � �������� �� getTime())
  oldTime                     - ���������� ������ �������
                                ( � �������� �� getTime())

  ���������:
  � ������, ���� ����������� ������� getTime() ( �.�. newTime < oldTime)
  ������������ null.

  ( <body::timeDiff>)
*/
function timeDiff(
  newTime number
  , oldTime number
)
return number;

/* pfunc: nextTime
  � ������ ��������� �������� � ���������� ������� ������� ��������� ��������
  ������� ������� �� ������� � ���������� ������ ����� ���������� ����.

  ���������:
  checkTime                   - ������� ������ �������
                                ( � �������� �� ������� getTime())
  timeout                     - ������� �������� ( � ��������)

  ���������:
    - � ������ ������ �������� � getTime() ������������ ������, �� �������
      �������� ������� ����� ���� ������ ���������;
    - � ������, ���� checkTime is null ������������ ������;
    - � ������, ���� timeout is null ������������ ������;

  ( <body::nextTime>)
*/
function nextTime(
  checkTime in out nocopy number
  , timeout number
)
return boolean;



/* group: �������������� � ��������� */

/* pproc: setAction
  ������������� ���������� � ����������� ��������.

  ���������:
  action                      - �������� ��������
  actionInfo                  - ���������� � ����������� ��������
  limitTime                   - ����������� ���� ���������� ��������

  ( <body::setAction>)
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2 := null
  , limitTime timestamp with time zone := null
);

/* pproc: setAction( LIMIT_SECOND)
  ������������� ���������� � ����������� ��������.

  ���������:
  action                      - �������� ��������
  actionInfo                  - ���������� � ����������� ��������
  limitSecond                 - ������������ ����� ���������� ( � ��������)

  ( <body::setAction( LIMIT_SECOND)>)
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2 := null
  , limitSecond integer
);

/* pproc: initTask
  �������������� ������.

  ���������:
  moduleName                  - ��� ������
  processName                 - ��� ��������

  ( <body::initTask>)
*/
procedure initTask(
  moduleName varchar2
  , processName varchar2
);

/* pproc: cleanTask
  ��������� ������� ��� ���������� ������.

  ���������:
  riseException               - ����������� ������� ������ ���������� � ������
                                ������, ��-��������� ��� ������ �����������
                                � ������� ���������� �� �������������

  ( <body::cleanTask>)
*/
procedure cleanTask(
  riseException boolean := null
);



/* group: ������ � �������� */

/* pproc: createPipe
  ������� �����.

  ���������:
  pipeName                    - ��� ������

  ( <body::createPipe>)
*/
procedure createPipe(
  pipeName varchar2
);

/* pproc: removePipe
  ������� �����.

  ���������:
  pipeName                    - ��� ������

  ( <body::removePipe>)
*/
procedure removePipe(
  pipeName varchar2
);

/* pproc: sendMessage
  �������� ��������� � �����.

  ���������:
  pipeName                    - ��� ������
  timeout                     - ������� �������� ( � ��������, �� ���������
                                ����������� ���������, dbms_pipe.maxwait)
  maxPipeSize                 - ������������ ������ ������ ( �� ��������� 8192)

  ���������:
  ������������ ����� ������� ��� ������� <sendMessage( INTERNAL)> ��� ��������
  � �������� ���������� ��� ���������� ���������� ( isCheckResult = 1).

  ( <body::sendMessage>)
*/
procedure sendMessage(
  pipeName varchar2
  , timeout integer := null
  , maxPipeSize integer := null
);

/* pfunc: sendMessage( STATUS)
  �������� ��������� � ����� � ���������� ���������.

  ���������:
  pipeName                    - ��� ������
  timeout                     - ������� �������� ( � ��������, �� ���������
                                ����������� ���������, dbms_pipe.maxwait)
  maxPipeSize                 - ������������ ������ ������ ( �� ��������� 8192)

  �������:
  ��� �������� �������� ��������� ( ��. <sendMessage( INTERNAL)>).

  ���������:
  ������������ ����� ������� ��� ������� <sendMessage( INTERNAL)> ��� ��������
  ��� �������� ���������� ( isCheckResult = 0).

  ( <body::sendMessage( STATUS)>)
*/
function sendMessage(
  pipeName varchar2
  , timeout integer := null
  , maxPipeSize integer := null
)
return integer;

/* pfunc: receiveMessage
  ��������� ������� ��������� � ������ � ���������� ������, ���� ��� ��������.

  ���������:
  pipeName                    - ��� ������
  timeout                     - ����� �������� � �������� ( �� ��������� ���
                                ��������)

  ( <body::receiveMessage>)
*/
function receiveMessage(
  pipeName varchar2
  , timeout number := null
)
return boolean;



/* group: ��������/��������� ������ */

/* pfunc: sendCommand
  �������� ������� ��������� ������.

  ���������:
  sessionSid                  - v$session.sid ������ ����������
  sessionSerial               - v$session.serial# ������ ����������

  ������������ ��������: ������, ���� ������� ������� ���������� � ����, ����
  ������� �� ����� ���� ���������� ���� ������ �.�. ��� �� ����������.

  ( <body::sendCommand>)
*/
function sendCommand(
  sessionSid number
  , sessionSerial number
)
return boolean;

/* pproc: sendStopCommand
  �������� ������� ��������� ���������� �����������.

  ���������:
  sessionSid                  - v$session.sid ������ ����������
  sessionSerial               - v$session.serial# ������ ����������
  moduleName                  - ��� ������

  ���������:
  ���� ��������� �� ������� (null), �� ������� ��������� ���������� ����
  ���������� ������������.

  ( <body::sendStopCommand>)
*/
procedure sendStopCommand(
  sessionSid number := null
  , sessionSerial number := null
  , moduleName varchar2 := null
);

/* pfunc: getCommand
  �������� �������� ��������� ������� � ������� ���������� ��������.
  ���������� ������, ���� ������� ���� ��������.

  ���������:
  command                     - ���������� �������
  timeout                     - ����� �������� � �������� ( �� ��������� ���
                                ��������)

  ( <body::getCommand>)
*/
function getCommand(
  command out varchar2
  , timeout number := null
)
return boolean;

/* pfunc: isStopCommandReceived
  ��������� ��������� ������� ���������.

  ���������:
  timeout                     - ����� �������� � ��������
                                (�� ��������� ��� ��������)

  �������:
  ������, ���� ������� ��������� ���� ��������.

  ( <body::isStopCommandReceived>)
*/
function isStopCommandReceived(
  timeout number := null
)
return boolean;

/* pproc: initHandler
  �������������� ����������.

  ���������:
  moduleName                  - ��� ������
  processName                 - ��� ��������

  ( <body::initHandler>)
*/
procedure initHandler(
  moduleName varchar2
  , processName varchar2
);

/* pproc: cleanHandler
  ��������� ������� ��� ���������� ������ �����������.

  ���������:
  riseException               - ����������� ������� ������ ���������� � ������
                                ������, ��-��������� ��� ������ �����������
                                � ������� ���������� �� �������������


  ( <body::cleanHandler>)
*/
procedure cleanHandler(
  riseException boolean := null
);



/* group: ���������� */

/* pproc: setLock
  ������������� ������������ ���������� ��� ������������ ����������.

  ���������:
  lockName                    - ��� ����������
  waitSecond                  - ������� �������� � ������� ( null -
                                ���c������� ��������� �����)

  ( <body::setLock>)
*/
procedure setLock(
  lockName varchar2
  , waitSecond integer := null
);

end pkg_TaskHandler;
/
