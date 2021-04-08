create or replace package pkg_LoggingInternal is
/* package: pkg_LoggingInternal
  ���������� ����� ������ Logging.

  SVN root: Oracle/Module/Logging
*/



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
                                (null ��� �������� � ������ �� ���������)

  ���������:
  - �� ��������� (���� �� ������ ������������ ���������� ��� ������)
    ���������� ��������� ����������� � ������� <lg_log>, � � �������� ��
    ������������� ��������� ����� ����� dbms_output (���� ������ �� ��������
    ����� dbms_job);

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
  messageValue                - ������������� ��������, ��������� � ����������
                                (�� ��������� �����������)
  messageLabel                - ��������� ��������, ��������� � ����������
                                (�� ��������� �����������)
  textData                    - ��������� ������, ��������� � ����������
                                (�� ��������� �����������)
  contextTypeShortName        - ������� ������������ ����
                                ������������/������������ ��������� ����������
                                (�� ��������� �����������)
  contextValueId              - �������������, ��������� �
                                �����������/����������� ���������� ����������
                                (�� ��������� �����������)
  openContextFlag             - ���� �������� ��������� ����������
                                (1 �������� ���������, 0 �������� ���������,
                                -1 �������� � ����������� �������� ���������,
                                null �������� �� ��������)
                                (�� ��������� -1 ���� ������
                                contextTypeShortName, ����� null)
  contextTypeModuleId         - Id ������ � ModuleInfo, � �������� ���������
                                �����������/����������� �������� ����������
                                (�� ��������� Id ������, � �������� ���������
                                �����)
  loggerUid                   - ������������� ������
                                (�� ��������� �������� �����)
  disableDboutFlag            - ������ ������ ��������� ����� dbms_output
                                (� �.�. ����������� ��������� �� �������)
                                (1 ��, 0 ��� (�� ���������))


  ���������:
  - ������� ���������� �� ��������� ������� ��������� �� ������������ ��
    � ������� <lg_log>, � �� �������� �� ����� ����� dbms_output

  ( <body::logMessage>)
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , messageValue integer := null
  , messageLabel varchar2 := null
  , textData clob := null
  , contextTypeShortName varchar2 := null
  , contextValueId integer := null
  , openContextFlag integer := null
  , contextTypeModuleId integer := null
  , loggerUid varchar2 := null
  , disableDboutFlag integer := null
);



/* group: ���������� ������� ������ */

/* pfunc: getOpenContextLogId
  ���������� Id ������ ���� �������� �������� (���������� ���������)
  ���������� ��������� (null ��� ���������� �������� ���������� ���������).

  ( <body::getOpenContextLogId>)
*/
function getOpenContextLogId
return integer;

/* pfunc: getLoggerUid
  ���������� ���������� ������������� ������.
  ��� ���������� ���������������� ������ ������� �����.

  ���������:
  loggerName                  - ��� ������
                                (�� ��������� ����������� �� moduleName �
                                objectName)
  moduleName                  - ��� ������
                                (�� ��������� ���������� �� loggerName)
  objectName                  - ��� ������� � ������ (������, ����, �������)
                                (�� ��������� ���������� �� loggerName)
  findModuleString            - ������ ��� ����������� Id ������ � ModuleInfo
                                (����� ��������� � ����� �� ���� ���������
                                ������: ���������, ����� � ��������� ��������,
                                �������������� ����� � ��������� �������� �
                                Subversion)
                                (�� ��������� ������������ moduleName)

  �������:
  - ������������� ������������� ������

  ( <body::getLoggerUid>)
*/
function getLoggerUid(
  loggerName varchar2
  , moduleName varchar2
  , objectName varchar2
  , findModuleString varchar2
)
return varchar2;

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

/* pfunc: mergeContextType
  ������� ��� ��������� ��� ���������.

  ���������:
  loggerUid                   - ������������� ������
  contextTypeShortName        - ������� ������������ ���� ���������
  contextTypeName             - ������������ ���� ���������
  nestedFlag                  - ���� ���������� ��������� (1 ��, 0 ���)
  contextTypeDescription      - �������� ���� ���������
  temporaryFlag               - ���� ���������� ���� ���������
                                (1 ��, 0 ��� (�� ���������))

  �������:
  - ���� �������� ��������� (0 ��� ���������, 1 ���� ��������� �������)

  ( <body::mergeContextType>)
*/
function mergeContextType(
  loggerUid varchar2
  , contextTypeShortName varchar2
  , contextTypeName varchar2
  , nestedFlag integer
  , contextTypeDescription varchar2
  , temporaryFlag integer := null
)
return integer;

/* pproc: deleteContextType
  ������� ��� ���������.

  ���������:
  loggerUid                   - ������������� ������
  contextTypeShortName        - ������� ������������ ���� ���������

  ���������:
  - ��� ���������� ������������� � ���� ������ ��������� ���������, �����
    �������� ���� ����������� ��������;

  ( <body::deleteContextType>)
*/
procedure deleteContextType(
  loggerUid varchar2
  , contextTypeShortName varchar2
);

end pkg_LoggingInternal;
/

