create or replace package pkg_MailInternal is
/* package: pkg_MailInternal
  Внутренние процедуры-утилиты модуля Mail
*/

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

/* group: Процедуры и функции */

/* pfunc: GetIsGotMessageDeleted
  Возврат флага <body::isGotMessageDeleted>.
  (<body::GetIsGotMessageDeleted>)
*/
function GetIsGotMessageDeleted
return integer;

/* pproc: SetIsGotMessageDeleted
  Установка флага <body::isGotMessageDeleted>.
  (<body::SetIsGotMessageDeleted>)
*/
procedure SetIsGotMessageDeleted(
  isGotMessageDeleted integer
);

/* pproc: LogJava
  Интерфейсная процедура к модулю Logging
  для использования в Java
  (<body::LogJava>).
*/
procedure LogJava(
  levelCode varchar2
  , messageText varchar2
);

/* pfunc: GetBatchShortName
  Возвращает наименование батча сеанса
  (<body::GetBatchShortName>)
*/
function GetBatchShortName(
  forcedBatchShortName varchar2 := null
)
return varchar2;

/* pproc: InitCheckTime
  Инициализация проверки поступления запросов и команд
  (<body::InitCheckTime>)
*/
procedure InitCheckTime;

/* pproc: InitRequestCheckTime
  Инициализация проверки поступления запросов
  (<body::InitRequestCheckTime>)
*/
procedure InitRequestCheckTime;

/* pproc: InitHandler
  Инициализация обработчика
  (<body::InitHandler>)
*/
procedure InitHandler(
  processName varchar2
);

/* pfunc: WaitForCommand
  Ожидает команду, получаемую через pipe
  (<body::WaitForCommand>)
*/
function WaitForCommand(
  command varchar2
  , checkRequestTimeOut integer := null
)
return boolean;

/* pfunc: NextRequestTime
  Определяет истечение таймаута для проверки
  наличия запросов
  (<body::NextRequestTime>)
*/
function NextRequestTime(
  checkRequestTimeOut number
)
return boolean;

/* pproc: WaitForFetchRequest
  Ожидание запроса извлечения сообщений
  (<body::WaitForFetchRequest>)
*/
procedure WaitForFetchRequest(
  fetchRequestId integer
);

end pkg_MailInternal;
/
