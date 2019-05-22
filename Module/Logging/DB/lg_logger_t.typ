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



/* group: Уровни логирования */

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



/* group: Вспомогательные функции */

/* pfunc: getOpenContextLogId
  Возвращает Id записи лога открытия текущего (последнего открытого)
  вложенного контекста (null при отсутствии текущего вложенного контекста).

  ( <body::getOpenContextLogId>)
*/
static function getOpenContextLogId
return integer,



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
  levelCode                   - Код уровня сообщения
  messageText                 - Текст сообщения
  messageValue                - Целочисленное значение, связанное с сообщением
                                (по умолчанию отсутствует)
  messageLabel                - Строковое значение, связанное с сообщением
                                (по умолчанию отсутствует)
  contextTypeShortName        - Краткое наименование типа
                                открываемого/закрываемого контекста выполнения
                                (по умолчанию отсутствует)
  contextValueId              - Идентификатор, связанный с
                                открываемым/закрываемым контекстом выполнения
                                (по умолчанию отсутствует)
  openContextFlag             - Флаг открытия контекста выполнения
                                (1 открытие контекста, 0 закрытие контекста,
                                -1 открытие и немедленное закрытие контекста,
                                null контекст не меняется)
                                (по умолчанию -1 если указан
                                contextTypeShortName, иначе null)
  contextTypeModuleId         - Id модуля в ModuleInfo, к которому относится
                                открываемый/закрываемый контекст выполнения
                                (по умолчанию Id модуля, к которому относится
                                логер)

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
  Логирует сообщение о фатальной ошибке (уровня <getFatalLevelCode>).

  Параметры:
  messageText                 - Текст сообщения
  ...                         - Необязательные параметры, идентичные
                                необязательным параметрам процедуры <log>

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
  Логирует сообщение об ошибке (уровня <getErrorLevelCode>).

  Параметры:
  messageText                 - Текст сообщения
  ...                         - Необязательные параметры, идентичные
                                необязательным параметрам процедуры <log>

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
  Логирует предупреждающее сообщение (уровня <getWarnLevelCode>).

  Параметры:
  messageText                 - Текст сообщения
  ...                         - Необязательные параметры, идентичные
                                необязательным параметрам процедуры <log>

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
  Логирует информационое сообщение (уровня <getInfoLevelCode>).

  Параметры:
  messageText                 - Текст сообщения
  ...                         - Необязательные параметры, идентичные
                                необязательным параметрам процедуры <log>

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
  Логирует отладочное сообщение (уровня <getDebugLevelCode>).

  Параметры:
  messageText                 - Текст сообщения
  ...                         - Необязательные параметры, идентичные
                                необязательным параметрам процедуры <log>

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
  Логирует трассировочное сообщение (уровня <getTraceLevelCode>).

  Параметры:
  messageText                 - Текст сообщения
  ...                         - Необязательные параметры, идентичные
                                необязательным параметрам процедуры <log>

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



/* group: Стек ошибок ( исключений) */

/* pfunc: errorStack
  Сохраняет сообщение в стек ошибок
  и возвращает строку для генерации исключения.

  Параметры:
  messageText                 - текст сообщения
  closeContextTypeShortName   - Краткое наименование типа закрываемого
                                контекста выполнения
                                (по умолчанию отсутствует)
  contextValueId              - Идентификатор, связанный с закрываемым
                                контекстом выполнения
                                (по умолчанию отсутствует)
  contextTypeModuleId         - Id модуля в ModuleInfo, к которому относится
                                закрываемый контекст выполнения (по умолчанию
                                Id модуля, к которому относится логер)
  levelCode                   - Код уровня сообщения о закрытии контекста
                                выполнения
                                (по умолчанию "Ошибка" ("ERROR"))
  messageValue                - Целочисленное значение, связанное с сообщением
                                о закрытии контекста выполнения
                                (по умолчанию отсутствует)
  messageLabel                - Строковое значение, связанное с сообщением
                                о закрытии контекста выполнения
                                (по умолчанию отсутствует)

  Возврат:
  - соообщение для генерации исключения
    ( второй аргумент для raise_application_error).
    В простейшем случае, то есть в случае
    достаточно короткого сообщения
    ( см. <pkg_LoggingErrorStack::body::Stack_Message_Limit>)
    возвращает messageText

  Замечания:
  - вызывает процедуру <pkg_LoggingErrorStack.processStackElement>
    (см. также <Описание::Логирование стека ошибок>);
  - если указано значение closeContextTypeShortName, то предварительно будет
    выполнено закрытие указанного контекста выполнения, при этом формируется
    сообщение с текстом "Закрытие контекста выполнения в связи с ошибкой:",
    с добавлением messageText и текущего стека ошибок, возвращаемого функцией
    <getErrorStack> (с указанием isStackPreserved равного 1), а также с
    использованием значений levelCode, messageValue и messageLabel;
  - если значение параметра closeContextTypeShortName не указано, то значения
    последующих параметров (начиная с contextValueId) игнориуются;

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
member procedure clearErrorStack,



/* group: Типы контекста выполнения */

/* pfunc: mergeContextType
  Создает или обновляет тип контекста выполнения.

  Параметры:
  contextTypeShortName        - Краткое наименование типа контекста
  contextTypeName             - Наименование типа контекста
  nestedFlag                  - Флаг вложенного контекста (1 да, 0 нет)
  contextTypeDescription      - Описание типа контекста

  Возврат:
  - флаг внесения изменений (0 нет изменений, 1 если изменения внесены)

  Замечания:
  - считается, что тип контекста выполнения относится к модулю, к которому
    относится текущий экземпляр логера;
  - в случае, если для логера не был определен Id модуля в ModuleInfo
    (например, для корневого логера) выполнение завершается с ошибкой;
  - для вложенных контекстов подсчитывается уровень вложенности (значения
    context_level и context_type_level таблицы lg_log), при закрытии
    вложенного контекста незакрытые вложенные контексты большего уровня
    (открытые позже) закрываются автоматически, вложенный контекст закрывается
    с учетом связанного с ним значения (context_value_id), невложенный без
    учета значения;

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
  Создает или обновляет тип контекста выполнения.
  Процедура идентична функции <mergeContextType> за исключением отсутствия
  возвращаемого значения.

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
  Удаляет тип контекста выполнения.

  Параметры:
  contextTypeShortName        - Краткое наименование типа контекста

  Замечания:
  - считается, что тип контекста выполнения относится к модулю, к которому
    относится текущий экземпляр логера;
  - при отсутствии использования в логе запись удаляется физически, иначе
    ставится флаг логического удаления;

  ( <body::deleteContextType>)
*/
member procedure deleteContextType(
  self in lg_logger_t
  , contextTypeShortName varchar2
)

)
/
