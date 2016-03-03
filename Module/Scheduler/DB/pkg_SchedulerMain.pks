create or replace package pkg_SchedulerMain is
/* package: pkg_SchedulerMain
  �������� ����� ������ Scheduler.

  SVN root: Oracle/Module/Scheduler
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'Scheduler';

/* const: Module_SvnRoot
  ���� � ��������� �������� ������ � Subversion.
*/
Module_SvnRoot constant varchar2(100) := 'Oracle/Module/Scheduler';

/* const: Batch_OptionObjTypeSName
  �������� �������� ���� ������� "�������� �������" � ������ Option ( ����
  object_type_short_name ������� opt_object_type).
  ������ Option ����������� ��� �������� ���������� �������� �������, ��� ����
  � �������� ��������� ����� ������� ( ���� object_short_name �������������
  v_opt_option_value) ����������� �������� ��� ��������� �������
  ( batch_short_name ������� <sch_batch>).
*/
Batch_OptionObjTypeSName constant varchar2(50) := 'batch';



/* group: ����������� ��������� */

/* const: LocalRoleSuffix_OptionSName
  �������� ������������ �����
  "������� ��� �����, � ������� ������� �������� ����� �� ��� �������� �������,
  ��������� � �������� ������������� ������ Scheduler".

  ��� �������� ���� ������� �����������
  ����:

  AdminAllBatch<LocalRoleSuffix>    - ������ �����
  ExecuteAllBatch<LocalRoleSuffix>  - ���������� �������� �������
  ShowAllBatch<LocalRoleSuffix>     - �������� ������

  ��� <LocalRoleSuffix> ��� �������� �����.

  ����� ������ �� ��� �������� �������, ����������� � ������ Scheduler, �
  ������� ������������ �������� �����. ��� ���� ���������������, ��� �
  ��������� �� ������ ����� ����� ��������� ��������, ������� �������� ���
  ��������� ������ Scheduler.

  ������:
  � �� DbNameP ����� ����� �������� "DbName", � ���������� ����� ��
  ��� �������� �������, ��������� � �� DbNameP, ����� ������ � �������
  ����� "AdminAllBatchDbName", "ExecuteAllBatchDbName",
  "ShowAllBatchDbName".
*/
LocalRoleSuffix_OptionSName constant varchar2(50) := 'LocalRoleSuffix';



/* group: ������� */

/* pfunc: getModuleId
  ���������� Id ������ Scheduler � ������� �� ( � ������������ �����
  ������������� ��������).

  �������:
  Id ������ ��� ������ Scheduler � ������� mod_module ������ ModuleInfo.

  ( <body::getModuleId>)
*/
function getModuleId
return integer;

/* pproc: getBatch( batchId)
  ���������� ������ ��������� �������.

  ���������:
  dataRec                     - ������ ��������� �������
                                ( �������)
  batchId                     - Id ��������� �������

  ( <body::getBatch( batchId)>)
*/
procedure getBatch(
  dataRec out nocopy sch_batch%rowtype
  , batchId integer
);

/* pproc: getBatch( batchShortName)
  ���������� ������ ��������� �������.

  ���������:
  dataRec                     - ������ ��������� �������
                                ( �������)
  batchShortName              - �������� �������� ��������� �������

  ( <body::getBatch( batchShortName)>)
*/
procedure getBatch(
  dataRec out nocopy sch_batch%rowtype
  , batchShortName varchar2
);

/* pfunc: getLastRootLogId
  ���������� Id ��������� ���� ���������� ������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������

  �������:
  Id ������ ��� null, ���� ��� �����������.

  ( <body::getLastRootLogId>)
*/
function getLastRootLogId(
  batchId integer
)
return integer;

/* pfunc: getBatchLogInfo
  ���������� ���������� �� ���� ���������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
                                ( �� ������������, ���� ������ rootLogId)
  rootLogId                   - Id �������� ������ ����
                                ( �� ��������� ��� ���������� �������
                                  ���������� ��������� �������)

  ���������:
  - ������ ���� ����� �������� batchId ��� rootLogId, ����� �������������
    ����������;

  ( <body::getBatchLogInfo>)
*/
function getBatchLogInfo(
  batchId integer := null
  , rootLogId integer := null
)
return sch_batch_log_info_t;

end pkg_SchedulerMain;
/
