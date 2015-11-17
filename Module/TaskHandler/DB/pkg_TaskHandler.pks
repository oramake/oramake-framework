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
  Возвращает длительность интервала в секундах
  ( <body::toSecond>).
*/
function toSecond(
  timeInterval interval day to second
)
return number;

/* pfunc: getTimeout
  Возвращает значение таймаута ( в секундах)
  ( <body::getTimeout>).
*/
function getTimeout(
  baseTimeout number
  , limitTime timestamp with time zone
)
return number;

/* pfunc: getTime
  Возвращет текущее время в секундах
  ( <body::getTime>).
*/
function getTime
return number;

/* pfunc: timeDiff
  Возвращает длительность прошедшего времемни в секундах
  ( <body::timeDiff>).
*/
function timeDiff(
  newTime number
  , oldTime number
)
return number;

/* pfunc: nextTime
  Определяет истечение таймаута с указанного момента
  ( <body::nextTime>).
*/
function nextTime(
  checkTime in out nocopy number
  , timeout number
)
return boolean;



/* group: Информирование о состоянии */

/* pproc: setAction
  Устанавливает информацию о выполняемом действии
  ( <body::setAction>).
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2 := null
  , limitTime timestamp with time zone := null
);

/* pproc: setAction( LIMIT_SECOND)
  Устанавливает информацию о выполняемом действии
  ( <body::setAction( LIMIT_SECOND)>).
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2 := null
  , limitSecond integer
);

/* pproc: initTask
  Инициализирует задачу
  ( <body::initTask>).
*/
procedure initTask(
  moduleName varchar2
  , processName varchar2
);

/* pproc: cleanTask
  Выполняет очистку при завершении задачи
  ( <body::cleanTask>).
*/
procedure cleanTask(
  riseException boolean := null
);



/* group: Работа с каналами */

/* pproc: createPipe
  Создает канал
  ( <body::createPipe>).
*/
procedure createPipe(
  pipeName varchar2
);

/* pproc: removePipe
  Удаляет канал
  ( <body::removePipe>).
*/
procedure removePipe(
  pipeName varchar2
);

/* pproc: sendMessage
  Посылает сообщение в канал
  ( <body::sendMessage>).
*/
procedure sendMessage(
  pipeName varchar2
  , timeout integer := null
  , maxPipeSize integer := null
);

/* pfunc: sendMessage( STATUS)
  Посылает сообщение в канал и возвращает результат
  ( <body::sendMessage( STATUS)>).
*/
function sendMessage(
  pipeName varchar2
  , timeout integer := null
  , maxPipeSize integer := null
)
return integer;

/* pfunc: receiveMessage
  Проверяет наличие сообщения в канале
  ( <body::receiveMessage>).
*/
function receiveMessage(
  pipeName varchar2
  , timeout number := null
)
return boolean;



/* group: Отправка/получение команд */

/* pfunc: sendCommand
  Отсылает команду указанной сессии
  ( <body::sendCommand>).
*/
function sendCommand(
  sessionSid number
  , sessionSerial number
)
return boolean;

/* pproc: sendStopCommand
  Посылает команду остановки
  ( <body::sendStopCommand>).
*/
procedure sendStopCommand(
  sessionSid number := null
  , sessionSerial number := null
  , moduleName varchar2 := null
);

/* pfunc: getCommand
  Пытается получить очередную команду
  ( <body::getCommand>).
*/
function getCommand(
  command out varchar2
  , timeout number := null
)
return boolean;

/* pproc: initHandler
  Инициализирует обработчик
  ( <body::initHandler>).
*/
procedure initHandler(
  moduleName varchar2
  , processName varchar2
);

/* pproc: cleanHandler
  Выполняет очистку при завершении работы обработчика
  ( <body::cleanHandler>).
*/
procedure cleanHandler(
  riseException boolean := null
);

/* group: Блокировки */


/* proc: setLock
 Устанавливает эксклюзивную блокировку для сериализации выполнения
 ( <body::setLock>).
*/
procedure setLock(
  lockName varchar2
  , waitSecond integer := null
);

end pkg_TaskHandler;
/
