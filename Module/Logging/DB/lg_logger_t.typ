@oms-drop-type lg_logger_t

create or replace type lg_logger_t
as object
(
/* db object type: lg_logger_t
  Логер ( обеспечивает логирование с указанием источника сообщений).

  SVN root: Oracle/Module/Logging
*/



/* group: Закрытые объявления */

/* ivar: loggerUid
  Уникальный идентификатор логера.
*/
  loggerUid varchar2(250)

/* func: lg_logger_t
  Создает логер
  ( <body::lg_logger_t>).
*/
, constructor function lg_logger_t(
    loggerName varchar2
  )
  return self as result



/* group: Открытые объявления */



/* group: Получение логера */

/* pfunc: GetRootLogger
  Возвращает корневой логер
  ( <body::GetRootLogger>).
*/
, static function GetRootLogger
  return lg_logger_t

/* pfunc: GetLogger
  Возвращает логер по полному имени
  ( <body::GetLogger>).
*/
, static function GetLogger(
    loggerName varchar2
  )
  return lg_logger_t

/* func: GetLoggerName
  Возвращает имя логера по имени модуля и объекта в модуле.
  ( <body::GetLoggerName>)
*/
, static function GetLoggerName(
    moduleName varchar2
    , objectName varchar2
  )
  return varchar2

/* pfunc: GetLogger( MOD_OBJ)
  Возвращает логер по имени модуля и объекта в модуле
  ( <body::GetLogger( MOD_OBJ)>).
*/
, static function GetLogger(
    moduleName varchar2
    , packageName varchar2 := null
    , objectName varchar2
  )
  return lg_logger_t

/* pfunc: GetLogger( MOD_PKG)
  Устаревшая функция, вместо нее нужно использовать <GetLogger( MOD_OBJ)>.
*/
, static function GetLogger(
    moduleName varchar2
    , packageName varchar2
  )
  return lg_logger_t



/* group: Настройка логера */

/* pfunc: GetAdditivity
  Возвращает назначенный флаг аддитивности
  ( <body::GetAdditivity>).
*/
, member function GetAdditivity
  return boolean

/* pproc: SetAdditivity
  Устанавливает флаг аддитивности
  ( <body::SetAdditivity>).
*/
, member procedure SetAdditivity(
    self in lg_logger_t
    , additive boolean
  )

/* pfunc: GetLevel
  Возвращает назначенный уровень логирования
  ( <body::GetLevel>).
*/
, member function GetLevel
  return varchar2

/* pproc: SetLevel
  Устанавливает уровень логирования
  ( <body::SetLevel>).
*/
, member procedure SetLevel(
    self in lg_logger_t
    , levelCode varchar2
  )

/* pfunc: GetEffectiveLevel
  Возвращает эффективный уровень логирования
  ( <body::GetEffectiveLevel>).
*/
, member function GetEffectiveLevel
  return varchar2

/* pfunc: IsEnabledFor
  Возвращает истину, если сообщение данного уровня будет логироваться
  ( <body::IsEnabledFor>).
*/
, member function IsEnabledFor(
    levelCode varchar2
  )
  return boolean

/* pfunc: IsInfoEnabled
  Возвращает истину, если информационное сообщение будет логироваться
  ( <body::IsInfoEnabled>).
*/
, member function IsInfoEnabled
  return boolean

/* pfunc: IsDebugEnabled
  Возвращает истину, если отладочное сообщение будет логироваться
  ( <body::IsDebugEnabled>).
*/
, member function IsDebugEnabled
  return boolean

/* pfunc: IsTraceEnabled
  Возвращает истину, если трассировочное сообщение будет логироваться
  ( <body::IsTraceEnabled>).
*/
, member function IsTraceEnabled
  return boolean



/* group: Логирование сообщений */

/* pproc: Log
  Логирует сообщение
  ( <body::Log>).
*/
, member procedure Log(
    self in lg_logger_t
    , levelCode varchar2
    , messageText varchar2
  )

/* pproc: Fatal
  Логирует сообщение о фатальной ошибке
  ( <body::Fatal>).
*/
, member procedure Fatal(
    self in lg_logger_t
    , messageText varchar2
  )

/* pproc: Error
  Логирует сообщение об ошибке
  ( <body::Error>).
*/
, member procedure Error(
    self in lg_logger_t
    , messageText varchar2
  )

/* pproc: Warn
  Логирует предупреждающее сообщение
  ( <body::Warn>).
*/
, member procedure Warn(
    self in lg_logger_t
    , messageText varchar2
  )

/* pproc: Info
  Логирует информационное сообщение
  ( <body::Info>).
*/
, member procedure Info(
    self in lg_logger_t
    , messageText varchar2
  )

/* pproc: Debug
  Логирует отладочное сообщение
  ( <body::Debug>).
*/
, member procedure Debug(
    self in lg_logger_t
    , messageText varchar2
  )

/* pproc: Trace
  Логирует трассировочное сообщение
  ( <body::Trace>).
*/
, member procedure Trace(
    self in lg_logger_t
    , messageText varchar2
  )

/* group: Стек ошибок ( исключений)*/

/* pfunc: ErrorStack
  Сохраняет сообщение в стек ошибок
  и возвращает строку для генерации исключения
  ( <body::ErrorStack>).
*/
, member function ErrorStack(
    messageText varchar2
  )
  return varchar2

/* pfunc: RemoteErrorStack
  Сохраняет сообщение в стек ошибок, учитывая
  возможные данные о стеке на удалённой БД,
  и возвращает строку для генерации исключения
  ( <body::RemoteErrorStack>).
*/
, member function RemoteErrorStack(
    messageText varchar2
    , dbLink varchar2
  )
  return varchar2

/* pfunc: GetErrorStack
  Получает строку стека ошибок и очищает информацию о стеке
  ( <body::GetErrorStack>).
*/
, member function GetErrorStack
  return varchar2

/* pproc: ClearErrorStack
  Очищает (сбрасывает ) предыдущую информацию о стеке ошибок
  ( <body::ClearErrorStack>).
*/
, member procedure ClearErrorStack

)
/
