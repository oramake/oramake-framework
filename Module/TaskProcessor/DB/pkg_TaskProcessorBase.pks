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

end pkg_TaskProcessorBase;
/
