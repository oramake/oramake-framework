create or replace package pkg_Scheduler is
/* package: pkg_Scheduler
  ������������ ����� ������ Scheduler.
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'Scheduler';



/* group: ���������� ���������� */

/* const: True_ResultId
  Id ���������� ���������� "������������� ���������".
*/
True_ResultId constant integer := 1;

/* const: False_ResultId
  Id ���������� ���������� "������������� ���������".
*/
False_ResultId constant integer := 2;

/* const: Error_ResultId
  Id ���������� ���������� "������".
*/
Error_ResultId constant integer := 3;

/* const: RunError_ResultId
  Id ���������� ���������� "������ ��� �������".
*/
RunError_ResultId constant integer := 4;

/* const: Skip_ResultId
  Id ���������� ���������� "�������� �� �������".
*/
Skip_ResultId constant integer := 5;

/* const: Retryattempt_ResultId
  Id ���������� ���������� "��������� �������".
*/
RetryAttempt_ResultId constant integer := 6;



/* group: ���������� �� �������� ������� */

/* const: Admin_PrivilegeCode
  ��� ���������� "��������� ���� �����".
*/
Admin_PrivilegeCode constant varchar2(10) := 'ADMIN';

/* const: Exec_PrivilegeCode
  ��� ���������� "���������� ( ���������, �����������, ������, ����������)".
*/
Exec_PrivilegeCode constant varchar2(10) := 'EXEC';

/* const: Read_PrivilegeCode
  ��� ���������� "�������� ������".
*/
Read_PrivilegeCode constant varchar2(10) := 'READ';

/* const: Write_PrivilegeCode
  ��� ���������� "��������� ��������� ������� ( ����� ��������� ����������)".
*/
Write_PrivilegeCode constant varchar2(10) := 'WRITE';

/* const: WriteOption_PrivilegeCode
  ��� ���������� "��������� ���������� ��������� �������".
*/
WriteOption_PrivilegeCode constant varchar2(10) := 'WRITE_OPT';



/* group: ���� ��������� */

/* const: Bmanage_MessageTypeCode
  ��� ���� ��������� "���������� �������".
*/
Bmanage_MessageTypeCode constant varchar2(10) := 'BMANAGE';

/* const: Bstart_MessageTypeCode
  ��� ���� ��������� "����� ������".
*/
Bstart_MessageTypeCode constant varchar2(10) := 'BSTART';

/* const: Bfinish_MessageTypeCode
  ��� ���� ��������� "���������� ������".
*/
Bfinish_MessageTypeCode constant varchar2(10) := 'BFINISH';

/* const: Jstart_MessageTypeCode
  ��� ���� ��������� "����� �������".
*/
Jstart_MessageTypeCode constant varchar2(10) := 'JSTART';

/* const: Jfinish_MessageTypeCode
  ��� ���� ��������� "���������� �������".
*/
Jfinish_MessageTypeCode constant varchar2(10) := 'JFINISH';

/* const: Error_MessageTypeCode
  ��� ���� ��������� "������".
*/
Error_MessageTypeCode constant varchar2(10) := 'ERROR';

/* const: Warning_MessageTypeCode
  ��� ���� ��������� "��������������".
*/
Warning_MessageTypeCode constant varchar2(10) := 'WARNING';

/* const: Info_MessageTypeCode
  ��� ���� ��������� "����������".
*/
Info_MessageTypeCode constant varchar2(10) := 'INFO';

/* const: Debug_MessageTypeCode
  ��� ���� ��������� "�������".
*/
Debug_MessageTypeCode constant varchar2(10) := 'DEBUG';



/* group: ���� ���������� */

/* const: Minute_IntervalTypeCode
  ��� ���� ��������� "������".
*/
Minute_IntervalTypeCode constant varchar2(10) := 'MI';

/* const: Hour_IntervalTypeCode
  ��� ���� ��������� "����".
*/
Hour_IntervalTypeCode constant varchar2(10) := 'HH';

/* const: Dayofmonth_IntervalTypeCode
  ��� ���� ��������� "��� ������".
*/
Dayofmonth_IntervalTypeCode constant varchar2(10) := 'DD';

/* const: Month_IntervalTypeCode
  ��� ���� ��������� "������".
*/
Month_IntervalTypeCode constant varchar2(10) := 'MM';

/* const: Dayofweek_IntervalTypeCode
  ��� ���� ��������� "��� ������".
*/
Dayofweek_IntervalTypeCode constant varchar2(10) := 'DW';



/* group: ������� */



/* group: �������� ������� */

/* pproc: updateBatch
  �������� �����.

  ���������:
  batchId                     - Id ������
  batchName                   - �������� ������
  retrialCount                - ����� ������������
  retrialTimeout              - �������� ����� �������������
  operatorId                  - Id ���������

  ( <body::updateBatch>)
*/
procedure updateBatch(
  batchId integer
  , batchName varchar2
  , retrialCount integer
  , retrialTimeout interval day to second
  , operatorId integer
);

/* pproc: activateBatch
  ������ ����� ������� �� ���������� � ������������ � ����������� (����
  ������������� ���� ������� � �������� ������������ ����������������� ���
  �������������� �� ���������� ������).  ������� ����� ��������� ������� (����
  �� ��� ����������).

  ���������:
  batchId                     - Id �������
  operatorId                  - Id ���������

  ( <body::activateBatch>)
*/
procedure activateBatch(
  batchId integer
  , operatorId integer
);

/* pproc: deactivateBatch
  ���������� ������������� ���������� ������ �������

  ���������:
  batchId                     - Id �������
  operatorId                  - Id ���������

  ( <body::deactivateBatch>)
*/
procedure deactivateBatch(
  batchId integer
  , operatorId integer
);

/* pproc: setNextDate
  ������������� ���� ���������� ������� ��������������� ������.

  batchId                     - Id ������
  operatorId                  - Id ���������
  nextDate                    - ���� ���������� �������
                                ( �� ��������� ����������)

  ( <body::setNextDate>)
*/
procedure setNextDate(
  batchId integer
  , operatorId integer
  , nextDate date := sysdate
);

/* pproc: abortBatch
  ��������� ���������� ������ �������.

  ���������:
  batchId                     - Id �������
  operatorId                  - Id ���������

  ���������:
  - � ������ ��������� ���������� ������ ��������� ����������� commit.

  ( <body::abortBatch>)
*/
procedure abortBatch(
  batchId integer
  , operatorId integer
);

/* pfunc: findBatch
  ����� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  batchShortName              - �������� ��������
  batchName                   - ��������
  moduleId                    - Id ������, � �������� ��������� ������� �������
  retrialCount                - ����� ��������
  lastDateFrom                - ���� ���������� ������� �
  lastDateTo                  - ���� ���������� ������� ��
  rowCount                    - ������������ ����� ������������ �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  ������� ( ������):
  batch_id                    - Id ��������� �������
  batch_short_name            - �������� ��������
  batch_name                  - ��������
  module_id                   - Id ������
  module_name                 - �������� ������
  retrial_count               - ����� ��������
  retrial_timeout             - �������� ����� ���������
  oracle_job_id               - Id ������������ ������� ��� dbms_job
  retrial_number              - ����� ���������� ����������
  date_ins                    - ���� ���������� ��������� �������
  operator_id                 - Id ���������, ����������� �������� �������
  operator_name               - ��� ���������, ����������� �������� �������
                                ( ���.)
  job                         - Id ������� ������������� ������� ��� dbms_job
  last_date                   - ���� ���������� �������
  this_date                   - ���� �������� �������
  next_date                   - ���� ���������� �������
  total_time                  - ��������� ����� ����������
  failures                    - ����� ��������� ���������������� ������ ���
                                ������� ����� dbms_job
  is_job_broken               - ������� ������������ ������� � dbms_job
  root_log_id                 - Id ��������� ���� ���������� ����������
  last_start_date             - ���� ���������� ������� �� ����
  last_log_date               - ���� ��������� ������ � ����
  batch_result_id             - Id ���������� ���������� ��������� �������
  result_name                 - �������� ����������
  error_job_count             - ����� ��������, ������������� ������� ���
                                ��������� ���������
  error_count                 - ����� ������ ��� ��������� ���������
  warning_count               - ����� �������������� ��� ��������� ���������
  duration_second             - ������������ ���������� ���������� ( � ��������)
  sid                         - sid ������, � ������� ����������� ��������
                                �������
  serial                      - serial# ������, � ������� ����������� ��������
                                �������

  ���������:
  - ������������ ������ �������� �������, ��������� ���������� ��������� ��
    ������;
  - �������� ���������� batchShortName, batchName ������������ ��� ������ ��
    ������� ( like) ��� ����� �������� �� ��������������� �����;
  - ���� ��������� ������ ������������� ������ �������, ��� ���������
    ������������ ����� ������������ �������, �� ������ ��� �������� ����������
    ��������� ������� ( ��� ������������� �������);
  - ��������� ��������� �� ��������� null �� ������ �� ��������� ������;

  ( <body::findBatch>)
*/
function findBatch(
  batchId integer := null
  , batchShortName varchar2 := null
  , batchName varchar2 := null
  , moduleId integer := null
  , retrialCount integer := null
  , lastDateFrom date := null
  , lastDateTo date := null
  , rowCount integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: ���������� ������� */

/* pfunc: createSchedule
  ������� ����������.

  ���������:
  batchId                     - Id ������
  scheduleName                - �������� ����������
  operatorId                  - Id ���������

  ( <body::createSchedule>)
*/
function createSchedule(
  batchId integer
  , scheduleName varchar2
  , operatorId integer
)
return integer;

/* pproc: updateSchedule
  �������� ����������.

  ���������:
  scheduleId                  - Id ����������
  scheduleName                - �������� ����������
  operatorId                  - Id ���������

  ( <body::updateSchedule>)
*/
procedure updateSchedule(
  scheduleId integer
  , scheduleName varchar2
  , operatorId integer
);

/* pproc: deleteSchedule
  ������� ����������.

  ���������:
  scheduleId                  - Id ����������
  operatorId                  - Id ���������

  ( <body::deleteSchedule>)
*/
procedure deleteSchedule(
  scheduleId integer
  , operatorId integer
);

/* pfunc: findSchedule

  ���������:
    scheduleId                - ���������� �������������
    batchId                    - ������������� �����
    maxRowCount                - ���������� �������
    operatorId                - ������������� �������� ������������

  ������� (������):
    schedule_id                - ���������� �������������
    batch_id                  - ������������� �����
    schedule_name              - ������������
    date_ins                  - ���� ��������
    operator_id                - ������������� ���������
    operator_name              - ��������

  ( <body::findSchedule>)
*/
function findSchedule
(
    scheduleId  integer := null
  , batchId     integer := null
  , maxRowCount integer := null
  , operatorId  integer := null
) return sys_refcursor;



/* group: ��������� ���������� ������� */

/* pfunc: createInterval
  ������� ��������.

  ���������:
  scheduleId                  - Id ����������
  intervalTypeCode            - ��� ���� ���������
  minValue                    - ����������� ��������
  maxValue                    - ������������ ��������
  step                        - ��� ( �� ��������� 1)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::createInterval>)
*/
function createInterval(
  scheduleId integer
  , intervalTypeCode varchar2
  , minValue integer
  , maxValue integer
  , step integer := null
  , operatorId integer := null
)
return integer;

/* pproc: updateInterval
  �������� ��������.

  ���������:
  intervalId                  - Id ���������
  intervalTypeCode            - ��� ���� ���������
  minValue                    - ����������� ��������
  maxValue                    - ������������ ��������
  step                        - ���
  operatorId                  - Id ���������

  ( <body::updateInterval>)
*/
procedure updateInterval(
  intervalId integer
  , intervalTypeCode varchar2
  , minValue integer
  , maxValue integer
  , step integer
  , operatorId integer
);

/* pproc: deleteInterval
  ������� ��������.

  ���������:
  intervalId                  - Id ���������
  operatorId                  - Id ���������

  ( <body::deleteInterval>)
*/
procedure deleteInterval(
  intervalId integer
  , operatorId integer
);

/* pfunc: findInterval

  ���������:
    scheduleId                - ���������� �������������
    batchId                    - ������������� �����
    maxRowCount                - ���������� �������
    operatorId                - ������������� �������� ������������

  ������� (������):
    interval_id               - ���������� �������������
    schedule_id               - ������������� ����������
    interval_type_code        - ��� ���� ���������
    interval_type_name        - ������������ ���� ���������
    min_value                 - ������ �������
    max_value                 - ������� �������
    step                      - ��� ���������
    date_ins                  - ���� ��������
    operator_id               - ������������� ���������
    operator_name             - ��������

  ( <body::findInterval>)
*/
function findInterval
(
    intervalId  integer := null
  , scheduleId  integer := null
  , maxRowCount integer := null
  , operatorId  integer := null
) return sys_refcursor;



/* group: ���� */

/* pfunc: findRootLog

  ���������:
    logId                  - ���������� �������������
    batchId                - ������������� �����
    maxRowCount            - ���������� �������
    operatorId             - ������������� �������� ������������

  ������� (������):
    log_id                  - ���������� �������������
    batch_id                - ������������� �����
    message_type_code       - ��� ���� ���������
    message_type_name       - ������������ ���� ���������
    message_text            - ����� ���������
    date_ins                - ���� ��������
    operator_id             - ������������� ���������
    operator_name           - ��������

  ( <body::findRootLog>)
*/
function findRootLog
(
    logId        integer := null
  , batchId      integer := null
  , maxRowCount  integer := null
  , operatorId  integer := null
) return sys_refcursor;

/* pfunc: getDetailedLog

  ���������:
    parentLogId            - ������������� ������������� ����
    operatorId             - ������������� �������� ������������

  ������� (������):
    log_id                  - ���������� �������������
    parent_log_id           - ������������� ������������� ����
    message_type_code       - ��� ���� ���������
    message_type_name       - ������������ ���� ���������
    message_text            - ����� ���������
    message_value           - �������� ���������
    log_level               - ������� ��������
    date_ins                - ���� ��������
    operator_id             - ������������� ���������
    operator_name           - ��������

  ( <body::getDetailedLog>)
*/
function getDetailedLog
(
    parentLogId integer
  , operatorId  integer
) return sys_refcursor;



/* group: ��������� �������� ������� */

/* pfunc: createOption
  ������� �������� ��������� ������� � ������ ��� ���� ������������ � �������
  �� ��������.

  ���������:
  batchId                     - Id ��������� �������
  optionShortName             - �������� �������� ���������
  valueTypeCode               - ��� ���� �������� ���������
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ��� ( �� ���������))
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ����
                                ( 1 ��, 0 ��� ( �� ���������))
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 �� ( �� ���������), 0 ���)
  optionName                  - �������� ���������
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  stringListSeparator         - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������� ��������
                                ( �� ��������� ������������ ";")
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id ���������.

  ���������:
  - � ������, ���� ������������ ������ ��������, ��������� � ����������
    ������� �������� ����������� ��� ������ �������� ������;

  ( <body::createOption>)
*/
function createOption(
  batchId integer
  , optionShortName varchar2
  , valueTypeCode varchar2
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , optionName varchar2
  , optionDescription varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , operatorId integer := null
)
return integer;

/* pproc: updateOption
  �������� �������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  optionId                    - Id ���������
  valueTypeCode               - ��� ���� �������� ���������
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ���)
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ���� ( 1 ��, 0 ���)
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ���)
  optionName                  - �������� ���������
  optionDescription           - �������� ���������
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ��������, ������� �� ������������� ����� ������ ������������ ���������,
    ���������;
  - � ������������ �� ��� ��������� �������� testProdSensitiveFlag �������
    �������� ��������� ����������� ( ��� ���� ������ ������ �������� ���������
    �������� ��� ������������ �� ��� ��������);

  ( <body::updateOption>)
*/
procedure updateOption(
  batchId integer
  , optionId integer
  , valueTypeCode varchar2
  , valueListFlag integer
  , encryptionFlag integer
  , testProdSensitiveFlag integer
  , optionName varchar2
  , optionDescription varchar2
  , operatorId integer := null
);

/* pproc: setOptionValue
  ������ ������������ � ������� �� �������� ��������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  optionId                    - Id ���������
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::setOptionValue>)
*/
procedure setOptionValue(
  batchId integer
  , optionId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
);

/* pproc: deleteOption
  ������� ����������� ��������.

  ���������:
  batchId                     - Id ��������� �������
  optionId                    - Id ���������
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::deleteOption>)
*/
procedure deleteOption(
  batchId integer
  , optionId integer
  , operatorId integer := null
);

/* pfunc: findOption
  ����� ����������� ���������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  optionId                    - Id ���������
                                ( �� ��������� ��� �����������)
  maxRowCount                 - ������������ ����� ������������ ������� �������
                                ( �� ��������� ��� �����������)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� ( ������):
  option_id                   - Id ���������
  value_id                    - Id ������������� ��������
  option_short_name           - �������� �������� ���������
  value_type_code             - ��� ���� �������� ���������
  value_type_name             - �������� ���� �������� ���������
  date_value                  - �������� ��������� ���� ����
  number_value                - �������� �������� ���������
  string_value                - ��������� �������� ��������� ���� ������
                                �������� � ������������, ��������� � ����
                                list_separator ( ���� ��� ������)
  list_separator              - ������, ������������ � �������� ����������� �
                                ������ ��������
  value_list_flag             - ���� ������� ��� ��������� ������ ��������
  encryption_flag             - ���� �������� �������� ��������� �
                                ������������� ����
  test_prod_sensitive_flag    - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
  access_level_code           - ��� ������ ������� ����� ���������
  access_level_name           - �������� ������ ������� ����� ���������
  option_name                 - �������� ���������
  option_description          - �������� ���������

  ���������:
  - � ������������ ������� ����� ������������ ������ ������������������� ����
    ����, ������� �� ������ �������������� � ����������;

  ( <body::findOption>)
*/
function findOption(
  batchId integer
  , optionId integer := null
  , maxRowCount integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: �������� ��������� ��������� ������� */

/* pfunc: createValue
  ������� �������� ���������.

  ���������:
  batchId                     - Id ��������� �������
  optionId                    - Id ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                  �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  stringListSeparator         - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������� ��������
                                ( �� ��������� ������������ ";")
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id �������� ���������.

  ���������:
  - � ������, ���� ������������ ������ ��������, ��������� � ����������
    ������� �������� ����������� ��� ������ �������� ������;

  ( <body::createValue>)
*/
function createValue(
  batchId integer
  , optionId integer
  , prodValueFlag integer
  , instanceName varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , operatorId integer := null
)
return integer;

/* pproc: updateValue
  �������� �������� ��������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  valueId                     - Id ��������
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::updateValue>)
*/
procedure updateValue(
  batchId integer
  , valueId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
);

/* pproc: deleteValue
  ������� �������� ��������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  valueId                     - Id �������� ���������
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::deleteValue>)
*/
procedure deleteValue(
  batchId integer
  , valueId integer
  , operatorId integer := null
);

/* pfunc: findValue
  ����� �������� ��������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������
  valueId                     - Id ��������
  optionId                    - Id ���������
  maxRowCount                 - ������������ ����� ������������ ������� �������
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� ( ������):
  value_id                    - Id ��������
  option_id                   - Id ���������
  used_value_flag             - ���� �������� ������������� � �� ��������
                                ( 1 ��, ����� null)
  prod_value_flag             - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) �� ( 1 ������ �
                                ������������ ��, 0 ������ � �������� ��, null
                                ��� �����������)
  instance_name               - ��� ���������� ��, � ������� �����
                                �������������� �������� ( � ������� ��������,
                                null ��� �����������)
  value_type_code             - ��� ���� �������� ���������
  value_type_name             - �������� ���� �������� ���������
  list_separator              - ������, ������������ � �������� ����������� �
                                ������ ��������
  encryption_flag             - ���� �������� �������� ��������� �
                                ������������� ����
  date_value                  - �������� ��������� ���� ����
  number_value                - �������� �������� ���������
  string_value                - ��������� �������� ��������� ���� ������
                                �������� � ������������, ��������� � ����
                                list_separator ( ���� ��� ������)

  ���������:
  - ����������� ������ ���� ������� �������� valueId ��� optionId;

  ( <body::findValue>)
*/
function findValue(
  batchId integer
  , valueId integer := null
  , optionId integer := null
  , maxRowCount integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: ����� ����� �� �������� ������� */

/* pfunc: createBatchRole
  ������ ���� ���������� �� �����.

  ���������:
  batchId                     - Id ������
  privilegeCode               - ��� ����������
  roleId                      - Id ����
  operatorId                  - Id ���������

  ( <body::createBatchRole>)
*/
function createBatchRole(
  batchId integer
  , privilegeCode varchar2
  , roleId integer
  , operatorId integer
)
return integer;

/* pproc: deleteBatchRole
  �������� � ���� ���������� �� �����.

  ���������:
  batchRoleId                 - Id ��������� ������
  operatorId                  - Id ���������

  ( <body::deleteBatchRole>)
*/
procedure deleteBatchRole(
  batchRoleId integer
  , operatorId integer
);

/* pfunc: findBatchRole

  ���������:
    batchRoleId                 - ���������� �������������
    batchId                     - ������������� �����
    maxRowCount                 - ���������� �������
    operatorId                  - ������������� �������� ������������

  ������� (������):
    batch_role_id               - ���������� �������������
    batch_id                    - ������������� �����
    privilege_code              - ��� ����������
    role_id                     - ������������� ����
    role_short_name             - ������� ������������ ����
    privilege_name              - ������������ ����������
    role_name                   - ������������ ����
    date_ins                    - ���� ��������
    operator_id                 - ������������� ���������
    operator_name               - ��������

  ( <body::findBatchRole>)
*/
function findBatchRole
(
    batchRoleId integer := null
  , batchId     integer := null
  , maxRowCount  integer := null
  , operatorId  integer := null
) return sys_refcursor;



/* group: ����� ����� �� �������� ������� ������� */

/* pfunc: createModuleRolePrivilege
  ������ ���� ���������� �� ����� �������� ������� ������.

  ���������:
  moduleId                    - Id ������
  roleId                      - Id ����
  privilegeCode               - ��� ����������
  operatorId                  - Id ���������

  �������:
  Id ��������� ������.

  ( <body::createModuleRolePrivilege>)
*/
function createModuleRolePrivilege(
  moduleId integer
  , roleId integer
  , privilegeCode varchar2
  , operatorId integer
)
return integer;

/* pproc: deleteModuleRolePrivilege
  �������� � ���� ���������� �� ��� �������.

  ���������:
  moduleRolePrivilegeId       - Id ������ c ������� ����������
  operatorId                  - Id ���������

  ( <body::deleteModuleRolePrivilege>)
*/
procedure deleteModuleRolePrivilege(
  moduleRolePrivilegeId integer
  , operatorId integer
);

/* pfunc: findModuleRolePrivilege
  ����� �������� ����� ���������� �� ����� �������� ������� ������.

  ���������:
  moduleRolePrivilegeId       - Id ������ c ������� ����������
                                ( �� ��������� ��� �����������)
  moduleId                    - Id ������
                                ( �� ��������� ��� �����������)
  roleId                      - Id ����
                                ( �� ��������� ��� �����������)
  privilegeCode               - ��� ����������
                                ( �� ��������� ��� �����������)
  maxRowCount                 - ������������ ����� ������������ �������
                                ( �� ��������� ��� �����������)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� (������):
  module_role_privilege_id    - Id ������ c ������� ����������
  module_id                   - Id ������
  module_name                 - �������� ������
  role_id                     - Id ����
  role_short_name             - ������� �������� ����
  role_name                   - �������� ����
  privilege_code              - ��� ����������
  privilege_name              - �������� ����������
  date_ins                    - ���� ���������� ������
  operator_id                 - Id ���������, ����������� ������
  operator_name               - ��������, ���������� ������

  ���������:
  - ������������ ������ ������������� �� module_name, role_short_name,
    privilege_code;

  ( <body::findModuleRolePrivilege>)
*/
function findModuleRolePrivilege(
  moduleRolePrivilegeId integer := null
  , moduleId integer := null
  , privilegeCode varchar2 := null
  , roleId integer := null
  , maxRowCount  integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: ����������� */

/* pfunc: findModule
  ���������� ����������� ������, � ������� ���� �������� �������.

  ������� ( ������):
  module_id                   - Id ������
  module_name                 - �������� ������
  ( ���������� �� module_name, module_id)

  ( <body::findModule>)
*/
function findModule
return sys_refcursor;

/* pfunc: getIntervalType
  ������� �������� ��� ������ �� ������� sch_interval_type ��� �������������� �������.

  ������� (������):
    interval_type_code          -  ���������� �������������
    interval_type_name          -  ������������

  ( <body::getIntervalType>)
*/
function getIntervalType
return sys_refcursor;

/* pfunc: getPrivilege
  ���������� ���������� �� ������ � ��������� ���������.

  ������� ( ������):
  privilege_code              - ��� ���� ����������
  privilege_name              - �������� ���� ����������

  ( ���������� �� privilege_name)

  ( <body::getPrivilege>)
*/
function getPrivilege
return sys_refcursor;

/* pfunc: getRole
  ���������� ������ �����.

  ���������:
  searchStr                   - ������-������� ��� ������ ( ������ ��� ������
                                �� ��������� ��������, �������� ��� ��������
                                ���� ��� ����� ��������)

  ������� ( ������):
  role_id                     - Id ����
  role_name                   - �������� ����

  ���������:
  - ������������ ������ ������������� �� role_name;

  ( <body::getRole>)
*/
function getRole(
  searchStr varchar2 := null
)
return sys_refcursor;

/* pfunc: getValueType
  ���������� ���� �������� ���������� �������� �������.

  ������� ( ������):
  value_type_code             - ��� ���� �������� ���������
  value_type_name             - �������� ���� �������� ���������

  ( <body::getValueType>)
*/
function getValueType
return sys_refcursor;



/* group: ���������� ������ */

/* pfunc: calcNextDate
  ��������� ���� ���������� ������� ������ �������.

  ���������:
  batchId              - Id ������
  startDate            - ��������� ���� (������� � ������� ����������� ������)

  ( <body::calcNextDate>)
*/
function calcNextDate(
  batchId integer
  , startDate date := sysdate
)
return date;

/* pproc: stopHandler
  ������������� ������ ����������� � ������� �������� ������� ���������.

  ���������:
  batchId                     - Id ������
  sid                         - sid ������
  serial#                     - serial# ������
  operatorId                  - Id ���������

  ( <body::stopHandler>)
*/
procedure stopHandler(
  batchId integer
  , sid number
  , serial# number
  , operatorId integer
);

/* pproc: execBatch( BATCH_ID)
  ��������� ��������� ����� �������

  ���������:
  batchId              - Id �������

  ( <body::execBatch( BATCH_ID)>)
*/
function execBatch(
  batchId integer
)
return integer;

/* pproc: execBatch( BATCH_SHORT_NAME)
  ��������� ��������� ����� �������

  ���������:
  batchShortName       - ��� (batch_short_name) ������������ �������

  ( <body::execBatch( BATCH_SHORT_NAME)>)
*/
function execBatch(
  batchShortName varchar2
)
return integer;



/* group: ������ ������� */

/* pproc: clearLog
  ������� ������ ���� � ���������� ����� ��������� �������.

  ���������:
  toDate                      - ����, �� ������� ���� ������� ���� ( �� �������)

  ( <body::clearLog>)
*/
function clearLog(
  toDate date
)
return integer;

/* pfunc: getLog
  ���������� ����� �� ���� ( ������� sch_log).

  ���������:
  rootLogId                - Id �������� ������ �� sch_log

  ���������:
  - ������� ������������� ��� ������������� � SQL-�������� ����:
  select lg.* from record( pkg_Scheduler.getLog( :rootLogId)) lg

  ( <body::getLog>)
*/
function getLog(
  rootLogId integer
)
return
  sch_log_table_t
pipelined parallel_enable;



/* group: ��������� ������ ���������� ������� */

/* pfunc: getDebugFlag
  ���������� �������� ����� �������.

  ( <body::getDebugFlag>)
*/
function getDebugFlag
return integer;

/* pproc: setDebugFlag
  ������������� ���� ������� � ��������� ��������.

  ( <body::setDebugFlag>)
*/
procedure setDebugFlag(
  flagValue integer := 1
);

/* pfunc: getSendNotifyFlag
  ���������� �������� ����� �������������� �������� �����������.

  ( <body::getSendNotifyFlag>)
*/
function getSendNotifyFlag
return integer;

/* pproc: setSendNotifyFlag
  ������������� ���� �������� ����������� � ��������� ��������.

  ( <body::setSendNotifyFlag>)
*/
procedure setSendNotifyFlag(
  flagValue integer := 1
);



/* group: ���������� ��������� ������� */

/* pproc: setContext( ANYDATA)
  ������������� �������� ���������� ��������� ������� ������������� ����.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  varValue                    - �������� ����������
  isConstant                  - ���������� �������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)

  ( <body::setContext( ANYDATA)>)
*/
procedure setContext(
  varName varchar2
  , varValue anydata
  , isConstant integer := null
  , valueIndex pls_integer := null
);

/* pproc: setContext( DATE)
  ������������� �������� ���������� ��������� ������� ���� ����.
  �������.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  varValue                    - �������� ����������
  isConstant                  - ���������� �������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)

  ( <body::setContext( DATE)>)
*/
procedure setContext(
  varName varchar2
  , varValue date
  , isConstant integer := null
  , valueIndex pls_integer := null
);

/* pproc: setContext( NUMBER)
  ������������� �������� �������� ���������� ��������� �������.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  varValue                    - �������� ����������
  isConstant                  - ���������� �������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)

  ( <body::setContext( NUMBER)>)
*/
procedure setContext(
  varName varchar2
  , varValue number
  , isConstant integer := null
  , valueIndex pls_integer := null
);

/* pproc: setContext( STRING)
  ������������� ��������� �������� ���������� ��������� �������.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  varValue                    - �������� ����������
  isConstant                  - ���������� �������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)
  encryptedValue              - ������������� �������� ����������
                                ( ���� �������, �� ������������ ��� �����������
                                  ������ �������� ����������)

  ( <body::setContext( STRING)>)
*/
procedure setContext(
  varName varchar2
  , varValue varchar2
  , isConstant integer := null
  , valueIndex pls_integer := null
  , encryptedValue varchar2 := null
);

/* pfunc: getContextAnydata
  ���������� �������� ���������� ��������� ������� ������������� ����.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)

  �������:
  �������� ����������.

  ( <body::getContextAnydata>)
*/
function getContextAnydata(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return anydata;

/* pfunc: getContextDate
  ���������� �������� ���������� ��������� ������� ���� ����.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)

  �������:
  �������� ����������.

  ( <body::getContextDate>)
*/
function getContextDate(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return date;

/* pfunc: getContextNumber
  ���������� �������� ���������� ��������� ������� ��������� ����.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)

  �������:
  �������� ����������.

  ( <body::getContextNumber>)
*/
function getContextNumber(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return number;

/* pfunc: getContextString
  ���������� �������� ���������� ��������� ������� ���������� ����.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, �� ��������� 1)

  �������:
  �������� ����������.

  ( <body::getContextString>)
*/
function getContextString(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return varchar2;

/* pfunc: getContextValueCount
  ���������� ����� �������� ��� ���������� ��������� �������.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������:
  ����� �������� ��� 0 ��� ���������� ����������.

  ( <body::getContextValueCount>)
*/
function getContextValueCount(
  varName in varchar2
  , riseException integer := null
)
return integer;

/* pproc: deleteContext
  ������� ���������� ��������� �������.

  ���������:
  varName                     - ��� ���������� ( ��� ����� ��������)
  riseException               - ���� ��������� ���������� ��� ����������
                                ����������
                                ( 1 ��, 0 ��� ( �� ���������))

  ( <body::deleteContext>)
*/
procedure deleteContext(
  varName in varchar2
  , riseException integer := null
);



/* group: ����������� */

/* pproc: writeLog
  ���������� ��������� � ��� (������� sch_log).

  ���������:
  MessageTypeCode           - ��� ���� ���������
  MessageText               - ����� ���������
  MessageValue              - ����� ��������, ��������� � ����������
  operatorId                - Id ���������

  ( <body::writeLog>)
*/
procedure writeLog(
  messageTypeCode varchar2
  , messageText varchar2
  , messageValue number := null
  , operatorId integer := null
);



/* group: ���������� ��������� ������� */

/* pproc: execBatch( ORACLE_JOB)
  ��������� ��������� ����� �������

  ���������:
  oracleJobId          - Id ������� Oracle (��� ����������� batch_id)
  nextDate             - ���� ���������� ������� (��� dbms_job)

  ( <body::execBatch( ORACLE_JOB)>)
*/
procedure execBatch(
  oracleJobId number
  , nextDate in out date
);



/* group: ���������� ������� */

/* pfunc: getContextInteger
  ���������� �������, ������� ������������ <getContextNumber>.

  ( <body::getContextInteger>)
*/
function getContextInteger(
  varName in varchar2
  , riseException integer := 0
)
return number;

end pkg_Scheduler;
/
