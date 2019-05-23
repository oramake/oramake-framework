create or replace type
  lg_logger_t
force
as object
(
/* db object type: lg_logger_t
  ����� ( ������������ ����������� � ��������� ��������� ���������).

  SVN root: Oracle/Module/Logging
*/



/* group: �������� ���������� */

/* ivar: loggerUid
  ���������� ������������� ������.
*/
loggerUid varchar2(250),



/* group: ������� */



/* group: �������� ���������� */

/* pfunc: lg_logger_t
  ������� �����.

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
  - ��������� ������

  ���������:
  - ������� �� ������ ���������� ����, ����� ��������� ������������ �������
    getLogger;
  - �������� ������� <pkg_LoggingInternal.getLoggerUid>;

  ( <body::lg_logger_t>)
*/
constructor function lg_logger_t(
  loggerName varchar2
  , moduleName varchar2 := null
  , objectName varchar2 := null
  , findModuleString varchar2 := null
)
return self as result,



/* group: ������ ����������� */

/* pfunc: getOffLevelCode
  ���������� ��� ������ ����������� "����������� ���������".

  ( <body::getOffLevelCode>)
*/
static function getOffLevelCode
return varchar2,

/* pfunc: getFatalLevelCode
  ���������� ��� ������ ����������� "��������� ������".

  ( <body::getFatalLevelCode>)
*/
static function getFatalLevelCode
return varchar2,

/* pfunc: getErrorLevelCode
  ���������� ��� ������ ����������� "������".

  ( <body::getErrorLevelCode>)
*/
static function getErrorLevelCode
return varchar2,

/* pfunc: getWarnLevelCode
  ���������� ��� ������ ����������� "��������������".

  ( <body::getWarnLevelCode>)
*/
static function getWarnLevelCode
return varchar2,

/* pfunc: getInfoLevelCode
  ���������� ��� ������ ����������� "����������".

  ( <body::getInfoLevelCode>)
*/
static function getInfoLevelCode
return varchar2,

/* pfunc: getDebugLevelCode
  ���������� ��� ������ ����������� "�������".

  ( <body::getDebugLevelCode>)
*/
static function getDebugLevelCode
return varchar2,

/* pfunc: getTraceLevelCode
  ���������� ��� ������ ����������� "�����������".

  ( <body::getTraceLevelCode>)
*/
static function getTraceLevelCode
return varchar2,

/* pfunc: getAllLevelCode
  ���������� ��� ������ ����������� "������������ ������� �����������".

  ( <body::getAllLevelCode>)
*/
static function getAllLevelCode
return varchar2,



/* group: ��������������� ������� */

/* pfunc: getOpenContextLogId
  ���������� Id ������ ���� �������� �������� (���������� ���������)
  ���������� ��������� (null ��� ���������� �������� ���������� ���������).

  ( <body::getOpenContextLogId>)
*/
static function getOpenContextLogId
return integer,



/* group: ��������� ������ */

/* pfunc: getRootLogger
  ���������� �������� �����.

  �������:
  - �������� �����

  ( <body::getRootLogger>)
*/
static function getRootLogger
return lg_logger_t,

/* pfunc: getLoggerName
  ���������� ��� ������ �� ����� ������ � ������� � ������.

  ���������:
  moduleName                  - ��� ������
  objectName                  - ��� ������� � ������ (������, ����, �������)

  �������:
  - ��� ������

  ( <body::getLoggerName>)
*/
static function getLoggerName(
  moduleName varchar2
  , objectName varchar2
)
return varchar2,

/* pfunc: getLogger
  ���������� ����� �� ����� ���� �� ����� ������ � ������� � ������.

  ���������:
  loggerName                  - ��� ������
                                (�� ��������� ����������� �� moduleName �
                                 objectName)
  objectName                  - ��� ������� � ������ (������, ����, �������)
                                (�� ��������� �����������)
  moduleName                  - ��� ������
                                (�� ��������� ��� ������������� ������� ��
                                loggerName ���� ������ objectName)
  findModuleString            - ������ ��� ����������� Id ������ � ModuleInfo
                                (����� ��������� � ����� �� ���� ���������
                                ������: ���������, ����� � ��������� ��������,
                                �������������� ����� � ��������� �������� �
                                Subversion)
                                (�� ��������� ������������ moduleName)

  �������:
  - �����

  ���������:
  - ���� � �������� �������� ���������� ������� null, ���������� ��������
    ����� (����� ��������� � ���� ������ �������� ������������� �������
    <getRootLogger>);
  - ���������������� ��������� �������� �������� moduleName � �����������
    objectName ������ ������������� loggerName;
  - ��� ������������� loggerName ����� ������ �� ������ ����� ��������� ������
    ������ (moduleName), �������� ����� ������ (����� ������ �����) ���������
    ������ ������� � ������ (objectName);
  - �������������� �������� packageName ������������ ��� ������������� � ��
    ������ ��������������, ������ ���� ������� ������������ objectName;

  ( <body::getLogger>)
*/
static function getLogger(
  loggerName varchar2 := null
  , objectName varchar2 := null
  , moduleName varchar2 := null
  , findModuleString varchar2 := null
  , packageName varchar2 := null
)
return lg_logger_t,



/* group: ��������� ������ */

/* pfunc: getLevel
  ���������� ����������� ������� �����������.

  ���������:
  - �������� ������� <pkg_LoggingInternal.getLevel>;

  �������:
  - ��� ������ �����������

  ( <body::getLevel>)
*/
member function getLevel
return varchar2,

/* pproc: setLevel
  ������������� ������� �����������.

  ���������:
  levelCode                   - ��� ������ ���������� ���������

  ���������:
  - �������� ��������� <pkg_LoggingInternal.setLevel>;

  ( <body::setLevel>)
*/
member procedure setLevel(
  self in lg_logger_t
  , levelCode varchar2
),

/* pfunc: getEffectiveLevel
  ���������� ����������� ������� �����������.

  ���������:
  - �������� ������� <pkg_LoggingInternal.getEffectiveLevel>;

  �������:
  - ��� ������ �����������

  ( <body::getEffectiveLevel>)
*/
member function getEffectiveLevel
return varchar2,

/* pfunc: isEnabledFor
  ���������� ������, ���� ��������� ������� ������ ����� ������������.

  ���������:
  levelCode                   - ��� ������ �����������

  ���������:
  - �������� ������� <pkg_LoggingInternal.isEnabledFor>;

  ( <body::isEnabledFor>)
*/
member function isEnabledFor(
  levelCode varchar2
)
return boolean,

/* pfunc: isInfoEnabled
  ���������� ������, ���� �������������� ��������� ����� ������������.

  ���������:
  - �������� ������� <isEnabledFor>;

  ( <body::isInfoEnabled>)
*/
member function isInfoEnabled
return boolean,

/* pfunc: isDebugEnabled
  ���������� ������, ���� ���������� ��������� ����� ������������.

  ���������:
  - �������� ������� <isEnabledFor>;

  ( <body::isDebugEnabled>)
*/
member function isDebugEnabled
return boolean,

/* pfunc: isTraceEnabled
  ���������� ������, ���� �������������� ��������� ����� ������������.

  ���������:
  - �������� ������� <isEnabledFor>;

  ( <body::isTraceEnabled>)
*/
member function isTraceEnabled
return boolean,



/* group: ����������� ��������� */

/* pproc: log
  �������� ��������� � ��������� �������.

  ���������:
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������
  messageValue                - ������������� ��������, ��������� � ����������
                                (�� ��������� �����������)
  messageLabel                - ��������� ��������, ��������� � ����������
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

  ( <body::log>)
*/
member procedure log(
  self in lg_logger_t
  , levelCode varchar2
  , messageText varchar2
  , messageValue integer := null
  , messageLabel varchar2 := null
  , contextTypeShortName varchar2 := null
  , contextValueId integer := null
  , openContextFlag integer := null
  , contextTypeModuleId integer := null
),

/* pproc: fatal
  �������� ��������� � ��������� ������ (������ <getFatalLevelCode>).

  ���������:
  messageText                 - ����� ���������
  ...                         - �������������� ���������, ����������
                                �������������� ���������� ��������� <log>

  ( <body::fatal>)
*/
member procedure fatal(
  self in lg_logger_t
  , messageText varchar2
  , messageValue integer := null
  , messageLabel varchar2 := null
  , contextTypeShortName varchar2 := null
  , contextValueId integer := null
  , openContextFlag integer := null
  , contextTypeModuleId integer := null
),

/* pproc: error
  �������� ��������� �� ������ (������ <getErrorLevelCode>).

  ���������:
  messageText                 - ����� ���������
  ...                         - �������������� ���������, ����������
                                �������������� ���������� ��������� <log>

  ( <body::error>)
*/
member procedure error(
  self in lg_logger_t
  , messageText varchar2
  , messageValue integer := null
  , messageLabel varchar2 := null
  , contextTypeShortName varchar2 := null
  , contextValueId integer := null
  , openContextFlag integer := null
  , contextTypeModuleId integer := null
),

/* pproc: warn
  �������� ��������������� ��������� (������ <getWarnLevelCode>).

  ���������:
  messageText                 - ����� ���������
  ...                         - �������������� ���������, ����������
                                �������������� ���������� ��������� <log>

  ( <body::warn>)
*/
member procedure warn(
  self in lg_logger_t
  , messageText varchar2
  , messageValue integer := null
  , messageLabel varchar2 := null
  , contextTypeShortName varchar2 := null
  , contextValueId integer := null
  , openContextFlag integer := null
  , contextTypeModuleId integer := null
),

/* pproc: info
  �������� ������������� ��������� (������ <getInfoLevelCode>).

  ���������:
  messageText                 - ����� ���������
  ...                         - �������������� ���������, ����������
                                �������������� ���������� ��������� <log>

  ( <body::info>)
*/
member procedure info(
  self in lg_logger_t
  , messageText varchar2
  , messageValue integer := null
  , messageLabel varchar2 := null
  , contextTypeShortName varchar2 := null
  , contextValueId integer := null
  , openContextFlag integer := null
  , contextTypeModuleId integer := null
),

/* pproc: debug
  �������� ���������� ��������� (������ <getDebugLevelCode>).

  ���������:
  messageText                 - ����� ���������
  ...                         - �������������� ���������, ����������
                                �������������� ���������� ��������� <log>

  ( <body::debug>)
*/
member procedure debug(
  self in lg_logger_t
  , messageText varchar2
  , messageValue integer := null
  , messageLabel varchar2 := null
  , contextTypeShortName varchar2 := null
  , contextValueId integer := null
  , openContextFlag integer := null
  , contextTypeModuleId integer := null
),

/* pproc: trace
  �������� �������������� ��������� (������ <getTraceLevelCode>).

  ���������:
  messageText                 - ����� ���������
  ...                         - �������������� ���������, ����������
                                �������������� ���������� ��������� <log>

  ( <body::trace>)
*/
member procedure trace(
  self in lg_logger_t
  , messageText varchar2
  , messageValue integer := null
  , messageLabel varchar2 := null
  , contextTypeShortName varchar2 := null
  , contextValueId integer := null
  , openContextFlag integer := null
  , contextTypeModuleId integer := null
),



/* group: ���� ������ ( ����������) */

/* pfunc: errorStack
  ��������� ��������� � ���� ������
  � ���������� ������ ��� ��������� ����������.

  ���������:
  messageText                 - ����� ���������
  closeContextTypeShortName   - ������� ������������ ���� ������������
                                ��������� ����������
                                (�� ��������� �����������)
  contextValueId              - �������������, ��������� � �����������
                                ���������� ����������
                                (�� ��������� �����������)
  contextTypeModuleId         - Id ������ � ModuleInfo, � �������� ���������
                                ����������� �������� ���������� (�� ���������
                                Id ������, � �������� ��������� �����)
  levelCode                   - ��� ������ ��������� � �������� ���������
                                ����������
                                (�� ��������� "������" ("ERROR"))
  messageValue                - ������������� ��������, ��������� � ����������
                                � �������� ��������� ����������
                                (�� ��������� �����������)
  messageLabel                - ��������� ��������, ��������� � ����������
                                � �������� ��������� ����������
                                (�� ��������� �����������)

  �������:
  - ���������� ��� ��������� ����������
    ( ������ �������� ��� raise_application_error).
    � ���������� ������, �� ���� � ������
    ���������� ��������� ���������
    ( ��. <pkg_LoggingErrorStack::body::Stack_Message_Limit>)
    ���������� messageText

  ���������:
  - �������� ��������� <pkg_LoggingErrorStack.processStackElement>
    (��. ����� <��������::����������� ����� ������>);
  - ���� ������� �������� closeContextTypeShortName, �� �������������� �����
    ��������� �������� ���������� ��������� ����������, ��� ���� �����������
    ��������� � ������� "�������� ��������� ���������� � ����� � �������:",
    � ����������� messageText � �������� ����� ������, ������������� ��������
    <getErrorStack> (� ��������� isStackPreserved ������� 1), � ����� �
    �������������� �������� levelCode, messageValue � messageLabel;
  - ���� �������� ��������� closeContextTypeShortName �� �������, �� ��������
    ����������� ���������� (������� � contextValueId) �����������;

  ( <body::errorStack>)
*/
member function errorStack(
  messageText varchar2
  , closeContextTypeShortName varchar2 := null
  , contextValueId integer := null
  , contextTypeModuleId integer := null
  , levelCode varchar2 := null
  , messageValue integer := null
  , messageLabel varchar2 := null
)
return varchar2,

/* pfunc: remoteErrorStack
  ��������� ��������� � ���� ������, ��������
  ��������� ������ � ����� �� �������� ��,
  � ���������� ������ ��� ��������� ����������.

  ���������:
  messageText                 - ����� ���������

  �������:
  - ���������� ��� ��������� ����������
    ( ������ �������� ��� raise_application_error).
    � ���������� ������, �� ���� � ������
    ���������� ��������� ���������
    ( ��. <pkg_LoggingErrorStack::body::Stack_Message_Limit>)
    ���������� messageText

  ���������:
  - �������� ��������� <pkg_LoggingErrorStack.ProcessRemoteStackElement>;
  - � �������� ���� ������������� ���������� ���������� ������
    ������ Logging;
  - ����� ������� ������������� �������� ������������� ����������;
  - ��. ����� <��������::����������� ����� ������>;

  ( <body::remoteErrorStack>)
*/
member function remoteErrorStack(
  messageText varchar2
  , dbLink varchar2
)
return varchar2,

/* pfunc: getErrorStack
  �������� ������ ����� ������ � ������� ���������� � �����.

  ���������:
  isStackPreserved            - ��������� �� ������ �� �����. ��-��������� (
                                null) �� ��������� ( �.�. �������), �����
                                ������� ��-��������� ����� ������ ���� ��
                                ����� ���� ������� �����.

  �������:
  - ���� ������

  ���������:
  - �������� ��������� <pkg_LoggingErrorStack.getErrorStack>;
  - ��. ����� <��������::����������� ����� ������>;

  ( <body::getErrorStack>)
*/
member function getErrorStack(
  isStackPreserved integer := null
)
return varchar2,

/* pproc: clearErrorStack
  ������� (����������) ���������� ���������� � ����� ������.

  ���������:
  - �������� ��������� <pkg_LoggingErrorStack.clearLastStack>;
  - ��. ����� <��������::����������� ����� ������>;

  ( <body::clearErrorStack>)
*/
member procedure clearErrorStack,



/* group: ���� ��������� ���������� */

/* pfunc: mergeContextType
  ������� ��� ��������� ��� ��������� ����������.

  ���������:
  contextTypeShortName        - ������� ������������ ���� ���������
  contextTypeName             - ������������ ���� ���������
  nestedFlag                  - ���� ���������� ��������� (1 ��, 0 ���)
  contextTypeDescription      - �������� ���� ���������

  �������:
  - ���� �������� ��������� (0 ��� ���������, 1 ���� ��������� �������)

  ���������:
  - ���������, ��� ��� ��������� ���������� ��������� � ������, � ��������
    ��������� ������� ��������� ������;
  - � ������, ���� ��� ������ �� ��� ��������� Id ������ � ModuleInfo
    (��������, ��� ��������� ������) ���������� ����������� � �������;
  - ��� ��������� ���������� �������������� ������� ����������� (��������
    context_level � context_type_level ������� lg_log), ��� ��������
    ���������� ��������� ���������� ��������� ��������� �������� ������
    (�������� �����) ����������� �������������, ��������� �������� �����������
    � ������ ���������� � ��� �������� (context_value_id), ����������� ���
    ����� ��������;

  ( <body::mergeContextType>)
*/
member function mergeContextType(
  contextTypeShortName varchar2
  , contextTypeName varchar2
  , nestedFlag integer
  , contextTypeDescription varchar2
)
return integer,

/* pproc: mergeContextType( PROC)
  ������� ��� ��������� ��� ��������� ����������.
  ��������� ��������� ������� <mergeContextType> �� ����������� ����������
  ������������� ��������.

  ( <body::mergeContextType( PROC)>)
*/
member procedure mergeContextType(
  self in lg_logger_t
  , contextTypeShortName varchar2
  , contextTypeName varchar2
  , nestedFlag integer
  , contextTypeDescription varchar2
),

/* pproc: deleteContextType
  ������� ��� ��������� ����������.

  ���������:
  contextTypeShortName        - ������� ������������ ���� ���������

  ���������:
  - ���������, ��� ��� ��������� ���������� ��������� � ������, � ��������
    ��������� ������� ��������� ������;
  - ��� ���������� ������������� � ���� ������ ��������� ���������, �����
    �������� ���� ����������� ��������;

  ( <body::deleteContextType>)
*/
member procedure deleteContextType(
  self in lg_logger_t
  , contextTypeShortName varchar2
)

)
/
