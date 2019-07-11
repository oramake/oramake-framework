create or replace package pkg_TaskProcessorBase is
/* package: pkg_TaskProcessorBase
  ��������� ������ TaskProcessor.

  SVN root: Oracle/Module/TaskProcessor
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'TaskProcessor';

/* const: Module_SvnRoot
  ���� � ��������� �������� ������ � Subversion.
*/
Module_SvnRoot constant varchar2(100) := 'Oracle/Module/TaskProcessor';

/* group: ���� */

/* const: Administrator_RoleName
  ��� ����, ������ ������ ����� �� ������ � �������.
*/
Administrator_RoleName constant varchar2(30) := 'TaskProcessorAdministrator';



/* group: ��������� ������ */

/* const: MaxOpTpTaskExec_OptionSName
  �������� �������� ���������
  "������������ ����� ������������ ����������� ������� ������ ���� �� ������ ��������� ( �� ��������� ��� �����������)"
*/
MaxOpTpTaskExec_OptionSName constant varchar2(50) :=
  'MaxOperatorTypeTaskExecCount'
;



/* group: ��������� ���������� */

/* const: True_ResultCode
  ��� ���������� "������������� ���������".
  ������� ���� ������� ���������.
*/
True_ResultCode constant varchar2(10) := 'OK';

/* const: False_ResultCode
  ��� ���������� "������������� ���������".
  ������� ���� ��������� ��� ������, �� ��������� �� ��� ���������.
*/
False_ResultCode constant varchar2(10) := 'FL';

/* const: Error_ResultCode
  ��� ���������� "������".
  ��� ���������� ������� �������� ������.
*/
Error_ResultCode constant varchar2(10) := 'ERR';

/* const: Stop_ResultCode
  ��� ���������� "�����������".
  ���������� ������� ���� �����������.
*/
Stop_ResultCode constant varchar2(10) := 'STP';

/* const: Abort_ResultCode
  ��� ���������� "��������".
  ���������� ������� ���� ��������.
*/
Abort_ResultCode constant varchar2(10) := 'ABR';



/* group: ��������� ������� */

/* const: Idle_TaskStatusCode
  ��� ��������� ������� "�����������".
  ������� ������� ������������� ������������.
*/
Idle_TaskStatusCode constant varchar2(10) := 'I';

/* const: Queued_TaskStatusCode
  ��� ��������� ������� "� �������".
  ������� � ������� � �������� �������.
*/
Queued_TaskStatusCode constant varchar2(10) := 'Q';

/* const: Running_TaskStatusCode
  ��� ��������� ������� "�����������".
  ������� �����������.
*/
Running_TaskStatusCode constant varchar2(10) := 'R';



/* group: ��������� ����� */

/* const: Loading_FileStatusCode
  ��� ��������� ����� "�������� ������...".
*/
Loading_FileStatusCode constant varchar2(10) := 'LOADING';

/* const: Loaded_FileStatusCode
  ��� ��������� ����� "������ ��������� ( �� ����������)".
*/
Loaded_FileStatusCode constant varchar2(10) := 'LOADED';

/* const: Processing_FileStatusCode
  ��� ��������� ����� "��������� ������...".
*/
Processing_FileStatusCode constant varchar2(10) := 'PROCESSING';

/* const: Processed_FileStatusCode
  ��� ��������� ����� "������ ����������".
*/
Processed_FileStatusCode constant varchar2(10) := 'PROCESSED';



/* group: ���� ��������� ���������� � ���� */

/* const: Task_CtxTpSName
  ��� ��������� ���������� "�������".
  �������� ��� ��������, � context_value_id ����������� Id ������� (��������
  ���� task_id �� ������� tp_task), � message_label ����������� ��� ��������
  (��. <����� ��������� �� ��������� � ��������>).
*/
Task_CtxTpSName constant varchar2(10) := 'TASK';



/* group: ����� ��������� �� ��������� � ��������
  �������� ������������ ��� ���������� ���� message_label ���� � ������
  �������� ��������� <Task_CtxTpSName>.
*/

/* const: Create_TaskMsgLabel
  ����� ��������� ��� �������� "��������".
*/
Create_TaskMsgLabel constant varchar2(50) := 'CREATE';

/* const: Exec_TaskMsgLabel
  ����� ��������� ��� �������� "����������".
*/
Exec_TaskMsgLabel constant varchar2(50) := 'EXEC';

/* const: Start_TaskMsgLabel
  ����� ��������� ��� �������� "���������� �� ����������".
*/
Start_TaskMsgLabel constant varchar2(50) := 'START';

/* const: Stop_TaskMsgLabel
  ����� ��������� ��� �������� "������ � ����������".
*/
Stop_TaskMsgLabel constant varchar2(50) := 'STOP';

/* const: Update_TaskMsgLabel
  ����� ��������� ��� �������� "���������� ����������".
*/
Update_TaskMsgLabel constant varchar2(50) := 'UPDATE';

end pkg_TaskProcessorBase;
/
