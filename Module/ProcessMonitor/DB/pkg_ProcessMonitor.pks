create or replace package pkg_ProcessMonitor is
/* package: pkg_ProcessMonitor
  ������������ ����� ������ ProcessMonitor.

  SVN root: Oracle/Module/ProcessMonitor
*/



/* group: ������� */



/* group: ����������� */

/* pproc: hoursToString
  ������� �������� ������� � ����� � ������.

  �������:
  - ������ � ���� "? ����� ?? �����"

  ( <body::hoursToString>)
*/
function hoursToString( hour number)
return varchar2;

/* pproc: sqlTraceOn(registeredSessionId)
   ��������� ����������� ��� ����������������� ������.

   ���������:
   registeredSessionId        - id ������������������ ������ ( ������ ��
                                <prm_registered_session>)
   isFinalTraceSending        - ����� �� ���������� ������
                                � ����������� �� ���������� ������
                                ��-��������� �� ����������.
   recipient                  - ����������(�) ���������
                                ��� �������� ����� � �����������.
                                ��-��������� ����������� ���� ��� ��
                                (  ������� pkg_Common.getMailAddressSource()).
   subject                    - ���� ������ ��� �������� �����.
                                ��-��������� - ���.
   sqlTraceLevel              -  ������� �����������. �� ��������� - 12
                                (��. �������� ������� ����������� � <sqlTraceOn>)

  ( <body::sqlTraceOn(registeredSessionId)>)
*/
procedure sqlTraceOn(
  registeredSessionId integer
  , isFinalTraceSending integer := null
  , recipient varchar2 := null
  , subject varchar2 := null
  , sqlTraceLevel integer := null
);

/* pproc: sqlTraceOn
   ��������� �����������

   ���������:
   sid                        - sid ������ ( ��-��������� ������ ������� ������)
   serial#                    - serial# ������ ( ��-��������� ������ ������� ������)
   isFinalTraceSending        - ����� �� ���������� ������ � ����������� ��
                                ���������� ������. �� ���������-���.
   recipient                  - ����������(�) ��������� ��� �������� ����� �
                                �����������. �� ���������-����������� ���� ��� ��
                                ( ������ Common).
   subject                    - ���� ������ ��� �������� �����. �� ���������-���.
   sqlTraceLevel              - ������� �����������. ��-��������� 12.

   sqlTraceLevel ����� ��������� ��������� ��������:

   sqlTraceLevel=1            - �������� ����������� �������� SQL_TRACE.
                                ��������� �� ���������� �� ���������
                                SQL_TRACE=true.
   sqlTraceLevel=4            - �������� ����������� �������� SQL_TRACE �
                                ��������� � �������������� ���� ��������
                                ����������� ����������.
   sqlTraceLevel=8            - �������� ����������� �������� SQL_TRACE �
                                ��������� � �������������� ���� ���������� �
                                �������� �������� �� ������ ��������.
   sqlTraceLevel=12           - �������� ����������� �������� SQL_TRACE �
                                ��������� ��� �������� ����������� ����������,
                                ��� � ���������� �� �������� �������.

  ( <body::sqlTraceOn>)
*/
procedure sqlTraceOn(
  sid integer := null
  , serial# integer := null
  , isFinalTraceSending integer := null
  , recipient varchar2 := null
  , subject varchar2 := null
  , sqlTraceLevel integer := null
);

/* pfunc: copyTrace(registeredSessionId)
  ����������� ������ �����������

  ���������:
  registeredSessionId         - id ������������������ ������ ( ������ ��
                                <prm_registered_session>)
  traceCopyPath               - ���������� ��� ����������� ������ �����������
                                ( ��-��������� ������ ���������
                                  <pkg_ProcessMonitorUtility.getDefaultTraceCopyPath>)
  isSourceDeleted             - ������� �� �������� ���� ����������� (
                                ��-��������� �� �������).

  �������:
  - ���������� � ����������� � ���� ������;

  ( <body::copyTrace(registeredSessionId)>)
*/
function copyTrace(
  registeredSessionId integer
  , traceCopyPath varchar2
  , isSourceDeleted integer := null
)
return varchar2;

/* pfunc: copyTrace
  ����������� ������ �����������

  ���������:
  traceCopyPath               - ���������� ��� ����������� ������ �����������
                                ( ��-��������� ������ ���������
                                  <pkg_ProcessMonitorUtility.getDefaultTraceCopyPath>)
  isSourceDeleted             - ������� �� �������� ���� ����������� (
                                ��-��������� �� �������).
  sid                         - sid ������ ( ��-��������� ������ ������� ������)
  serial#                     - serial# ������ ( ��-��������� ������ ������� ������)

  �������:
    - ���������� � ����������� � ���� ������

  ( <body::copyTrace>)
*/
function copyTrace(
  traceCopyPath varchar2
  , isSourceDeleted integer := null
  , sid integer := null
  , serial# integer := null
)
return varchar2;

/* pproc: sendTrace
  �������� ������ �� ����� ������ �����������

  ���������:
  sid                         - sid ������ ( ��-��������� ������ �������
                                ������)
  serial#                     - serial# ������ ( ��-��������� ������ �������
                                ������)
  recipient                   - ����������(�) ��������� ��� �������� ����� �
                                �����������.  ��-��������� ����������� ����
                                ��� �� ( �������
                                pkg_Common.getMailAddressSource()).
  subject                     - ���� ������ ��� �������� �����.  ��-���������
                                ����������� ��������� ������.
  isSourceDeleted             - ������� �� �������� ���� ����������� (
                                ��-��������� �� �������).
  traceCopyPath               - ���������� ��� ����������� ������ �����������
                                ( ��-��������� ������ ���������
                                  <pkg_ProcessMonitorUtility.getDefaultTraceCopyPath>)
  sqlTraceOff                 - ��������� �� ����������� ����� ���������
                                ������ (1-��).  ��-��������� �� ���������.

  ( <body::sendTrace>)
*/
procedure sendTrace(
  sid integer := null
  , serial# integer := null
  , recipient varchar2 := null
  , subject varchar2 := null
  , isSourceDeleted integer := null
  , traceCopyPath varchar2 := null
  , sqlTraceOff integer := null
);

/* pproc: sqlTraceOff
  ���������� �����������

  ���������:
  sid                         - sid ������ ( ��-��������� ������� �������)
  serial#                     - serial# ������ ( ��-��������� ������� �������)

  ( <body::sqlTraceOff>)
*/
procedure sqlTraceOff(
  sid integer := null
  , serial# integer := null
);

/* pproc: batchTraceOn
  ��������� ����������� ��� ������ �����

  ���������:
  sid                         - sid ������ ( ��-��������� ������ ������� ������)
  serial#                     - serial# ������ ( ��-��������� ������ ������� ������)
  isFinalTraceSending         - ����� �� ���������� ������ � ����������� ��
                                ���������� ������
  sqlTraceLevel               - ������� ����������� (��. �������� �������
                                ����������� � <sqlTraceOn>)
  batchShortName              - ������������ �����

  ( <body::batchTraceOn>)
*/
procedure batchTraceOn(
  sid integer
  , serial# integer
  , isFinalTraceSending integer
  , sqlTraceLevel integer
  , batchShortName varchar2
);



/* group: �������� �� ���������� */

/* pfunc: formatLargeNumber
  �������������� �������� ����� � ������ ( � ������������� ��� ������
  ����������).

  ���������:
  numberValue                 - �������� ��������

  ( <body::formatLargeNumber>)
*/
function formatLargeNumber(
  numberValue number
)
return varchar2;

/* pproc: batchBegin
  ���������, ���������� � ������ ������ �����.

  ���������:
  sqlTraceLevel               - ������� ����������� (��. �������� �������
                                ����������� � <sqlTraceOn>)

  ( <body::batchBegin>)
*/
procedure batchBegin(
  sqlTraceLevel integer := null
);

/* pproc: batchEnd
  ���������, ���������� � ����� ������ �����.

  ( <body::batchEnd>)
*/
procedure batchEnd;

/* pproc: checkTrace
  ��������� ����������� ��� ������������������ ������.

  ( <body::checkTrace>)
*/
procedure checkTrace;

/* pproc: checkOraKill
  ���������� oraKill ��� ������������������ ������.

  ( <body::checkOraKill>)
*/
procedure checkOraKill;

/* pproc: checkSendTrace
  �������� ������ �� ����� ������ ����������� ��� ������������������ ������.

  ���������:
  isBatchEnd                  - ����� �� ��������� �������� ��� ����� �������
                                ������ (1-��) ��-��������� ���.

  ( <body::checkSendTrace>)
*/
procedure checkSendTrace(
  isBatchEnd integer := null
);

/* pproc: checkBatchExecution
  ������������ ������ ������

  ���������:
  warningTimePercent          - ����� �������������� ( � ���������)
  warningTimeHour             - ����� �������������� ( � �����)
  minWarningTimeHour          - ����������� ����� �������������� ( � �����)
  abortTimeHour               - ����� ���������� ( � �����)
  orakillWaitTimeHour         - ����� ���������� ����� orakill ( � �����).
                                ����� ������� ������������� � ������
                                ���������� ������.

  ( <body::checkBatchExecution>)
*/
procedure checkBatchExecution(
  warningTimePercent integer
  , warningTimeHour integer
  , minWarningTimeHour integer
  , abortTimeHour integer
  , orakillWaitTimeHour integer
  , traceCopyPath varchar2 := null
);

/* pfunc: getOsMemory
  ��������� ������ ������ ( � ������) �������������� ��������� Oracle.

  ���������:
  - ��������������, ��� ��� �������, ���������������� �������� �������� � ����
    ��� oracle instance;

  ( <body::getOsMemory>)
*/
function getOsMemory
return number;

/* pproc: checkMemory
  �������� ���������� �������� ������� ������������ ����������� ������.

  ���������:
  osMemoryThreshold           - ����� ������ �������� ������������ ������� �
                                ������, ��� ������� ������� ��������������
  pgaMemoryThreshold          - ����� ������ PGA ��������� Oracle, ��� �������
                                ������� ��������������
  emailRecipient              - ����������(�) ��������������

  ����������:
  - ������ ���� ����� ���� �� ���� ����� ( osMemoryThreshold ���
    pgaMemoryThreshold);

  ( <body::checkMemory>)
*/
procedure checkMemory(
  osMemoryThreshold number := null
  , pgaMemoryThreshold number := null
  , emailRecipient varchar2 := null
);



/* group: ��������� ����� */

/* pproc: setBatchConfig
  ��������� �������� ��� �����

  ���������:
  batchShortName              - �������� ������������ �����
  warningTimePercent          - ����� �������������� � ���������� ����������
                                ( � ���������)
  warningTimeHour             - ����� �������������� � ���������� ����������
                                ( � �����)
  abortTimeHour               - ����� ���������� ( � �����)
  orakillWaitTimeHour         - ����� �������� ��� ���������� oraKill ��� ������
                                � ��������� KILLED
  traceTimeHour               - ����� ��������� � �������� ����� �����������
  isFinalTraceSending         - �������� ������ �� ���� ����������� ��� ����������
                                ��������� �������
  sqlTraceLevel               - ������� �����������
                                (��. �������� ������� ����������� � <sqlTraceOn>)

  ( <body::setBatchConfig>)
*/
procedure setBatchConfig(
  batchShortName varchar2
  , warningTimePercent integer
  , warningTimeHour integer
  , abortTimeHour integer
  , orakillWaitTimeHour integer
  , traceTimeHour integer
  , sqlTraceLevel integer
  , isFinalTraceSending integer
);

/* pproc: deleteBatchConfig
  �������� �������� ��� �����

  ���������:
  batchShortName              - �������� ������������ �����

  ( <body::deleteBatchConfig>)
*/
procedure deleteBatchConfig(
  batchShortName varchar2
);

end pkg_ProcessMonitor;
/
