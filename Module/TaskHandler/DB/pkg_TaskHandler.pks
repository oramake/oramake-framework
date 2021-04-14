create or replace package pkg_TaskHandler is
/* package: pkg_TaskHandler
  Интерфейсный пакет модуля TaskHandler.

  SVN root: Oracle/Module/TaskHandler
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'TaskHandler';

/* const: Stop_Command
  Команда, посылаемая для завершения работы обработчика.
*/
Stop_Command constant varchar2(50) := 'stop';



/* group: Функции */



/* group: Таймауты и интервалы времени */

/* pfunc: toSecond
  Возвращает длительность интервала в секундах.

  Параметры:
  timeInterval                - исходный временной интервал

  ( <body::toSecond>)
*/
function toSecond(
  timeInterval interval day to second
)
return number;

/* pfunc: getTimeout
  Возвращает значение таймаута ( в секундах) на основе базового таймаута
  и граничного времени ( в случае, если граничное время наступает до
  до истечения базового таймаута, то возвращается таймаут до граничного
  времени).

  Параметры:
  baseTimeout               - базовый таймаут ( в секундах)
  limitTime                 - граничное время

  Замечание:
  если граничное время просрочено или null, возвращается null.

  ( <body::getTimeout>)
*/
function getTimeout(
  baseTimeout number
  , limitTime timestamp with time zone
)
return number;

/* pfunc: getTime
  Возвращет текущее время в секундах ( с определенного момента с точностью до
  сотых долей секунды).

  Замечание: счетчик может сбрасываться через существенный интервал времени
  ( несколько дней - месяцев).

  ( <body::getTime>)
*/
function getTime
return number;

/* pfunc: timeDiff
  Возвращает длительность прошедшего времени в секундах.

  Параметры:
  newTime                     - последний момент времени
                                ( в секундах по getTime())
  oldTime                     - предыдущий момент времени
                                ( в секундах по getTime())

  Замечание:
  в случае, если сбрасывался счетчик getTime() ( т.е. newTime < oldTime)
  возвращается null.

  ( <body::timeDiff>)
*/
function timeDiff(
  newTime number
  , oldTime number
)
return number;

/* pfunc: nextTime
  В случае истечения таймаута с указанного момента времени обновляет значение
  момента времени на текущее и возвращает истину иначе возвращает ложь.

  Параметры:
  checkTime                   - базовый момент времени
                                ( в секундах по функции getTime())
  timeout                     - таймаут ожидания ( в секундах)

  Замечание:
    - в случае сброса счетчика в getTime() возвращается истина, но реально
      истекший таймаут может быть меньше заданного;
    - в случае, если checkTime is null возвращается истина;
    - в случае, если timeout is null возвращается истина;

  ( <body::nextTime>)
*/
function nextTime(
  checkTime in out nocopy number
  , timeout number
)
return boolean;



/* group: Информирование о состоянии */

/* pproc: setAction
  Устанавливает информацию о выполняемом действии.

  Параметры:
  action                      - название действия
  actionInfo                  - информация о выполняемом действии
  limitTime                   - планируемая дата завершения действия

  ( <body::setAction>)
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2 := null
  , limitTime timestamp with time zone := null
);

/* pproc: setAction( LIMIT_SECOND)
  Устанавливает информацию о выполняемом действии.

  Параметры:
  action                      - название действия
  actionInfo                  - информация о выполняемом действии
  limitSecond                 - максимальное время выполнения ( в секундах)

  ( <body::setAction( LIMIT_SECOND)>)
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2 := null
  , limitSecond integer
);

/* pproc: initTask
  Инициализирует задачу.

  Параметры:
  moduleName                  - имя модуля
  processName                 - имя процесса

  ( <body::initTask>)
*/
procedure initTask(
  moduleName varchar2
  , processName varchar2
);

/* pproc: cleanTask
  Выполняет очистку при завершении задачи.

  Параметры:
  riseException               - возможность выброса наружу исключения в случае
                                ошибки, по-умолчанию все ошибки маскируются
                                и никакие исключения не выбрасываются

  ( <body::cleanTask>)
*/
procedure cleanTask(
  riseException boolean := null
);



/* group: Работа с каналами */

/* pproc: createPipe
  Создает канал.

  Параметры:
  pipeName                    - имя канала

  ( <body::createPipe>)
*/
procedure createPipe(
  pipeName varchar2
);

/* pproc: removePipe
  Удаляет канал.

  Параметры:
  pipeName                    - имя канала

  ( <body::removePipe>)
*/
procedure removePipe(
  pipeName varchar2
);

/* pproc: sendMessage
  Посылает сообщение в канал.

  Параметры:
  pipeName                    - имя канала
  timeout                     - таймаут ожидания ( в секундах, по умолчанию
                                максимально возможный, dbms_pipe.maxwait)
  maxPipeSize                 - максимальный размер канала ( по умолчанию 8192)

  Замечания:
  представляет собой обертку для функции <sendMessage( INTERNAL)> для варианта
  с выбросом исключения при неуспешном результате ( isCheckResult = 1).

  ( <body::sendMessage>)
*/
procedure sendMessage(
  pipeName varchar2
  , timeout integer := null
  , maxPipeSize integer := null
);

/* pfunc: sendMessage( STATUS)
  Посылает сообщение в канал и возвращает результат.

  Параметры:
  pipeName                    - имя канала
  timeout                     - таймаут ожидания ( в секундах, по умолчанию
                                максимально возможный, dbms_pipe.maxwait)
  maxPipeSize                 - максимальный размер канала ( по умолчанию 8192)

  Возврат:
  код результа отправки сообщения ( см. <sendMessage( INTERNAL)>).

  Замечания:
  представляет собой обертку для функции <sendMessage( INTERNAL)> для варианта
  без проверки результата ( isCheckResult = 0).

  ( <body::sendMessage( STATUS)>)
*/
function sendMessage(
  pipeName varchar2
  , timeout integer := null
  , maxPipeSize integer := null
)
return integer;

/* pfunc: receiveMessage
  Проверяет наличие сообщения в канале и возвращает истину, если оно получено.

  Параметры:
  pipeName                    - имя канала
  timeout                     - время ожидания в секундах ( по умолчанию без
                                ожидания)

  ( <body::receiveMessage>)
*/
function receiveMessage(
  pipeName varchar2
  , timeout number := null
)
return boolean;



/* group: Отправка/получение команд */

/* pfunc: sendCommand
  Отсылает команду указанной сессии.

  Параметры:
  sessionSid                  - v$session.sid сессии назначения
  sessionSerial               - v$session.serial# сессии назначения

  Возвращаемое значение: истина, если команда успешно отправлена и ложь, если
  команды не могут быть отправлены этой сессии т.к. она не существует.

  ( <body::sendCommand>)
*/
function sendCommand(
  sessionSid number
  , sessionSerial number
)
return boolean;

/* pproc: sendStopCommand
  Посылает команду остановки указанному обработчику.

  Параметры:
  sessionSid                  - v$session.sid сессии назначения
  sessionSerial               - v$session.serial# сессии назначения
  moduleName                  - имя модуля

  Замечания:
  если параметры не указаны (null), то команда остановки посылается всем
  работающим обработчикам.

  ( <body::sendStopCommand>)
*/
procedure sendStopCommand(
  sessionSid number := null
  , sessionSerial number := null
  , moduleName varchar2 := null
);

/* pfunc: getCommand
  Пытается получить очередную команду в течение указанного таймаута.
  Возвращает истину, если команда была получена.

  Параметры:
  command                     - полученная команда
  timeout                     - время ожидания в секундах ( по умолчанию без
                                ожидания)

  ( <body::getCommand>)
*/
function getCommand(
  command out varchar2
  , timeout number := null
)
return boolean;

/* pfunc: isStopCommandReceived
  Проверяет получение команды остановки.

  Параметры:
  timeout                     - Время ожидания в секундах
                                (по умолчанию без ожидания)

  Возврат:
  истина, если команда остановки была получена.

  ( <body::isStopCommandReceived>)
*/
function isStopCommandReceived(
  timeout number := null
)
return boolean;

/* pproc: initHandler
  Инициализирует обработчик.

  Параметры:
  moduleName                  - имя модуля
  processName                 - имя процесса

  ( <body::initHandler>)
*/
procedure initHandler(
  moduleName varchar2
  , processName varchar2
);

/* pproc: cleanHandler
  Выполняет очистку при завершении работы обработчика.

  Параметры:
  riseException               - возможность выброса наружу исключения в случае
                                ошибки, по-умолчанию все ошибки маскируются
                                и никакие исключения не выбрасываются


  ( <body::cleanHandler>)
*/
procedure cleanHandler(
  riseException boolean := null
);



/* group: Блокировки */

/* pproc: setLock
  Устанавливает эксклюзивную блокировку для сериализации выполнения.

  Параметры:
  lockName                    - имя блокировки
  waitSecond                  - таймаут ожидания в секудах ( null -
                                макcимально возможное время)

  ( <body::setLock>)
*/
procedure setLock(
  lockName varchar2
  , waitSecond integer := null
);

end pkg_TaskHandler;
/
