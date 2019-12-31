create or replace package pkg_SchedulerTest is
/* package: pkg_SchedulerTest
  ����� ��� ������������ ������.

  SVN root: Oracle/Module/Scheduler
*/



/* group: ��������� */



/* group: ���������� ���� �������� */

/* const: Activate_OperCode
  ��� �������� "��������� �����".
*/
Activate_OperCode constant varchar2(20) := 'ACTIVATE';

/* const: Deactivate_OperCode
  ��� �������� "����������� �����".
*/
Deactivate_OperCode constant varchar2(20) := 'DEACTIVATE';

/* const: Run_OperCode
  ��� �������� "������ �����".
*/
Run_OperCode constant varchar2(20) := 'RUN';

/* const: ShowLog_OperCode
  ��� �������� "����� ���� �����".
*/
ShowLog_OperCode constant varchar2(20) := 'SHOW_LOG';

/* const: WaitRun_OperCode
  ��� �������� "�������� ��������� ������ �����".
*/
WaitRun_OperCode constant varchar2(20) := 'WAIT_RUN';

/* const: WaitSession_OperCode
  ��� �������� "�������� �������� ������ �����".
*/
WaitSession_OperCode constant varchar2(20) := 'WAIT_SESSION';

/* const: WaitAbsentSession_OperCode
  ��� �������� "�������� �������� ������ �����".
*/
WaitAbsentSession_OperCode constant varchar2(20) := 'SESSION_ABSENT';



/* group: ������� */

/* pproc: killBatchSession
  ��������� ���������� ������ �����.

  ���������:
  batchShortName              - ������� ������������ ��������� �������
  waitSecond                  - ������������ ����� �������� ���������� ������
                                � ��������
                                (�� ��������� ��� ��������)

  ( <body::killBatchSession>)
*/
procedure killBatchSession(
  batchShortName varchar2
  , waitSecond number := null
);

/* pproc: testBatchOperation
  ��������� ������������ ���������� �������� ��� ��������� ���������.

  ���������:
  testCaseNumber              - ����� ������������ ��������� ������
                                (�� ��������� ��� �����������)
  saveDataFlag                - ���� ���������� �������� ������
                                (1 ��, 0 ��� (�� ���������))

  ( <body::testBatchOperation>)
*/
procedure testBatchOperation(
  testCaseNumber integer := null
  , saveDataFlag integer := null
);

/* pproc: setOutputFlag
  ��������� ���� ������ � ����� dbms_output.

  ���������:
  outputFlag                  - ���� ������ � ����� dbms_output.

  ( <body::setOutputFlag>)
*/
procedure setOutputFlag(
  outputFlag number
);

/* pproc: showLastRunLog
  ������� ��� ���������� ���������� ����� �� �����.

  ���������:
  batchId                     - id �����

  ( <body::showLastRunLog>)
*/
procedure showLastRunLog(
  batchId integer
);

/* pfunc: isOfMask
  �������� ������������ ������ ������.

  ���������:
  testString                  - ������
  maskList                    - ������ �����

  ( <body::isOfMask>)
*/
function isOfMask(
  testString varchar2
  , maskList varchar2
)
return integer;

/* pproc: execBatchOperation
  ��������� �������� � �������.

  batchShortNameList          - ������ ����� ������ ����� ","
  operationCode               - ��� �������� ( ��. <pkg_SchedulerTest::���������);

  ( <body::execBatchOperation>)
*/
procedure execBatchOperation(
  batchShortNameList varchar2
  , operationCode varchar2
);

/* pproc: testBatch
  ���������� �����, ���������, ������� ���������� ������ � ������������, �����
  ���������� ��� ����������.

  ���������:
  batchShortNameList          - ������ ����� ������ ����� ","
  batchWaitSecond             - ����� �������� ������ ����� � �������� ( ��
                                ��������� ������������ ����������,
                                ��-��������� ������);
  raiseWhenRetryFlag          - ��������� ���������� � ������ ������� ����������
                                ����� "��������� �������". ��-��������� ������������.

  ( <body::testBatch>)
*/
procedure testBatch(
  batchShortNameList varchar2
  , batchWaitSecond number := null
  , raiseWhenRetryFlag number := null
);

/* pproc: testLoadBatch
  ������������ �������� �����.

  ���������:
  jobWhat                     - plsql-��� ������� ( job)
  batchXmlText                - ���������� ��������� ������� � ���� xml
  testCaseNumber              - ����� ������������ ��������� ������
                                ( �� ��������� ��� ����������� ���� �� �������
                                  ��������� jobWhat � batchXmlText, �����
                                  ������ 1 ���� ( �������� ������� � �����))

  ( <body::testLoadBatch>)
*/
procedure testLoadBatch(
  jobWhat varchar2 := null
  , batchXmlText clob := null
  , testCaseNumber integer := null
);

/* pproc: testNlsLanguage
  �������� ����� ���������.

  ���������:
  nlsLanguage                 - �������� ���������� NLS_LANGUAGE

  ( <body::testNlsLanguage>)
*/
procedure testNlsLanguage(
  nlsLanguage varchar2
);

/* pproc: testWebApi
  ���� API ��� web-����������.

  ( <body::testWebApi>)
*/
procedure testWebApi;

/* pproc: testBatchOption
  ���� ���� sch_batch_option_t.

  ( <body::testBatchOption>)
*/
procedure testBatchOption;

end pkg_SchedulerTest;
/
