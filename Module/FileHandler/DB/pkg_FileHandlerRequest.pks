create or replace package pkg_FileHandlerRequest is
/* package: pkg_FileHandlerRequest
  Пакет для обработки запросов FileHandler

  SVN root: Oracle/Module/FileHandler
*/

/* pfunc: CreateFileData
  Добавление записи данных файла
  (<body::CreateFileData>)
*/
function CreateFileData
return integer;

/* pfunc: CreateFileData(loadedBlob)
  Добавление записи данных файла
  (<body::CreateFileData(loadedBlob)>)
*/
function CreateFileData(
  loadedBlob in out nocopy blob
)
return integer;

/* pfunc: CreateRequest
  Создаёт запрос для обработчика.
  (<body::CreateRequest>)
*/
function CreateRequest(
  operationCode varchar2
  , commandText varchar2 := null
  , fileFullPath varchar2 := null
  , fileMask varchar2 := null
  , maxListCount integer := null
  , fileDestPath varchar2 := null
  , isOverwrite integer := null
  , writeMode integer := null
  , charEncoding varchar2 := null
  , isGzipped integer := null  
  , colText pkg_FileHandlerBase.tabClob := null
  , useCache boolean := null
)
return integer;

/* pproc: WaitForRequest
  Ожидание запроса для обработки
  (<body::WaitForRequest>)
*/
procedure WaitForRequest(
  requestId integer
);

/* pproc: WaitForRequest(command)
  Ожидание запроса для обработки
  (<body::WaitForRequest(command)>)
*/
procedure WaitForRequest(
  requestId integer
  , output in out nocopy clob
  , error in out nocopy clob
  , commandResult out integer
);

/* pproc: SimpleProcessRequest
  Обработка запроса без предварительного резервирования
  записей и установки статуса.
  (<body::SimpleProcessRequest>)
*/
procedure SimpleProcessRequest(
  requestId integer
  , resultStateCode out varchar2
  , errorCode out integer
  , errorMessage out varchar2
);

/* pproc: ProcessRequest
  Обработка текущих запросов
  (<body::ProcessRequest>)
*/
procedure ProcessRequest(
  requestId integer := null
  , minPriorityOrder integer := null
  , maxPriorityOrder integer:= null
  , operationCode varchar2 := null
  , batchShortName varchar2:= null
  , maxRequestCount integer := null
  , cachedDirectoryId integer := null
);

/* pproc: HandleRequest
  Циклическая realtime-обработка запросов
  (<body::HandleRequest>)
*/
procedure HandleRequest(
  minPriorityOrder integer := null
  , maxPriorityOrder integer:= null
  , operationCode varchar2 := null
  , batchShortName varchar2:= null
  , maxRequestCount integer := null
  , checkRequestInterval interval day to second
);


end pkg_FileHandlerRequest;
/