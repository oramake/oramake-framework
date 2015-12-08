@oms-drop-type lg_logger_t

create or replace type lg_logger_t
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
  loggerUid varchar2(250)

/* func: lg_logger_t
  ������� �����
  ( <body::lg_logger_t>).
*/
, constructor function lg_logger_t(
    loggerName varchar2
  )
  return self as result



/* group: �������� ���������� */



/* group: ��������� ������ */

/* pfunc: GetRootLogger
  ���������� �������� �����
  ( <body::GetRootLogger>).
*/
, static function GetRootLogger
  return lg_logger_t

/* pfunc: GetLogger
  ���������� ����� �� ������� �����
  ( <body::GetLogger>).
*/
, static function GetLogger(
    loggerName varchar2
  )
  return lg_logger_t

/* func: GetLoggerName
  ���������� ��� ������ �� ����� ������ � ������� � ������.
  ( <body::GetLoggerName>)
*/
, static function GetLoggerName(
    moduleName varchar2
    , objectName varchar2
  )
  return varchar2

/* pfunc: GetLogger( MOD_OBJ)
  ���������� ����� �� ����� ������ � ������� � ������
  ( <body::GetLogger( MOD_OBJ)>).
*/
, static function GetLogger(
    moduleName varchar2
    , packageName varchar2 := null
    , objectName varchar2
  )
  return lg_logger_t

/* pfunc: GetLogger( MOD_PKG)
  ���������� �������, ������ ��� ����� ������������ <GetLogger( MOD_OBJ)>.
*/
, static function GetLogger(
    moduleName varchar2
    , packageName varchar2
  )
  return lg_logger_t



/* group: ��������� ������ */

/* pfunc: GetAdditivity
  ���������� ����������� ���� ������������
  ( <body::GetAdditivity>).
*/
, member function GetAdditivity
  return boolean

/* pproc: SetAdditivity
  ������������� ���� ������������
  ( <body::SetAdditivity>).
*/
, member procedure SetAdditivity(
    self in lg_logger_t
    , additive boolean
  )

/* pfunc: GetLevel
  ���������� ����������� ������� �����������
  ( <body::GetLevel>).
*/
, member function GetLevel
  return varchar2

/* pproc: SetLevel
  ������������� ������� �����������
  ( <body::SetLevel>).
*/
, member procedure SetLevel(
    self in lg_logger_t
    , levelCode varchar2
  )

/* pfunc: GetEffectiveLevel
  ���������� ����������� ������� �����������
  ( <body::GetEffectiveLevel>).
*/
, member function GetEffectiveLevel
  return varchar2

/* pfunc: IsEnabledFor
  ���������� ������, ���� ��������� ������� ������ ����� ������������
  ( <body::IsEnabledFor>).
*/
, member function IsEnabledFor(
    levelCode varchar2
  )
  return boolean

/* pfunc: IsInfoEnabled
  ���������� ������, ���� �������������� ��������� ����� ������������
  ( <body::IsInfoEnabled>).
*/
, member function IsInfoEnabled
  return boolean

/* pfunc: IsDebugEnabled
  ���������� ������, ���� ���������� ��������� ����� ������������
  ( <body::IsDebugEnabled>).
*/
, member function IsDebugEnabled
  return boolean

/* pfunc: IsTraceEnabled
  ���������� ������, ���� �������������� ��������� ����� ������������
  ( <body::IsTraceEnabled>).
*/
, member function IsTraceEnabled
  return boolean



/* group: ����������� ��������� */

/* pproc: Log
  �������� ���������
  ( <body::Log>).
*/
, member procedure Log(
    self in lg_logger_t
    , levelCode varchar2
    , messageText varchar2
  )

/* pproc: Fatal
  �������� ��������� � ��������� ������
  ( <body::Fatal>).
*/
, member procedure Fatal(
    self in lg_logger_t
    , messageText varchar2
  )

/* pproc: Error
  �������� ��������� �� ������
  ( <body::Error>).
*/
, member procedure Error(
    self in lg_logger_t
    , messageText varchar2
  )

/* pproc: Warn
  �������� ��������������� ���������
  ( <body::Warn>).
*/
, member procedure Warn(
    self in lg_logger_t
    , messageText varchar2
  )

/* pproc: Info
  �������� �������������� ���������
  ( <body::Info>).
*/
, member procedure Info(
    self in lg_logger_t
    , messageText varchar2
  )

/* pproc: Debug
  �������� ���������� ���������
  ( <body::Debug>).
*/
, member procedure Debug(
    self in lg_logger_t
    , messageText varchar2
  )

/* pproc: Trace
  �������� �������������� ���������
  ( <body::Trace>).
*/
, member procedure Trace(
    self in lg_logger_t
    , messageText varchar2
  )

/* group: ���� ������ ( ����������)*/

/* pfunc: ErrorStack
  ��������� ��������� � ���� ������
  � ���������� ������ ��� ��������� ����������
  ( <body::ErrorStack>).
*/
, member function ErrorStack(
    messageText varchar2
  )
  return varchar2

/* pfunc: RemoteErrorStack
  ��������� ��������� � ���� ������, ��������
  ��������� ������ � ����� �� �������� ��,
  � ���������� ������ ��� ��������� ����������
  ( <body::RemoteErrorStack>).
*/
, member function RemoteErrorStack(
    messageText varchar2
    , dbLink varchar2
  )
  return varchar2

/* pfunc: GetErrorStack
  �������� ������ ����� ������ � ������� ���������� � �����
  ( <body::GetErrorStack>).
*/
, member function GetErrorStack
  return varchar2

/* pproc: ClearErrorStack
  ������� (���������� ) ���������� ���������� � ����� ������
  ( <body::ClearErrorStack>).
*/
, member procedure ClearErrorStack

)
/
