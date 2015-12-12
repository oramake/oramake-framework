create or replace package pkg_TaskProcessorTest is
/* package: pkg_TaskProcessorTest
  ����� ��� ������������ ������.

  SVN root: Oracle/Module/TaskProcessor
*/



/* group: ������� */

/* pfunc: createProcessFileTask
  ������� ������� �� ��������� ����� ( ��� ���������� commit).

  ���������:
  moduleName                  - �������� ������, � �������� ��������� �������
  processName                 - �������� ��������, � �������� ��������� �������
  fileData                    - ��������� ������ �����
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id �������.

  ( <body::createProcessFileTask>)
*/
function createProcessFileTask(
  moduleName varchar2
  , processName varchar2
  , fileData clob
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
