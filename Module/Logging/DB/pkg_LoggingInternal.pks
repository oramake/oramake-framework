create or replace package pkg_LoggingInternal is
/* package: pkg_LoggingInternal
  Внутренний пакет модуля Logging.

  SVN root: Oracle/Module/Logging
*/



/* group: Функции */



/* group: Настройки логирования */

/* pproc: setDestination
  Устанавливает единственное назначения для вывода.

  Параметры:
  destinationCode             - код назначения

  ( <body::setDestination>)
*/
procedure setDestination(
  destinationCode varchar2
);



/* group: Логирование сообщений */

/* pproc: logMessage
  Логирует сообщение.

  Параметры:
  levelCode                   - код уровня сообщения
  messageText                 - текст сообщения
  loggerUid                   - идентификатор логера, через которое пришло
                                сообщение ( по умолчанию корневой логер)

  Замечания:
  - текущая реализация по умолчанию выводит сообщения на промышленной БД
    в лог модуля Scheduler, а на тестовой БД также через dbms_output, при
    этом уровень логирования в модуле Scheduler не контролируется ( по
    умолчанию отладочные сообщения в нем игнорируются);

  ( <body::logMessage>)
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , loggerUid varchar2 := null
);



/* group: Реализация функций логера */

/* pfunc: getLoggerUid
  Возвращает уникальный идентификатор логера по имени.
  При отсутствии соответствующего логера создает новый.

  Параметры:
  loggerName                  - имя логера ( null соответсвует корневому логеру)

  Возврат:
  - идентификатор существующего логера

  ( <body::getLoggerUid>)
*/
function getLoggerUid(
  loggerName varchar2
)
return varchar2;

/* pfunc: getAdditivity
  Возвращает флаг аддитивности.

  ( <body::getAdditivity>)
*/
function getAdditivity(
  loggerUid varchar2
)
return boolean;

/* pproc: setAdditivity
  Устанавливает флаг аддитивности.

  Параметры:
  loggerUid                   - идентификатор логера
  additive                    - флаг аддитивности

  ( <body::setAdditivity>)
*/
procedure setAdditivity(
  loggerUid varchar2
  , additive boolean
);

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

end pkg_LoggingInternal;
/

