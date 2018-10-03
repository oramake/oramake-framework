create or replace type
  lg_logger_t
force
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



/* group: Функции */



/* group: Закрытые объявления */

/* pfunc: lg_logger_t
  Создает логер.

  Параметры:
  loggerName                  - Имя логера
                                (по умолчанию формируется из moduleName и
                                objectName)
  moduleName                  - Имя модуля
                                (по умолчанию выделяется из loggerName)
  objectName                  - Имя объекта в модуле (пакета, типа, скрипта)
                                (по умолчанию выделяется из loggerName)
  findModuleString            - Строка для определения Id модуля в ModuleInfo
                                (может совпадать с одним из трех атрибутов
                                модуля: названием, путем к корневому каталогу,
                                первоначальным путем к корневому каталогу в
                                Subversion)
                                (по умолчанию используется moduleName)

  Возврат:
  - созданный объект

  Замечания:
  - функция не должна вызываться явно, более адекватно использовать функции
    getLogger;
  - вызывает функцию <pkg_LoggingInternal.getLoggerUid>;

  ( <body::lg_logger_t>)
*/
constructor function lg_logger_t(
  loggerName varchar2
  , moduleName varchar2 := null
  , objectName varchar2 := null
  , findModuleString varchar2 := null
)
return self as result,



/* group: Открытые объявления */

/* pfunc: getOffLevelCode
  Возвращает код уровня логирования "Логирование отключено".

  ( <body::getOffLevelCode>)
*/
static function getOffLevelCode
return varchar2,

/* pfunc: getFatalLevelCode
  Возвращает код уровня логирования "Фатальная ошибка".

  ( <body::getFatalLevelCode>)
*/
static function getFatalLevelCode
return varchar2,

/* pfunc: getErrorLevelCode
  Возвращает код уровня логирования "Ошибка".

  ( <body::getErrorLevelCode>)
*/
static function getErrorLevelCode
return varchar2,

/* pfunc: getWarnLevelCode
  Возвращает код уровня логирования "Предупреждение".

  ( <body::getWarnLevelCode>)
*/
static function getWarnLevelCode
return varchar2,

/* pfunc: getInfoLevelCode
  Возвращает код уровня логирования "Информация".

  ( <body::getInfoLevelCode>)
*/
static function getInfoLevelCode
return varchar2,

/* pfunc: getDebugLevelCode
  Возвращает код уровня логирования "Отладка".

  ( <body::getDebugLevelCode>)
*/
static function getDebugLevelCode
return varchar2,

/* pfunc: getTraceLevelCode
  Возвращает код уровня логирования "Трассировка".

  ( <body::getTraceLevelCode>)
*/
static function getTraceLevelCode
return varchar2,

/* pfunc: getAllLevelCode
  Возвращает код уровня логирования "Максимальный уровень логирования".

  ( <body::getAllLevelCode>)
*/
static function getAllLevelCode
return varchar2,



/* group: Получение логера */

/* pfunc: getRootLogger
  Возвращает корневой логер.

  Возврат:
  - корневой логер

  ( <body::getRootLogger>)
*/
static function getRootLogger
return lg_logger_t,

/* pfunc: getLoggerName
  Возвращает имя логера по имени модуля и объекта в модуле.

  Параметры:
  moduleName                  - Имя модуля
  objectName                  - Имя объекта в модуле (пакета, типа, скрипта)

  Возврат:
  - имя логера

  ( <body::getLoggerName>)
*/
static function getLoggerName(
  moduleName varchar2
  , objectName varchar2
)
return varchar2,

/* pfunc: getLogger
  Возвращает логер по имени либо по имени модуля и объекта в модуле.

  Параметры:
  loggerName                  - Имя логера
                                (по умолчанию формируется из moduleName и
                                 objectName)
  objectName                  - Имя объекта в модуле (пакета, типа, скрипта)
                                (по умолчанию отсутствует)
  moduleName                  - Имя модуля
                                (по умолчанию для совместимости берется из
                                loggerName если указан objectName)
  findModuleString            - Строка для определения Id модуля в ModuleInfo
                                (может совпадать с одним из трех атрибутов
                                модуля: названием, путем к корневому каталогу,
                                первоначальным путем к корневому каталогу в
                                Subversion)
                                (по умолчанию используется moduleName)

  Возврат:
  - логер

  Замечания:
  - если в качестве значений параметров передан null, возвращает корневой
    логер (более очевидным в этом случае является использование функции
    <getRootLogger>);
  - предпочтительным вариантом является указание moduleName и опционально
    objectName вместо использования loggerName;
  - при использовании loggerName часть строки до первой точки считается именем
    модуля (moduleName), оставшая часть строки (после первой точки) считается
    именем объекта в модуле (objectName);
  - необязательный параметр packageName присутствует для совместимости и не
    должен использоваться, вместо него следует использовать objectName;

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
  Логирует сообщение с указанным уровнем.

  Параметры:
  levelCode                   - код уровня сообщения
  messageText                 - текст сообщения

  ( <body::log>)
*/
member procedure log(
  self in lg_logger_t
  , levelCode varchar2
  , messageText varchar2
),

/* pproc: fatal
  Логирует сообщение о фатальной ошибке ( уровня <getFatalLevelCode>).

  Параметры:
  messageText                 - текст сообщения

  ( <body::fatal>)
*/
member procedure fatal(
  self in lg_logger_t
  , messageText varchar2
),

/* pproc: error
  Логирует сообщение об ошибке ( уровня <getErrorLevelCode>).

  Параметры:
  messageText                 - текст сообщения

  ( <body::error>)
*/
member procedure error(
  self in lg_logger_t
  , messageText varchar2
),

/* pproc: warn
  Логирует предупреждающее сообщение ( уровня <getWarnLevelCode>).

  Параметры:
  messageText                 - текст сообщения

  ( <body::warn>)
*/
member procedure warn(
  self in lg_logger_t
  , messageText varchar2
),

/* pproc: info
  Логирует информационое сообщение ( уровня <getInfoLevelCode>).

  Параметры:
  messageText                 - текст сообщения

  ( <body::info>)
*/
member procedure info(
  self in lg_logger_t
  , messageText varchar2
),

/* pproc: debug
  Логирует отладочное сообщение ( уровня <getDebugLevelCode>).

  Параметры:
  messageText                 - текст сообщения

  ( <body::debug>)
*/
member procedure debug(
  self in lg_logger_t
  , messageText varchar2
),

/* pproc: trace
  Логирует трассировочное сообщение ( уровня <getTraceLevelCode>).

  Параметры:
  messageText                 - текст сообщения

  ( <body::trace>)
*/
member procedure trace(
  self in lg_logger_t
  , messageText varchar2
),



/* group: Стек ошибок ( исключений) */

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
  - вызывает процедуру <pkg_LoggingErrorStack.processStackElement>;
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

  Параметры:
  isStackPreserved            - оставлять ли данные по стеку. По-умолчанию (
                                null) не оставлять ( т.е. очищать), таким
                                образом по-умолчанию после вызова стек не
                                может быть соединён далее.

  Возврат:
  - стек ошибок

  Замечания:
  - вызывает процедуру <pkg_LoggingErrorStack.getErrorStack>;
  - см. также <Описание::Логирование стека ошибок>;

  ( <body::getErrorStack>)
*/
member function getErrorStack(
  isStackPreserved integer := null
)
return varchar2,

/* pproc: clearErrorStack
  Очищает (сбрасывает) предыдущую информацию о стеке ошибок.

  Замечания:
  - вызывает процедуру <pkg_LoggingErrorStack.clearLastStack>;
  - см. также <Описание::Логирование стека ошибок>;

  ( <body::clearErrorStack>)
*/
member procedure clearErrorStack

)
/
