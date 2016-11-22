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
  loggerUid varchar2(250),

/* func: lg_logger_t
  Создает логер.

  Параметры:
  loggerName                  - имя логера

  Возврат:
  - созданный объект

  Замечания:
  - функция не должна вызываться явно, более адекватно использовать функции
    getLogger;
  - вызывает функцию <pkg_LoggingInternal.GetLoggerUid>;

  ( <body::lg_logger_t>)
*/
constructor function lg_logger_t(
  loggerName varchar2
)
return self as result,



/* group: Открытые объявления */



/* group: Функции */



/* group: Получение логера */

/* pfunc: getRootLogger
  Возвращает корневой логер.

  Возврат:
  - корневой логер

  ( <body::getRootLogger>)
*/
static function getRootLogger
return lg_logger_t,

/* pfunc: getLogger
  Возвращает логер по полному имени.

  Параметры:
  loggerName                  - имя логера

  Возврат:
  - логер

  Замечания:
  - если в качестве loggerName передан null, возвращает корневой логер;

  ( <body::getLogger>)
*/
static function getLogger(
  loggerName varchar2
)
return lg_logger_t,

/* pfunc: getLoggerName
  Возвращает имя логера по имени модуля и объекта в модуле.

  Параметры:
  moduleName                  - имя модуля
  objectName                  - имя объекта в модуле ( пакета, класса и т.д.)

  Возврат:
  - имя логера

  ( <body::getLoggerName>)
*/
static function getLoggerName(
  moduleName varchar2
  , objectName varchar2
)
return varchar2,

/* pfunc: getLogger( MOD_OBJ)
  Возвращает логер по имени модуля и объекта в модуле.

  Параметры:
  moduleName                  - имя модуля
  objectName                  - имя объекта в модуле ( пакета, класса и т.д.)

  Возврат:
  - логер

  Замечания:
  - если в качестве обоих параметров передан null, возвращает корневой логер;
  - необязательный параметр packageName присутствует для совместимости и не
    должен использоваться ( будет в дальнейшем удален);

  ( <body::getLogger( MOD_OBJ)>)
*/
static function getLogger(
  moduleName varchar2
  , packageName varchar2 := null
  , objectName varchar2
)
return lg_logger_t,

/* pfunc: getLogger( MOD_PKG)
  Устаревшая функция, вместо нее нужно использовать <getLogger( MOD_OBJ)>.

  ( <body::getLogger( MOD_PKG)>)
*/
static function getLogger(
  moduleName varchar2
  , packageName varchar2
)
return lg_logger_t,



/* group: Настройка логера */

/* pfunc: getAdditivity
  Возвращает назначенный флаг аддитивности.

  Замечания:
  - вызывает функцию <pkg_LoggingInternal.getAdditivity>;

  ( <body::getAdditivity>)
*/
member function getAdditivity
return boolean,

/* pproc: setAdditivity
  Устанавливает флаг аддитивности.

  Параметры:
  additive                    - флаг аддитивности

  Замечания:
  - вызывает процедуру <pkg_LoggingInternal.setAdditivity>;

  ( <body::setAdditivity>)
*/
member procedure setAdditivity(
  self in lg_logger_t
  , additive boolean
),

/* pfunc: getLevel
  Возвращает назначенный уровень логирования.

  Замечания:
  - вызывает функцию <pkg_LoggingInternal.getLevel>;

  Возврат:
  - код уровня логирования

  ( <body::getLevel>)
*/
member function getLevel
return varchar2,

/* pproc: setLevel
  Устанавливает уровень логирования.

  Параметры:
  levelCode                   - код уровня логируемых сообщений

  Замечания:
  - вызывает процедуру <pkg_LoggingInternal.setLevel>;

  ( <body::setLevel>)
*/
member procedure setLevel(
  self in lg_logger_t
  , levelCode varchar2
),

/* pfunc: getEffectiveLevel
  Возвращает эффективный уровень логирования.

  Замечания:
  - вызывает функцию <pkg_LoggingInternal.getEffectiveLevel>;

  Возврат:
  - код уровня логирования

  ( <body::getEffectiveLevel>)
*/
member function getEffectiveLevel
return varchar2,

/* pfunc: isEnabledFor
  Возвращает истину, если сообщение данного уровня будет логироваться.

  Параметры:
  levelCode                   - код уровня логирования

  Замечания:
  - вызывает функцию <pkg_LoggingInternal.isEnabledFor>;

  ( <body::isEnabledFor>)
*/
member function isEnabledFor(
  levelCode varchar2
)
return boolean,

/* pfunc: isInfoEnabled
  Возвращает истину, если информационное сообщение будет логироваться.

  Замечания:
  - вызывает функцию <isEnabledFor>;

  ( <body::isInfoEnabled>)
*/
member function isInfoEnabled
return boolean,

/* pfunc: isDebugEnabled
  Возвращает истину, если отладочное сообщение будет логироваться.

  Замечания:
  - вызывает функцию <isEnabledFor>;

  ( <body::isDebugEnabled>)
*/
member function isDebugEnabled
return boolean,

/* pfunc: isTraceEnabled
  Возвращает истину, если трассировочное сообщение будет логироваться.

  Замечания:
  - вызывает функцию <isEnabledFor>;

  ( <body::isTraceEnabled>)
*/
member function isTraceEnabled
return boolean,



/* group: Логирование сообщений */

/* pproc: log
  Логирует сообщение.

  Параметры:
  levelCode                   - код уровня сообщения
  messageText                 - текст сообщения

  Замечания:
  - вызывает процедуру <pkg_LoggingInternal.LogMessage>;

  ( <body::log>)
*/
member procedure log(
  self in lg_logger_t
  , levelCode varchar2
  , messageText varchar2
),

/* pproc: fatal
  Логирует сообщение о фатальной ошибке с уровнем <pkg_Logging.Fatal_LevelCode>.

  Параметры:
  messageText                 - текст сообщения

  Замечания:
  - вызывает процедуру <log>;

  ( <body::fatal>)
*/
member procedure fatal(
  self in lg_logger_t
  , messageText varchar2
),

/* pproc: error
  Логирует сообщение об ошибке с уровнем <pkg_Logging.Error_LevelCode>.

  Параметры:
  messageText                 - текст сообщения

  Замечания:
  - вызывает процедуру <log>;

  ( <body::error>)
*/
member procedure error(
  self in lg_logger_t
  , messageText varchar2
),

/* pproc: warn
  Логирует предупреждающее сообщение с уровнем <pkg_Logging.Warning_LevelCode>.

  Параметры:
  messageText                 - текст сообщения

  Замечания:
  - вызывает процедуру <log>;

  ( <body::warn>)
*/
member procedure warn(
  self in lg_logger_t
  , messageText varchar2
),

/* pproc: info
  Логирует информационое сообщение с уровнем <pkg_Logging.Info_LevelCode>.

  Параметры:
  messageText                 - текст сообщения

  Замечания:
  - вызывает процедуру <log>;

  ( <body::info>)
*/
member procedure info(
  self in lg_logger_t
  , messageText varchar2
),

/* pproc: debug
  Логирует отладочное сообщение с уровнем <pkg_Logging.Debug_LevelCode>.

  Параметры:
  messageText                 - текст сообщения

  Замечания:
  - вызывает процедуру <log>;

  ( <body::debug>)
*/
member procedure debug(
  self in lg_logger_t
  , messageText varchar2
),

/* pproc: trace
  Логирует трассировочное сообщение с уровнем <pkg_Logging.Trace_LevelCode>.

  Параметры:
  messageText                 - текст сообщения

  Замечания:
  - вызывает процедуру <log>;

  ( <body::trace>)
*/
member procedure trace(
  self in lg_logger_t
  , messageText varchar2
),



/* group: Стек ошибок ( исключений)*/

/* pfunc: errorStack
  Сохраняет сообщение в стек ошибок
  и возвращает строку для генерации исключения.

  Параметры:
  messageText                 - текст сообщения

  Возврат:
  - соообщение для генерации исключения
    ( второй аргумент для raise_application_error).
    В простейшем случае, то есть в случае
    достаточно короткого сообщения
    ( см. <pkg_LoggingErrorStack::body::Stack_Message_Limit>)
    возвращает messageText

  Замечания:
  - вызывает процедуру <pkg_LoggingErrorStack.ProcessStackElement>;
  - см. также <Описание::Логирование стека ошибок>;

  ( <body::errorStack>)
*/
member function errorStack(
  messageText varchar2
)
return varchar2,

/* pfunc: remoteErrorStack
  Сохраняет сообщение в стек ошибок, учитывая
  возможные данные о стеке на удалённой БД,
  и возвращает строку для генерации исключения.

  Параметры:
  messageText                 - текст сообщения

  Возврат:
  - соообщение для генерации исключения
    ( второй аргумент для raise_application_error).
    В простейшем случае, то есть в случае
    достаточно короткого сообщения
    ( см. <pkg_LoggingErrorStack::body::Stack_Message_Limit>)
    возвращает messageText

  Замечания:
  - вызывает процедуру <pkg_LoggingErrorStack.ProcessRemoteStackElement>;
  - в удалённой базе рекомендуется установить актуальную версию
    модуля Logging;
  - перед вызовом рекомендуется откатить распределённую транзакцию;
  - см. также <Описание::Логирование стека ошибок>;

  ( <body::remoteErrorStack>)
*/
member function remoteErrorStack(
  messageText varchar2
  , dbLink varchar2
)
return varchar2,

/* pfunc: getErrorStack
  Получает строку стека ошибок и очищает информацию о стеке.

  Возврат:
  - стек ошибок

  Замечания:
  - вызывает процедуру <pkg_LoggingErrorStack.getErrorStack>;
  - см. также <Описание::Логирование стека ошибок>;

  ( <body::getErrorStack>)
*/
member function getErrorStack
return varchar2,

/* pproc: clearErrorStack
  Очищает (сбрасывает) предыдущую информацию о стеке ошибок.

  Замечания:
  - вызывает процедуру <pkg_LoggingErrorStack.ClearLastStack>;
  - см. также <Описание::Логирование стека ошибок>;

  ( <body::clearErrorStack>)
*/
member procedure clearErrorStack

)
/
