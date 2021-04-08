create or replace package pkg_LoggingInternal is
/* package: pkg_LoggingInternal
  Внутренний пакет модуля Logging.

  SVN root: Oracle/Module/Logging
*/



/* group: Функции */



/* group: Использование модуля AccessOperator */

/* pfunc: getCurrentOperatorId
  Возвращает Id текущего зарегистрированного оператора при доступности модуля
  AccessOperator.

  Возврат:
  Id текущего оператора либо null в случае недоступности модуля AccessOperator
  или отсутствии текущего зарегистрированного оператора.

  ( <body::getCurrentOperatorId>)
*/
function getCurrentOperatorId
return integer;



/* group: Настройки логирования */

/* pproc: setDestination
  Устанавливает единственное назначение для вывода.

  Параметры:
  destinationCode             - Код назначения
                                (null для возврата к выводу по умолчанию)

  Замечания:
  - по умолчанию (если не задано единственное назначение для вывода)
    логируемые сообщения добавляются в таблицу <lg_log>, а в тестовых БД
    дополнительно выводятся через пакет dbms_output (если сессия не запущена
    через dbms_job);

  ( <body::setDestination>)
*/
procedure setDestination(
  destinationCode varchar2
);



/* group: Логирование сообщений */

/* pproc: logMessage
  Логирует сообщение.

  Параметры:
  levelCode                   - Код уровня сообщения
  messageText                 - Текст сообщения
  messageValue                - Целочисленное значение, связанное с сообщением
                                (по умолчанию отсутствует)
  messageLabel                - Строковое значение, связанное с сообщением
                                (по умолчанию отсутствует)
  textData                    - Текстовые данные, связанные с сообщением
                                (по умолчанию отсутствуют)
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
  loggerUid                   - Идентификатор логера
                                (по умолчанию корневой логер)
  disableDboutFlag            - Запрет вывода сообщений через dbms_output
                                (в т.ч. порождаемых сообщений об ошибках)
                                (1 да, 0 нет (по умолчанию))


  Замечания:
  - текущая реализация по умолчанию выводит сообщения на промышленной БД
    в таблицу <lg_log>, а на тестовой БД также через dbms_output

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



/* group: Реализация функций логера */

/* pfunc: getOpenContextLogId
  Возвращает Id записи лога открытия текущего (последнего открытого)
  вложенного контекста (null при отсутствии текущего вложенного контекста).

  ( <body::getOpenContextLogId>)
*/
function getOpenContextLogId
return integer;

/* pfunc: getLoggerUid
  Возвращает уникальный идентификатор логера.
  При отсутствии соответствующего логера создает новый.

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
  - идентификатор существующего логера

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
  Возвращает уровень логирования.

  Параметры:
  loggerUid                   - идентификатор логера

  ( <body::getLevel>)
*/
function getLevel(
  loggerUid varchar2
)
return varchar2;

/* pproc: setLevel
  Устанавливает уровень логирования.

  Параметры:
  loggerUid                   - идентификатор логера
  levelCode                   - код уровня логируемых сообщений

  ( <body::setLevel>)
*/
procedure setLevel(
  loggerUid varchar2
  , levelCode varchar2
);

/* pfunc: getEffectiveLevel
  Возвращает эффективный уровень логирования.

  Параметры:
  loggerUid                   - идентификатор логера

  Возврат:
  - код уровня логирования

  Замечания:
  - вызывает функцию <getLoggerEffectiveLevel>;

  ( <body::getEffectiveLevel>)
*/
function getEffectiveLevel(
  loggerUid varchar2
)
return varchar2;

/* pfunc: isEnabledFor
  Возвращает истину, если сообщение данного уровня будет логироваться.

  Параметры:
  loggerUid                   - идентификатор логера
  levelCode                   - код уровня логирования

  Замечания:
  - вызывает функцию <isMessageEnabled>;

  ( <body::isEnabledFor>)
*/
function isEnabledFor(
  loggerUid varchar2
  , levelCode varchar2
)
return boolean;

/* pfunc: mergeContextType
  Создает или обновляет тип контекста.

  Параметры:
  loggerUid                   - Идентификатор логера
  contextTypeShortName        - Краткое наименование типа контекста
  contextTypeName             - Наименование типа контекста
  nestedFlag                  - Флаг вложенного контекста (1 да, 0 нет)
  contextTypeDescription      - Описание типа контекста
  temporaryFlag               - Флаг временного типа контекста
                                (1 да, 0 нет (по умолчанию))

  Возврат:
  - флаг внесения изменений (0 нет изменений, 1 если изменения внесены)

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
  Удаляет тип контекста.

  Параметры:
  loggerUid                   - Идентификатор логера
  contextTypeShortName        - Краткое наименование типа контекста

  Замечания:
  - при отсутствии использования в логе запись удаляется физически, иначе
    ставится флаг логического удаления;

  ( <body::deleteContextType>)
*/
procedure deleteContextType(
  loggerUid varchar2
  , contextTypeShortName varchar2
);

end pkg_LoggingInternal;
/

