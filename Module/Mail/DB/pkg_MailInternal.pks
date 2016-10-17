create or replace package pkg_MailInternal is
/* package: pkg_MailInternal
  Внутренние процедуры-утилиты модуля Mail
*/



/* group: Константы */

/* group: Состояния запросов */

/* const: Wait_RequestStateCode
  Код состояния "Ожидание обработки"
*/
Wait_RequestStateCode constant varchar2(10) := 'WAIT';

/* const: Error_RequestStateCode
  Код состояния "Ошибка обработки"
*/
Error_RequestStateCode constant varchar2(10) := 'ERROR';

/* const: Processed_RequestStateCode
  Код состояния "Успешно обработан"
*/
Processed_RequestStateCode constant varchar2(10) := 'PROCESSED';



/* group: Функции */

/* pproc: logJava
  Интерфейсная процедура логгирования
  для использования в Java

  Параметры:
  levelCode                   - код уровня сообщения
  messageText                 - текст сообщения

  ( <body::logJava>)
*/
procedure logJava(
  levelCode varchar2
  , messageText varchar2
);

/* pfunc: getBatchShortName
  Возвращает наименование батча сеанса

  Параметры:
  forcedBatchShortName        - переопределение наименования батча

  Возврат:
  имя выполняемого батча.

  ( <body::getBatchShortName>)
*/
function getBatchShortName(
  forcedBatchShortName varchar2 := null
)
return varchar2;

/* pproc: initCheckTime
  Инициализация проверки поступления запросов и команд

  ( <body::initCheckTime>)
*/
procedure initCheckTime;

/* pproc: initRequestCheckTime
  Инициализация проверки поступления команд и запросов

  ( <body::initRequestCheckTime>)
*/
procedure initRequestCheckTime;

/* pproc: initHandler
  Инициализация обработчика.

  Параметры:
  processName                 - имя процесса

  ( <body::initHandler>)
*/
procedure initHandler(
  processName varchar2
);

/* pfunc: waitForCommand
  Ожидает команду, получаемую через pipe
  в случае если наступило время проверять команду
  с учётом <lastCommandCheck>.

  Параметры:
  command                     - команда для ожидания
  checkRequestTimeOut         - интервал для проверки ожидания запроса
                                Если задан интервал ожидания команды
                                вычисляется на основе переменной
                                (<body::lastRequestCheck>).

  Возврат:
  получена ли команда.

  ( <body::waitForCommand>)
*/
function waitForCommand(
  command varchar2
  , checkRequestTimeOut integer := null
)
return boolean;

/* pfunc: nextRequestTime
  Определяет истечение таймаута для проверки наличия запросов.
  Учитывается переменная <body::lastRequestCheck>.

  Параметр:
  checkRequestTimeOut         - таймаут ожидания запроса( в секундах)

  Возврат:
  наступило ли время проверять запрос.

  ( <body::nextRequestTime>)
*/
function nextRequestTime(
  checkRequestTimeOut number
)
return boolean;

/* pproc: waitForFetchRequest
  Ожидание запроса извлечения сообщений

  Параметры:
  fetchRequestId              - Id запроса

  ( <body::waitForFetchRequest>)
*/
procedure waitForFetchRequest(
  fetchRequestId integer
);

end pkg_MailInternal;
/
