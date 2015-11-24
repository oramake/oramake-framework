create or replace package pkg_FileHandlerUtility is
/* package: pkg_FileHandlerUtility
  Набор утилит модуля FileHandler

  SVN root: Oracle/Module/FileHandler
*/

/* pfunc: GetBatchShortName
  Возвращает наименование батча сеанса
  (<body::GetBatchShortName>)
*/
function GetBatchShortName(
  forcedBatchShortName varchar2 := null
)
return varchar2;

/* pproc: SetCreateCacheTextMask
  Устаналивает значение маски текстовых файлов
  для автоматического кэширования директории
  (<body::SetCreateCacheTextMask>)
*/
procedure SetCreateCacheTextMask(
  newValue varchar2
);

/* pfunc: GetCreateCacheTextMask
  Возвращет значение маски текстовых файлов
  для автоматического кэширования директории
  (<body::GetCreateCacheTextMask>)
*/
function GetCreateCacheTextMask
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

/* pproc: ClearOldRequest
 Очистка данных обработанных запросов
 (<body::ClearOldRequest>)
*/
procedure ClearOldRequest(
  toDate date
);

end pkg_FileHandlerUtility;
/