create or replace package pkg_FileHandlerCachedDirectory is
/* package: pkg_FileHandlerCachedDirectory
  Пакет для работы с кэшированными данными каталога

  SVN root: Oracle/Module/FileHandler
*/

/* pproc: AddBatchCreateCache
  Установки настроек кэширования
  для батча
  (<body::SetBatchCreateCache>)
*/
procedure SetBatchCreateCache(
  batchShortName varchar2
  , textMask varchar2
);

/* pfunc: FindCachedDirectory
  Поиск директории по полному пути к файлу
  (<body::FindCachedDirectory>)
*/
function FindCachedDirectory(
  operationCode varchar2
  , fileFullPath varchar2
  , requestTime timestamp with time zone
  , createCacheTextFileMask varchar2 := null
  , isListActual out integer
)
return integer;

/* pproc: UseCache
  Обработка запроса с использованием
  кэш.
  (<body::UseCache>)
*/
procedure UseCache(
  requestId integer
  , operationCode varchar2
  , fileFullPath varchar2
  , requestTime timestamp with time zone
  , createCacheTextFileMask varchar2 := null
);

/* pproc: SimpleProcessRequest
  Обработка запроса без предварительного резервирования
  записей и установки статуса
  (<body::SimpleProcessRequest>)
*/
procedure SimpleProcessRequest(
  requestId integer
  , cachedDirectoryId integer
  , cachedFileId integer := null
  , resultStateCode out varchar2
  , errorCode out integer
  , errorMessage out varchar2
);

/* pproc: RefreshCachedDirectory
  Обновление информации кэшированной директории
  (<body::RefreshCachedDirectory>)
*/
procedure RefreshCachedDirectory(
  cachedDirectoryId integer
  , requestTime timestamp with time zone
);

/* pproc: HandleCachedDirectory
  Обработчик кэшированных директорий
  (<body::HandleCachedDirectory>)
*/
procedure HandleCachedDirectory(
  cachedDirectoryId integer := null
  , minPriorityOrder integer := null
  , maxPriorityOrder integer := null
  , pathMask varchar2 := null
  , batchShortName varchar2 := null
  , maxRefreshCount integer := null
  , checkInterval interval day to second
);

end pkg_FileHandlerCachedDirectory;
/