create or replace package pkg_TaskProcessorTest is
/* package: pkg_TaskProcessorTest
  ����� ��� ������������ ������.

  SVN root: Oracle/Module/TaskProcessor
*/



/* group: ������� */

/* pproc: stopTask
  ������� ������� � ����������.

  ���������:
  moduleName                  - ��� ����������� ������
  processName                 - ��� ����������� ��������, ��������������� ����
                                ��� �������

  ���������:
  - ����������� � ���������� ����������;

  ( <body::stopTask>)
*/
procedure stopTask(
  moduleName varchar2 := null
  , processName varchar2 := null
);

/* pproc: waitForTask
  �������� ��������� �������.

  taskId                      - ������������ �������
  maxCount                    - �������� �������� � ���
                                ( �� ��������� 200)

  ( <body::waitForTask>)
*/
procedure waitForTask(
  taskId                      integer
, maxCount                    integer := null
);

/* pfunc: createProcessFileTask
  ������� ������� �� ��������� ����� ( ��� ���������� commit).

  ���������:
  moduleName                  - �������� ������, � �������� ��������� �������
  processName                 - �������� ��������, � �������� ��������� �������
  fileData                    - ��������� ������ �����
  fileName                    - ��� �����
                                (�� ��������� "�������� ����.csv")
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id �������.

  ( <body::createProcessFileTask>)
*/
function createProcessFileTask(
  moduleName varchar2
  , processName varchar2
  , fileData clob
  , fileName varchar2 := null
  , operatorId integer := null
)
return integer;

/* pproc: executeLoadFileTask
  ������ ������� �� �������� ����� � ������� ��� ����������.

  ���������:
  moduleName                  - �������� ������, � �������� ��������� �������
  processName                 - �������� ��������, � �������� ��������� �������
  fileData                    - ��������� ������ �����

  ( <body::executeLoadFileTask>)
*/
procedure executeLoadFileTask(
  moduleName varchar2
  , processName varchar2
  , fileData clob
);

/* pproc: userApiTest
  ������������ API ��� ����������������� ����������.

  ( <body::userApiTest>)
*/
procedure userApiTest;

end pkg_TaskProcessorTest;
/
