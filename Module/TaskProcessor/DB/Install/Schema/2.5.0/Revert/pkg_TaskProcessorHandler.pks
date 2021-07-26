create or replace package pkg_TaskProcessorHandler is
/* package: pkg_TaskProcessorHandler
  ������� ��������� ������ TaskProcessor.

  SVN root: Oracle/Module/TaskProcessor
*/



/* group: ������� */

/* pfunc: getExecCommandText
  ������� ���������� PL/SQL ��� ��� ����������

  ���������:
  execCommand                 - ������� ���������� ������
  isProcessFile               - ������� �������� �����
  isOnlyParse                 - ������� �������� ������������ ���� �������,
                                ��� ���� ��� �� �����������
                                ( �� ��������� false)

  ( <body::getExecCommandText>)
*/
function getExecCommandText(
  execCommand                 varchar2
, isProcessFile               boolean
, isOnlyParse                 boolean := null
)
return varchar2;

/* pproc: checkExecCommandParsed
  ��������� �������� ������������ ������������ PL/SQL ����

  ���������:
  execCommand                 - ����� ���������� �������
  isProcessFile               - ������� �������� �����

  ( <body::checkExecCommandParsed>)
*/
procedure checkExecCommandParsed(
  execCommand                 varchar2
, isProcessFile               boolean
);

/* pfunc: taskHandler
  ���������� �������.
  ��������� �������, ����������� � �������, � ����� ��������� � ����������
  ��������� �������, ���������� ������� ���� ��������.

  ������� ����������� � ������� ������������� ������ � PL/SQL-����� �������,
  ��������������� ���� ������� ( �� ���� exec_command ������� <tp_task_type>).

  ����������, ��������� ���������� �������:
  taskId                      - Id �������
  manageOperatorId            - Id ���������, ������������ ������� �� ����������
  nextStartDate               - ���� ���������� ������� ( �����������, ��
                                �� ��������� null)
  startNumber                 - ���������� ����� �������, ������� � 1
                                ( ������������� ������������� ��� ������
                                ������� ������� �������)
  startDate                   - ���� �������
  fileName                    - ��� ��������������� �����
                                ( ������ ��� ������� ��������� �����)
  fileData                    - ������ ��������������� ����� ( ��� CLOB)
                                ( ������ ��� ������� ��������� �����)
  resultCode                  - ��� ���������� ( �����������, �� ���������
                                <pkg_TaskProcessorBase.True_ResultCode>)
  execResult                  - ��������� ���������� ( �����������, �� ���������
                                null)
  errorCode                   - ��� ������ ( �����������, �� ��������� null)
  errorMessage                - ����� ������ ( �����������, �� ��������� null)

  ���� ������� ���� ��������� ��� ����������, �� ����� ���������� �������
  �������� ����������, ����������� �����������, ����������� � ���������������
  ����� ������� <tp_task> � ����������� commit.

  � ������, ���� ����� ���������� ������� ���������� nextStartDate ����� ��
  null ��������, ������� ����� �������� � ������� �� ����������, � ���������
  ������ ��� ����������� � ��������������.

  � ������, ���� ��� ���������� ������� �������� ����������, �����������
  rollback, ��������������� ��� ����������
  <pkg_TaskProcessorBase.Error_ResultCode>, ����������� ��� � ��������� ��
  ������ � ������� ����������� � �������������� ( � ������ ���������� ��-��
  ����������� �������� ������� �������� �� ��������� ����������, ��. ���������
  ����).

  � ������, ���� ���������� �������, ��������� �������� ���� ��������,
  ��������������� ��� ���������� <pkg_TaskProcessorBase.Abort_ResultCode> �
  ������� ����������� � ��������������.

  ���������:
  isFinishAfterProcess        - ���� ���������� ��������� ����� ����������
                                ( � ����� �����������) ������ ������� ����
                                ���������� ������ ������ ������� ������ ����
                                ( 1 ���������, 0 �� ��������� ( �� ���������))
  forceTaskTypeIdList         - ������ ��������������� ����� �������
                                �� ���������� ����� ";"
                                ( �� ��������� ��� �����������)
  ignoreTaskTypeIdList        - ������ ��������������� ����� �������,
                                ������� �� ����� �����������, ����� ";"
                                ( �� ��������� ��� �����������)

  �������:
  - ����� ������������ �������

  ���������:
  - �������� isFinishAfterProcess ������������ ��� ������� �������� �
    ����������� ��������� ���������� ���������� �������� � ������
    ����������� ( ��. <������>);
  - � ������, ���� ��� ���������� ������� ��������� ���������� ��-��
    ����������� ��������, ��������
    "ORA-04061: existing state of package <packageName>  has been invalidated",
    �� ������� �������� �� ��������� ����������, � ������� ��������� �������
    ����������� � �����������, �.�. ��������� ���������� ������� � �����
    ������ ����� ����������� �������;
  - �������������� ���������� ������ �� ���������� forceTaskTypeIdList
    ��� ignoreTaskTypeIdList

  ( <body::taskHandler>)
*/
function taskHandler(
  isFinishAfterProcess integer := null
, forceTaskTypeIdList varchar2 := null
, ignoreTaskTypeIdList varchar2 := null
)
return integer;

end pkg_TaskProcessorHandler;
/