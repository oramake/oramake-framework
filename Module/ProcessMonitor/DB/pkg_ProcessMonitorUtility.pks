create or replace package pkg_ProcessMonitorUtility is
/* package: pkg_ProcessMonitorUtility
  Набор утилит модуля ProcessMonitor.

  SVN root: Oracle/Module/ProcessMonitor
*/



/* group: Функции */



/* pfunc: getOperatorId
  Получение id текущего оператора
  ( <body::getOperatorId>)
*/
function getOperatorId
return integer;

/* pproc: oraKill
  Выполнение orakill для сессии
  ( <body::oraKill>)
*/
procedure oraKill(
  sid integer
  , serial# integer
);

/* pproc: abortBatch
  Прерывает выполнение пакета заданий
  ( <body::abortBatch>)
*/
procedure abortBatch(
  batchId integer
  , sid integer
  , serial# integer
);

/* pfunc: getRegisteredSession
  Получение id зарегистрированной сессии.
  В случае, если сессия не была зарегистрирована,
  то регистрирует сессию
  ( <body::getRegisteredSession>)
*/
function getRegisteredSession(
  sid integer
  , serial# integer
) return integer;

/* pproc: addAction
  Добавление запланированного действия
  для сессии
  ( <body::addAction>)
*/
procedure addAction(
  registeredSessionId integer
  , dateTime date
  , actionCode varchar2
  , emailRecipient varchar2 := null
  , emailSubject varchar2 := null
);

/* pproc: deleteAction
  Удаление запланированного действия
  для сессии
  ( <body::deleteAction>)
*/
procedure deleteAction(
  registeredSessionId integer
  , dateTime date
  , actionCode varchar2
);

/* pproc: clearRegisteredSession
  Чистка завершённых зарегистрированных сессий
  ( <body::clearRegisteredSession>)
*/
procedure clearRegisteredSession;

/* pproc: completeAction
  Помечает действие как выполненное
  ( <body::completeAction>)
*/
procedure completeAction(
  registeredSessionId integer
  , dateTime date
  , actionCode varchar2
);

/* pfunc: getDefaultTraceCopyPath
  Получение директории для копирования файлов
  по-умолчанию
  ( <body::getDefaultTraceCopyPath>)
*/
function getDefaultTraceCopyPath
return varchar2;


end pkg_ProcessMonitorUtility;
/
