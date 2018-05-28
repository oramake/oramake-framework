create or replace package pkg_LoggingInternal is
/* package: pkg_LoggingInternal
  ���������� ����� ������ Logging.

  SVN root: Oracle/Module/Logging
*/



/* group: ��������� */



/* group: ���� ��������� ���� */

/* const: Error_MessageTypeCode
  ��� ���� ��������� "������".
*/
Error_MessageTypeCode constant varchar2(10) := 'ERROR';

/* const: Info_MessageTypeCode
  ��� ���� ��������� "����������".
*/
Info_MessageTypeCode constant varchar2(10) := 'INFO';

/* const: Warning_MessageTypeCode
  ��� ���� ��������� "��������������".
*/
Warning_MessageTypeCode constant varchar2(10) := 'WARNING';

/* const: Debug_MessageTypeCode
  ��� ���� ��������� "�������".
*/
Debug_MessageTypeCode constant varchar2(10) := 'DEBUG';



/* group: ������� */



/* group: ������������� ������ AccessOperator */

/* pfunc: getCurrentOperatorId
  ���������� Id �������� ������������������� ��������� ��� ����������� ������
  AccessOperator.

  �������:
  Id �������� ��������� ���� null � ������ ������������� ������ AccessOperator
  ��� ���������� �������� ������������������� ���������.

  ( <body::getCurrentOperatorId>)
*/
function getCurrentOperatorId
return integer;



/* group: ��������� ����������� */

/* pproc: setDestination
  ������������� ������������ ���������� ��� ������.

  ���������:
  destinationCode             - ��� ����������

  ( <body::setDestination>)
*/
procedure setDestination(
  destinationCode varchar2
);



/* group: ����������� ��������� */

/* pproc: logMessage
  �������� ���������.

  ���������:
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������
  loggerUid                   - ������������� ������, ����� ������� ������
                                ��������� ( �� ��������� �������� �����)

  ���������:
  - ������� ���������� �� ��������� ������� ��������� �� ������������ ��
    � ������� <lg_log>, � �� �������� �� ����� ����� dbms_output

  ( <body::logMessage>)
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , loggerUid varchar2 := null
);



/* group: ���������� ������� ������ */

/* pfunc: getLoggerUid
  ���������� ���������� ������������� ������ �� �����.
  ��� ���������� ���������������� ������ ������� �����.

  ���������:
  loggerName                  - ��� ������ ( null ������������ ��������� ������)

  �������:
  - ������������� ������������� ������

  ( <body::getLoggerUid>)
*/
function getLoggerUid(
  loggerName varchar2
)
return varchar2;

/* pfunc: getAdditivity
  ���������� ���� ������������.

  ( <body::getAdditivity>)
*/
function getAdditivity(
  loggerUid varchar2
)
return boolean;

/* pproc: setAdditivity
  ������������� ���� ������������.

  ���������:
  loggerUid                   - ������������� ������
  additive                    - ���� ������������

  ( <body::setAdditivity>)
*/
procedure setAdditivity(
  loggerUid varchar2
  , additive boolean
);

/* pfunc: getLevel
  ���������� ������� �����������.

  ���������:
  loggerUid                   - ������������� ������

  ( <body::getLevel>)
*/
function getLevel(
  loggerUid varchar2
)
return varchar2;

/* pproc: setLevel
  ������������� ������� �����������.

  ���������:
  loggerUid                   - ������������� ������
  levelCode                   - ��� ������ ���������� ���������

  ( <body::setLevel>)
*/
procedure setLevel(
  loggerUid varchar2
  , levelCode varchar2
);

/* pfunc: getEffectiveLevel
  ���������� ����������� ������� �����������.

  ���������:
  loggerUid                   - ������������� ������

  �������:
  - ��� ������ �����������

  ���������:
  - �������� ������� <getLoggerEffectiveLevel>;

  ( <body::getEffectiveLevel>)
*/
function getEffectiveLevel(
  loggerUid varchar2
)
return varchar2;

/* pfunc: isEnabledFor
  ���������� ������, ���� ��������� ������� ������ ����� ������������.

  ���������:
  loggerUid                   - ������������� ������
  levelCode                   - ��� ������ �����������

  ���������:
  - �������� ������� <isMessageEnabled>;

  ( <body::isEnabledFor>)
*/
function isEnabledFor(
  loggerUid varchar2
  , levelCode varchar2
)
return boolean;



/* group: ������������� � Scheduler */

/* pproc: beforeInsertLogRow
  ���������� ��� ���������������� ������� ������� �� ������ ������� �� ��������
  �� ������� <lg_log>.

  ���������:
  logRec                      - ������ ������ ������� <lg_log>
                                (�����������)

  ( <body::beforeInsertLogRow>)
*/
procedure beforeInsertLogRow(
  logRec in out nocopy lg_log%rowtype
);

end pkg_LoggingInternal;
/

