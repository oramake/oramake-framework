create or replace package pkg_TaskProcessor is
/* package: pkg_TaskProcessor
  ������������ ����� ������ TaskProcessor.

  SVN root: Oracle/Module/TaskProcessor
*/



/* group: ��������� */



/* group: ��������� ���������� */

/* const: True_ResultCode
  ��� ���������� "������������� ���������".
  ������� ���� ������� ���������.
*/
True_ResultCode constant varchar2(10) :=
  pkg_TaskProcessorBase.True_ResultCode
;

/* const: False_ResultCode
  ��� ���������� "������������� ���������".
  ������� ���� ��������� ��� ������, �� ��������� �� ��� ���������.
*/
False_ResultCode constant varchar2(10) :=
  pkg_TaskProcessorBase.False_ResultCode
;

/* const: Error_ResultCode
  ��� ���������� "������".
  ��� ���������� ������� �������� ������.
*/
Error_ResultCode constant varchar2(10) :=
  pkg_TaskProcessorBase.Error_ResultCode
;

/* const: Stop_ResultCode
  ��� ���������� "�����������".
  ���������� ������� ���� �����������.
*/
Stop_ResultCode constant varchar2(10) :=
  pkg_TaskProcessorBase.Stop_ResultCode
;

/* const: Abort_ResultCode
  ��� ���������� "��������".
  ���������� ������� ���� ��������.
*/
Abort_ResultCode constant varchar2(10) :=
  pkg_TaskProcessorBase.Abort_ResultCode
;



/* group: ������� */



/* group: ���� ������� */

/* pfunc: mergeTaskType
  ������� ��� ��������� ��� �������.

  ���������:
  moduleName                  - ��� ����������� ������
  processName                 - ��� ����������� ��������, ��������������� ����
                                ��� �������
  taskTypeNameEng             - �������� ���� ������� ( ���.)
  taskTypeNameRus             - �������� ���� ������� ( ���.)
  execCommand                 - �������, ���������� ��� ��������� ( ����������
                                PL/SQL �����, �������� � ��������������
                                ���������������� ����������)
  fileNamePattern             - ����� ����� ����� ( ��� like, ������������
                                ������ "\") � ������� ��� ��������� �������� (
                                ���� �������, �� ��� ���������� ������� �����
                                ��������� ���� � ���������� ������ �����
                                ���������, ����� ���� ��� ������� ��
                                ������������)
  accessRoleShortName         - �������� ���� �� ������ AccessOperator,
                                ����������� ��� ������� � �������� ����� ����
  taskKeepDay                 - ����� �������� ������� � ����, �� ���������
                                �������� �������������� �������������� �������
                                ������������� ��������� ( �� ���������
                                ������������)
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  �������:
  - ���� �������� ��������� ( 0 ��� ���������, 1 ������ ��������� ��� ���������)

  ���������:
  - ������ ��� ������� ������ ���� �������� �� ���������� ����������
    moduleName, processName;

  ( <body::mergeTaskType>)
*/
function mergeTaskType(
  moduleName varchar2
  , processName varchar2
  , taskTypeNameEng varchar2
  , taskTypeNameRus varchar2
  , execCommand varchar2
  , fileNamePattern varchar2 := null
  , accessRoleShortName varchar2 := null
  , taskKeepDay integer := null
  , operatorId integer := null
)
return integer;

/* pfunc: getTaskType
  ������� ������ ����� ����� ��� ���������� ������.

  ���������:
  moduleName                  - ������������ ������
  operatorId                  - Id ��������� ��� ���������� ����������� ���
                                ����� �����
                                ( �� ��������� ��� �����������)

  �������:
  task_type_id                - ������������� ���� ������
  process_name                - ������������ ����������� ��������
  task_type_name              - ������������ ���� ������

  ( ������������ ������ ������������� �� ���� task_type_id)

  ���������:
  - � ������ �������� Id ��������� � ��������� operatorId �� ������
    ����������� ���� �����, � ������� � ������� <tp_task_type> ��������� ����
    access_role_short_name � �������� � ���� ���� ���� ���������� ���������;

  ( <body::getTaskType>)
*/
function getTaskType(
  moduleName varchar2
  , operatorId integer := null
)
return sys_refcursor;

/* pfunc: getTaskTypeId
  ���������� Id ���� ������� ��� ���������� ��������.

  ���������:
  moduleName                  - ��� ����������� ������
  processName                 - ��� ����������� ��������, ��������������� ����
                                ��� �������
  isNotFoundRaised            - ������������ �� ���������� � ������
                                ���������� ����������� ���� �������
                                ( 1 �� ( �� ���������), 0 ���)

  �������:
  Id ���� ������� ���� null ���� ������ �� ������� � �������� ���������
  isNotFoundRaised ����� 0.

  ���������:
  - ������� ������������� ��� ������������� � ���������� �������;

  ( <body::getTaskTypeId>)
*/
function getTaskTypeId(
  moduleName varchar2
  , processName varchar2
  , isNotFoundRaised integer := null
)
return integer;



/* group: ������� */

/* pfunc: createTask
  ��������� �������.

  ���������:
  moduleName                  - ��� ����������� ������
  processName                 - ��� ����������� ��������
  startDate                   - ���� ������� ( �� ��������� �� ��������� ��
                                ������ ������ <startTask>)
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  �������:
  - Id ����������� ������

  ���������:
  - � ����������� ������� <tp_task_type> ������ ���� �������������� ��������
    ��������������� ��� ������� ( ������������ �� ����� ������ � ��������);

  ( <body::createTask>)
*/
function createTask(
  moduleName varchar2
  , processName varchar2
  , startDate date := null
  , operatorId integer := null
)
return integer;

/* pfunc: createTask( FILE)
  ��������� ������� ��� ��������� �����.

  ���������:
  moduleName                  - ��� ����������� ������
  processName                 - ��� ����������� ��������
  fileName                    - ��� ����� ��� ���������
  mimeTypeCode                - MIME-��� �����
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  �������:
  - Id ����������� ������

  ���������:
  - ����� ���������� ������� � ���� file_data ������� <tp_file> ( ��� ������
    �� ��������� task_id, ������ ������������� �������� ��������) ������
    ���� ��������� ������ �����, ����� ���� ������� ������� <setFileLoaded>;
  - � ����������� ������� <tp_task_type> ������ ���� �������������� ��������
    �������������� ��� ������� ( ������������ �� ����� ������ � ��������);

  ( <body::createTask( FILE)>)
*/
function createTask(
  moduleName varchar2
  , processName varchar2
  , fileName varchar2
  , mimeTypeCode varchar2
  , operatorId integer := null
)
return integer;

/* pproc: setFileLoaded
  ������������� ��������������� ��������� ����� ����� ���������� ��������
  ������ � ������ ������� � ������� �� ����������.
  ������� ������ ���������� ����� ���������� �������� ������ ����� � ����
  file_data ������� <tp_file> ( ��� ���� ������� ������ ���� ��������������
  ������� �������� createTask( FILE)).

  ���������:
  taskId                      - Id �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  ( <body::setFileLoaded>)
*/
procedure setFileLoaded(
  taskId integer
  , operatorId integer := null
);

/* pproc: updateTaskParameter
  ���������� ��� ��������� ���������� ���������� �������.
  ��������� �������������� �������, �������� ����������� ��� ������� ��
  ���������� ����������.

  ���������:
  taskId                      - Id �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  ���������:
  - ������� ������ ���������� � ������� "�����������", ����� �������������
    ����������;

  ( <body::updateTaskParameter>)
*/
procedure updateTaskParameter(
  taskId integer
  , operatorId integer := null
);

/* pproc: deleteTask
  ������� �������.

  ���������:
  taskId                      - Id �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  ���������:
  - ������� ������ ���������� � ������� "�����������", ����� �������������
    ����������;

  ( <body::deleteTask>)
*/
procedure deleteTask(
  taskId integer
  , operatorId integer := null
);

/* pfunc: findFile
  ����� ��������� ������.

  ���������:
  moduleName                  - �������� ������, � �������� ��������� �������
  processName                 - �������� ��������, � �������� ��������� �������
  taskId                      - Id �������
  fileName                    - ��� �����
                                ( ��������� �� like ��� ����� ��������)
  fromDate                    - ��������� ���� ���������� �����
                                ( � ��������� �� ���, ������������)
  toDate                      - �������� ���� ���������� �����
                                ( � ��������� �� ���, ������������)
  maxRowCount                 - ������������ ����� ������������ ������� �������
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� ( ������):
  task_id                     - Id �������
  task_type_id                - Id ���� �������
  task_type_name              - �������� ���� �������
  file_status_code            - ��� ��������� �����
  file_status_name            - �������� ��������� �����
  file_name                   - ��� �����
  extension                   - ���������� ����� ( ���������� �� ����� �����)
  mime_type_code              - MIME-��� �����
  file_loaded_date            - ���� �������� ������ �����
  task_start_date             - ���� ������� ��������� �����
  result_code                 - ��� ���������� ���������
  result_name                 - �������� ���������� ���������
  exec_result                 - �������� ��������� ���������
  error_message               - ��������� �� ������ ��� ���������
  file_date_ins               - ���� ���������� �����
  file_operator_id            - Id ���������, ����������� ����
  file_operator_name          - ��������, ���������� ����

  ���������:
  - ������������ ������ ������������� �� ���� task_id � �������� �������;

  ( <body::findFile>)
*/
function findFile(
  moduleName varchar2 := null
  , processName varchar2 := null
  , taskId integer := null
  , fileName varchar2 := null
  , fromDate date := null
  , toDate date := null
  , maxRowCount integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: ���������� ��������� */

/* pproc: startTask
  ������ ������� � ������� �� ����������.

  ���������:
  taskId                      - Id �������
  startDate                   - ���� ������� ( �� ��������� ����������)
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  ���������:
  - ������� ������ ���������� � ������� "�����������", ����� �������������
    ����������;

  ( <body::startTask>)
*/
procedure startTask(
  taskId integer
  , startDate date := null
  , operatorId integer := null
);

/* pproc: stopTask
  ������������� ���������� �������.

  ���������:
  taskId                      - Id �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)
  ���������:
  - ������� ������ ���������� � ������� "� �������", ����� �������������
    ����������;

  ( <body::stopTask>)
*/
procedure stopTask(
  taskId integer
  , operatorId integer := null
);



/* group: ��� ���������� ������� */

/* pproc: logMessage
  ���������� � ��� ���������, ����������� � �������� ������������ �������.

  ���������:
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������
  lineNumber                  - ����� ������ ��������������� �����, � �������
                                ��������� ��������� ( ��������� ������ �������
                                � 1, 0 ���� ��������� �� ��������� � ������
                                ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������� ������������� ��� ����������� �������� ���������� ��������
    �������, � ������ ������ ��� ���������� ������������ ������� �����
    ��������� ����������;

  ( <body::logMessage>)
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logError
  ���������� � ��� ��������� �� ������, ����������� � �������� ������������
  �������.

  ���������:
  messageText                 - ����� ���������
  lineNumber                  - ����� ������ ��������������� �����, � �������
                                ��������� ��������� ( ��������� ������ �������
                                � 1, 0 ���� ��������� �� ��������� � ������
                                ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������� ������������� ��� ����������� �������� ���������� ��������
    �������, � ������ ������ ��� ���������� ������������ ������� �����
    ��������� ����������;

  ( <body::logError>)
*/
procedure logError(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logWarning
  ���������� � ��� ��������������� ���������, ����������� � ��������
  ������������ �������.

  ���������:
  messageText                 - ����� ���������
  lineNumber                  - ����� ������ ��������������� �����, � �������
                                ��������� ��������� ( ��������� ������ �������
                                � 1, 0 ���� ��������� �� ��������� � ������
                                ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������� ������������� ��� ����������� �������� ���������� ��������
    �������, � ������ ������ ��� ���������� ������������ ������� �����
    ��������� ����������;

  ( <body::logWarning>)
*/
procedure logWarning(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logInfo
  ���������� � ��� �������������� ���������, ����������� � ��������
  ������������ �������.

  ���������:
  messageText                 - ����� ���������
  lineNumber                  - ����� ������ ��������������� �����, � �������
                                ��������� ��������� ( ��������� ������ �������
                                � 1, 0 ���� ��������� �� ��������� � ������
                                ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������� ������������� ��� ����������� �������� ���������� ��������
    �������, � ������ ������ ��� ���������� ������������ ������� �����
    ��������� ����������;

  ( <body::logInfo>)
*/
procedure logInfo(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logDebug
  ���������� � ��� ���������� ���������, ����������� � �������� ������������
  �������.

  ���������:
  messageText                 - ����� ���������
  lineNumber                  - ����� ������ ��������������� �����, � �������
                                ��������� ��������� ( ��������� ������ �������
                                � 1, 0 ���� ��������� �� ��������� � ������
                                ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������� ������������� ��� ����������� �������� ���������� ��������
    �������, � ������ ������ ��� ���������� ������������ ������� �����
    ��������� ����������;

  ( <body::logDebug>)
*/
procedure logDebug(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logTrace
  ���������� � ��� �������������� ���������, ����������� � ��������
  ������������ �������.

  ���������:
  messageText                 - ����� ���������
  lineNumber                  - ����� ������ ��������������� �����, � �������
                                ��������� ��������� ( ��������� ������ �������
                                � 1, 0 ���� ��������� �� ��������� � ������
                                ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������� ������������� ��� ����������� �������� ���������� ��������
    �������, � ������ ������ ��� ���������� ������������ ������� �����
    ��������� ����������;

  ( <body::logTrace>)
*/
procedure logTrace(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pfunc: findTaskLog
  ����� ���� ���������� �������.

  ���������:
  taskLogId                   - Id ������ ����
  taskId                      - Id �������
  startNumber                 - ����� ������� ������� ( ������� � 1)
  lineNumber                  - ����� ������ ��������������� ����� ( ������� 1
                                ��� 0 ��� ���������, �� ��������� �� �������
                                �����)
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������
                                ( ����� �� like ��� ����� ��������)
  startTaskLogId              - Id ������ ����, � ������� ����� ������ �������
  maxRowCount                 - ������������ ����� ������������ ������� �������
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� ( ������):
  task_log_id                 - Id ������ ����
  task_id                     - Id �������
  start_number                - ����� ������� ������� ( ������� � 1)
  line_number                 - ����� ������ ��������������� ����� ( ������� 1
                                ��� 0 ��� ���������, �� ��������� �� �������
                                �����)
  level_code                  - ��� ������ ���������
  level_name                  - �������� ������ ���������
  message_text                - ����� ���������
  date_ins                    - ���� ���������� ������

  ���������:
  - ������������ ������ ������������� �� ���� task_log_id;

  ( <body::findTaskLog>)
*/
function findTaskLog(
  taskLogId integer := null
  , taskId integer := null
  , startNumber integer := null
  , lineNumber integer := null
  , levelCode varchar2 := null
  , messageText varchar2 := null
  , startTaskLogId integer := null
  , maxRowCount integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: ����������� */

/* pfunc: getLevel
  ���������� ������ ������� ��������� ����.

  ������� ( ������):
  level_code                  - ��� ������ ���������
  level_name                  - �������� ������ ���������

  ���������:
  - ������������ ������ ������������� �� ���� level_code;

  ( <body::getLevel>)
*/
function getLevel
return sys_refcursor;

/* pfunc: getResult
  ���������� ��������� ���������� ���������� �������.

  ������� ( ������):
  result_code             - ��� ���������� ����������
  result_name             - �������� ���������� ����������

  ���������:
  - ������������ ������ ������������� �� result_code;

  ( <body::getResult>)
*/
function getResult
return sys_refcursor;

end pkg_TaskProcessor;
/
