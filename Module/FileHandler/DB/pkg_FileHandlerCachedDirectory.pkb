create or replace package body pkg_FileHandlerCachedDirectory is
/* package body: pkg_FileHandlerCachedDirectory::body */

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_FileHandlerBase.Module_Name
    , objectName => 'pkg_FileHandlerCachedDirectory'
  );

/* proc: SetBatchCreateCache
  Установки настроек кэширования
  для батча

  Параметры:
  batchShortName             - имя батча ( sch_batch )
  textMask                   - маска для кэшированных текстовых файлов
*/
procedure SetBatchCreateCache(
  batchShortName varchar2
  , textMask varchar2
)
is
begin
  update
    flh_batch_config c
  set
    c.auto_cache_text_mask = textMask
  where
    c.batch_short_name = batchShortName;
  if SQL%ROWCOUNT = 0 then
    insert into flh_batch_config(
      batch_short_name
      , auto_cache_text_mask
    )
    values(
      batchShortName
      , textMask
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка установки натсроек для батча' )
    , true
  );
end SetBatchCreateCache;

/* proc: AddMask
  Добавление текстовой маски

  Параметры:
  cachedDirectoryId          - id кэшированной директории
  textFileMask               - маска для кэшированных текстовых файлов
*/
procedure AddMask(
  cachedDirectoryId integer
  , textFileMask varchar2
)
is
begin
  insert into flh_cached_file_mask(
    cached_directory_id
    , file_mask
    , is_text
  )
  values(
    cachedDirectoryId
    , textFileMask
    , 1
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка добавления маски' )
    , true
  );
end AddMask;

/* func: CreateCachedDirectory
  Создание записи кэшированной директории

  Параметры:
  path                       - путь для кэшированной директории
                             ( без '\' в конце)
  textFileMask               - маска для кэшированных текстовых файлов

  Возврат:
  - id кэшированной директории
*/
function CreateCachedDirectory(
  path varchar2
  , textFileMask varchar2 := null
)
return varchar2
is
  cachedDirectoryId integer;



begin
                                       -- Создаём запись
  insert into flh_cached_directory(
    path
    , batch_short_name
    , existing_batch_short_name
  )
  values(
    CreateCachedDirectory.path
    , pkg_FileHandlerUtility.GetBatchShortName
    , pkg_FileHandlerUtility.GetBatchShortName
  )
  returning
    cached_directory_id
  into
    cachedDirectoryId;
  if textFileMask is not null then
    AddMask(
      cachedDirectoryId => cachedDirectoryId
      , textFileMask => textFileMask
    );
  end if;
  return cachedDirectoryId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка создания записи кэшированной директории ('
        || ' path = "' || path || '"'
        || ' textFileMask = "' || textFileMask || '"'
        || ')'
      )
    , true
  );
end CreateCachedDirectory;

/* func: FindCachedDirectory
  Поиск директории по полному пути к файлу

  Параметры:
    operationCode             - код операции запроса
    fileFullPath              - полный путь к файлу ( директории )
    requestTime               - время для выполнения запроса
    createCacheTextFileMask   - маска текстовых файлов для создания записи в случае
                              если запись не найдена. Если не задана, то запись
                              не создаётся
    isListActual              - возвращаемый флаг актуальности списка файлов

  Возврат:
    - id кэшированной директории
*/
function FindCachedDirectory(
  operationCode varchar2
  , fileFullPath varchar2
  , requestTime timestamp with time zone
  , createCacheTextFileMask varchar2 := null
  , isListActual out integer
)
return integer
is
                                       -- Результат функции
  foundId integer;
                                       -- Маска для совпадения с параметром
                                       -- createCacheTextFileMask
  createCacheTextMaskId integer;
                                       -- Курсор для поиска директории
  cursor curFindCachedDirectory is
    select
      cached_directory_id
                                       -- Флаг актуальности данных списка
                                       -- файлов
      , case when
                                       -- Ecли заданный интервал не истёк
          d.last_refresh >= requestTime
            - coalesce( d.list_refresh_timeout, interval '0' second )
          or d.is_actual_when_new_file = 1
                                       -- Если директория
                                       -- считается актуальной при наличии
                                       -- незапрошенного файла
          and exists
            (
            select
              1
            from
              flh_cached_file f
            where
              f.cached_directory_id = d.cached_directory_id
              and f.existing = 1
                                       -- Имя файла должно удовлетворять хотя
                                       -- бы одной из масок
              and coalesce( f.used_text_mask_id, f.used_binary_mask_id )
                is not null
              and f.file_data_id is not null
              and not exists
                (
                select
                  1
                from
                  flh_request r
                where
                  r.file_data_id = f.file_data_id
                )
             )
        then
          1
        else
          0
        end as is_list_actual
      ,
                                       -- Маска совпадающая
                                       -- с параметром createCacheTextFileMask
      (
      select
        cached_file_mask_id
      from
        flh_cached_file_mask m
      where
        m.cached_directory_id = d.cached_directory_id
        and m.file_mask = createCacheTextFileMask
        and m.is_text = 1
      ) as create_cache_text_mask_id
    from
      flh_cached_directory d
    where
                                        -- Для получение списка файлов
                                        -- директории должны совпадать
                                        -- с точностью до последнего разделителя
      operationCode = pkg_FileHandlerBase.FileList_OperationCode
      and d.path = rtrim( fileFullPath, '\' )
      or
                                        -- Для чтения текста
                                        -- должна быть задана маска
      operationCode =  pkg_FileHandlerBase.LoadText_OperationCode
      and exists
        (
        select
          1
        from
          flh_cached_file_mask m
        where
          m.cached_directory_id = d.cached_directory_id
          and m.is_text = 1
          and fileFullPath like pkg_FileHandler.GetFilePath(
            d.path
            , m.file_mask
          )
        )
      or
                                        -- Для чтения двоичных данных
                                        -- должна быть задана маска
      operationCode = pkg_FileHandlerBase.LoadBinary_OperationCode
      and exists
        (
        select
          1
        from
          flh_cached_file_mask m
        where
          m.cached_directory_id = d.cached_directory_id
          and m.is_text = 0
          and fileFullPath like pkg_FileHandler.GetFilePath(
            d.path
            , m.file_mask
          )
        )
      or
                                        -- Для установки признака
                                        -- удаления файл должен находиться
                                        -- в директории
      operationCode = pkg_FileHandlerBase.Delete_OperationCode
      and fileFullPath like d.path || '%'
   ;

begin
  logger.Trace('FindCachedDirectory: start...');
  open
    curFindCachedDirectory;
                                        -- В случае если директория
                                        -- не найдена
                                        -- возвращаемые значения не определены
  fetch
    curFindCachedDirectory
  into
    foundId
    , isListActual
    , createCacheTextMaskId;
  close
    curFindCachedDirectory;
  if operationCode = pkg_FileHandlerBase.FileList_OperationCode
    and createCacheTextFileMask is not null
  then
                                        -- Если запись не найдена
    if foundId is null then
      foundId :=
        CreateCachedDirectory(
          path => fileFullPath
          , textFileMask => createCacheTextFileMask
        );
    else
                                        -- Если маски нет
      if createCacheTextMaskId is null then
        AddMask(
          cachedDirectoryId => foundId
          , textFileMask => createCacheTextFileMask
        );
      end if;
    end if;
  end if;
                                        -- Возвращаем id
                                        -- найденной директории либо null
  logger.Trace('FindCachedDirectory: end...');
  return foundId;
exception when others then
  if curFindCachedDirectory%ISOPEN then
    close
      curFindCachedDirectory;
  end if;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка поиска кэшированной директории' )
    , true
  );
end FindCachedDirectory;


/* func: FindCachedFile(error)
  Поиск кэшированного файла

  Параметры:
    operationCode            - код операции запроса
    cachedDirectoryId        - id кэшированной директории
    fileFullPath             - полный путь к файлу ( директории )
    requestTime              - время для выполнения запроса
    isListActual             - возвращаемый флаг актуальности данных файла
    errorCode                - возвращаемый код ошибки в случае,
                               если файл не найден, либо данные
                               не загружены
    errorMessage             - возвращаемый текст ошибки в случае,
                               если файл не найден, либо данные
                               не загружены

  Возврат:
    - id кэшированного файла, если найден, либо null
*/
function FindCachedFile(
  operationCode varchar2
  , cachedDirectoryId integer
  , fileFullPath varchar2
  , requestTime timestamp with time zone
  , isFileActual out integer
  , errorCode out integer
  , errorMessage out varchar2
)
return integer
is
                                       -- Курсор для поиска файла
  cursor curFindCachedFile is
    select
      case when
        existing = 1
        and file_data_id is not null
      then
        cached_file_id
      end as cached_file_id
      ,
      case when
        existing = 1
        and file_data_id is not null
        and
                                       -- Если допустимый таймаут не задан
        ( d.file_refresh_timeout is null
                                       -- Или не истёк таймаут
          or f.last_load > requestTime - d.file_refresh_timeout
        )
      then
        1
      else
        0
      end as is_actual
      , f.file_data_id
      , f.existing
      , f.delete_request_id
    from
      flh_cached_directory d
      , flh_cached_file f
    where
      d.cached_directory_id = cachedDirectoryId
      and d.cached_directory_id = f.cached_directory_id
      and f.file_full_path = fileFullPath
    ;
                                       -- Считанные данные поиска
  recFindCachedFile curFindCachedFile%rowtype;
begin
  open curFindCachedFile;
  fetch
    curFindCachedFile
  into
    recFindCachedFile;
  return
    recFindCachedFile.cached_file_id;
                                       -- Сообщения об ошибке
  if curFindCachedFile%notfound then
                                       -- Файл не найден в кэш
    errorCode := pkg_FileHandlerBase.FileCacheNotFound_ErrorCode;
    errorMessage := 'Файл не найден в cache';
  elsif recFindCachedFile.existing = 0 then
                                       -- Файл помечен как несуществующий
    errorCode := pkg_FileHandlerBase.FileCacheNotExists_ErrorCode;
    errorMessage := 'Файл помечен как несуществующий';
    if recFindCachedFile.delete_request_id is not null then
      errorMessage := errorMessage || chr(10)
        || ', удалён запросом (requestId='
        || to_char( recFindCachedFile.delete_request_id) || ')';
    end if;
  elsif recFindCachedFile.file_data_id is null then
                                       -- Нет данных
    errorCode := pkg_FileHandlerBase.FileCacheNoData_ErrorCode;
    errorMessage := 'Данные файла не загружены в cache';
  end if;
  close curFindCachedFile;
  if
    recFindCachedFile.cached_file_id is null
    and errorMessage is null
  or
    recFindCachedFile.cached_file_id is not null
    and errorMessage is not null
  then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Внутренняя ошибка FindCachedFile: '
        || chr(10) || 'данные курсоры противоречивы'
    );
  end if;
  isFileActual := recFindCachedFile.is_actual;
  return
    recFindCachedFile.cached_file_id;
exception when others then
  if curFindCachedFile%ISOPEN then
    close curFindCachedFile;
  end if;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка поиска кэшированного файла ('
        || 'operationCode="' || operationCode || '"'
        || ', cachedDirectoryId="' || to_char(cachedDirectoryId) || '"'
        || ', fileFullPath="' || fileFullPath || '"'
        || ')'
      )
    , true
  );
end FindCachedFile;

/* func: FindCachedFile
  Поиск кэшированного файла

  Параметры:
    operationCode            - код операции запроса
    cachedDirectoryId        - id кэшированной директории
    fileFullPath             - полный путь к файлу ( директории )
    requestTime              - время для выполнения запроса
    isListActual             - возвращаемый флаг актуальности данных файла

  Возврат:
    - id кэшированного файла, если найден, либо null
*/
function FindCachedFile(
  operationCode varchar2
  , cachedDirectoryId integer
  , fileFullPath varchar2
  , requestTime timestamp with time zone
  , isFileActual out integer
)
return integer
is
                                       -- out-параметры
                                       -- для вызова перекрытой
                                       -- FindCachedFile
  errorCode flh_request.error_code%type;
  errorMessage flh_request.error_message%type;
                                       -- Результат функици
  foundCachedFileId integer;
begin
  foundCachedFileId :=
    FindCachedFile(
      operationCode => operationCode
      , cachedDirectoryId => cachedDirectoryId
      , fileFullPath => fileFullPath
      , requestTime => requestTime
      , isFileActual => isFileActual
      , errorCode => errorCode
      , errorMessage => errorMessage
    );
  if errorCode is not null and errorMessage is not null then
    logger.Debug('Сообщение поиска кэшированного файла: '
      || chr(10) || '"' || errorMessage || '"'
    );
  end if;
  return
    foundCachedFileId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка поиска кэшированного файла ('
        || 'operationCode="' || operationCode || '"'
        || ', cachedDirectoryId="' || to_char(cachedDirectoryId) || '"'
        || ', fileFullPath="' || fileFullPath || '"'
        || ')'
      )
    , true
  );
end FindCachedFile;


/* proc: SimpleProcessRequest
  Обработка запроса без предварительного резервирования
  записей и установки статуса с использованием кэшированной
  информации

  Параметры:
    requestId                - id запроса
    cachedDirectoryId        - id кэшированной директории
    cachedFileId             - id кэшированного файла,
                             если он был найден заранее
    resultStateCode          - возвращаемое новое состояние запроса

    fileFullPath             - полный путь к файлу ( директории )
    requestTime              - время для выполнения запроса
    isListActual             - возвращаемый флаг актуальности данных файла
    errorCode                - возвращаемый код ошибки в случае,
                               если файл не найден, либо данные
                               не загружены
    errorMessage             - возвращаемый текст ошибки в случае,
                               если файл не найден, либо данные
                               не загружены
*/
procedure SimpleProcessRequest(
  requestId integer
  , cachedDirectoryId integer
  , cachedFileId integer := null
  , resultStateCode out varchar2
  , errorCode out integer
  , errorMessage out varchar2
)
is
  recRequest flh_request%rowtype;

  procedure GetRequestData
  is
  -- Получение кода операции
  begin
    select
      *
    into
      recRequest
    from
      flh_request
    where
      request_id = requestId;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка получения операции' )
      , true
    );
  end GetRequestData;

  procedure ProcessFileList
  is
  -- Получение списка файлов из cache
  begin
    logger.Debug('ProcessFileList: start');
    delete
      flh_request_file_list
    where
      request_id = requestId;
    logger.Debug('ProcessFileList: requestId=' || to_char( requestId));
    logger.Debug('ProcessFileList: requestId=' || to_char( requestId));
    insert into flh_request_file_list(
      request_id
      , operation_code
      , file_name
      , file_size
      , last_modification
    )
    select
      recRequest.request_id as request_id
      , recRequest.operation_code as operation_code
      , file_name as file_name
      , file_size as file_size
      , last_modification as last_modification
    from
      flh_cached_file f
    where
      f.cached_directory_id = cachedDirectoryId
      and f.existing = 1;
    resultStateCode := pkg_FileHandlerBase.Processed_RequestStateCode;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка получения списка файлов' )
      , true
    );
  end ProcessFileList;

  procedure ProcessLoad
  is
  -- Загрузка файла с использованием cache
                                       -- Использованный id
                                       -- файла
    usedCachedFileId integer;
                                       -- Переменная для out-параметра
                                       -- FindCachedFile
    isFileActual integer;
  begin
                                       -- Проверка корректности загрузки
    if recRequest.file_data_id is not null then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Для запроса (request_id = '
          || to_char( recRequest.request_id) || ')'
          || ' file_data_id уже установлен'
      );
    end if;
    usedCachedFileId :=
      coalesce(
        cachedFileId
        ,
        FindCachedFile(
          operationCode => recRequest.operation_code
          , cachedDirectoryId => cachedDirectoryId
          , fileFullPath => recRequest.file_full_path
          , requestTime => recRequest.request_time
          , isFileActual => isFileActual
          , errorCode => errorCode
          , errorMessage => errorMessage
        )
      );
                                       -- Проверка непротиворечивости данных
    if usedCachedFileId is null and
    ( errorMessage is not null or errorCode is not null )
    or
    usedCachedFileId is null and
    ( errorMessage is null or errorCode is null )
    then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Внутренняя ошибка: данные поиска файла в cache противоречивы'
      );
    end if;
    if usedCachedFileId is not null then
      update
        flh_request
      set
        file_data_id =
        (
        select
          file_data_id
        from
          flh_cached_file f
        where
          f.cached_file_id = usedCachedFileId
       );
       resultStateCode := pkg_FileHandlerBase.Processed_RequestStateCode;
     else
       resultStateCode := pkg_FileHandlerBase.Error_RequestStateCode;
     end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка получения списка файлов' )
      , true
    );
  end ProcessLoad;

begin
                                       -- Получаем данные запроса
  GetRequestData;
  case
    recRequest.operation_code
  when
    pkg_FileHandlerBase.FileList_OperationCode
  then
    ProcessFileList;
  when
    pkg_FileHandlerBase.LoadText_OperationCode
  then
    ProcessLoad;
  when
    pkg_FileHandlerBase.LoadBinary_OperationCode
  then
    ProcessLoad;
  else
    raise_application_error(
      pkg_Error.ProcessError
      , 'Операция с кодом "' || recRequest.operation_code  || '"'
        || ' не может быть обработана с помощью cache'
    );
  end case;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка обработки запроса с помощью кэша( '
        || 'requestId = ' || to_char( requestId)
        || ')'
      )
    , true
  );
end SimpleProcessRequest;

/* proc: UseCache
  Обработка запроса с использованием
  кэш.

  Параметры:
    requestId                - id запроса
    operationCode            - код операции запроса
    fileFullPath             - полный путь к файлу ( директории )
    requestTime              - время для выполнения запроса
    createCacheTextFileMask  - маска текстовых файлов для создания записи
                               кэшированной директории в случае если запись не найдена.
                               Если не задана, то запись кэшированной директории
                               в случае отсутствия не создаётся.
*/
procedure UseCache(
  requestId integer
  , operationCode varchar2
  , fileFullPath varchar2
  , requestTime timestamp with time zone
  , createCacheTextFileMask varchar2 := null
)
is
                                       -- Id найденной директории
  cachedDirectoryId integer;
                                       -- Id найденного файла
  cachedFileId integer;
                                       -- Актуальны ли данные
                                       -- списка файлов директории
  isListActual integer;
                                       -- Актуальны ли данные файла
  isFileActual integer;
                                       -- out-параметры SimpleProcessRequest
  errorCode flh_request.error_code%type;
  errorMessage flh_request.error_message%type;
  resultStateCode flh_request.request_state_code%type;

  procedure GetActuality
  is
  -- Получение флагов актуальности данных в cache
  begin
    cachedDirectoryId :=
      FindCachedDirectory(
        operationCode => operationCode
        , fileFullPath => fileFullPath
        , requestTime => requestTime
        , createCacheTextFileMask => createCacheTextFileMask
        , isListActual => isListActual
      );
                                       -- Если директория найдена
    if cachedDirectoryId is not null
    and operationCode in (
        pkg_FileHandlerBase.LoadText_OperationCode
        , pkg_FileHandlerBase.LoadBinary_OperationCode
      )
    then
      cachedFileId := FindCachedFile(
        operationCode => operationCode
        , cachedDirectoryId => cachedDirectoryId
        , fileFullPath => fileFullPath
        , requestTime => requestTime
        , isFileActual => isFileActual
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка получения флагов актульности' )
      , true
    );
  end GetActuality;

  procedure ProcessDelete
  is
  -- Обработка запроса на удаления для cache
  begin
    update
      flh_cached_file f
    set
      f.delete_request_id = requestId
      , f.existing = 0
    where
      f.cached_file_id = cachedFileId;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка обработки запроса на удаления для cache' )
      , true
    );
  end ProcessDelete;

begin
                                       -- Считывания информации
                                       -- об актуальности
  GetActuality;
  if operationCode = pkg_FileHandlerBase.Delete_OperationCode then
                                       -- Запись информации об удалении
    ProcessDelete;
  end if;
  if
                                       -- Если данные актуальны
    cachedDirectoryId is not null
    and isListActual = 1
    and
    (
      operationCode = pkg_FileHandlerBase.FileList_OperationCode
      or
                                       -- Для считывания файла
                                       -- нужны существование и актуальность
                                       -- данных
      cachedFileId is not null
      and operationCode in
        ( pkg_FileHandlerBase.LoadText_OperationCode
          , pkg_FileHandlerBase.LoadBinary_OperationCode
        )
    )
  then
    logger.Debug('Using cache process request...');
    SimpleProcessRequest(
      requestId => requestId
      , cachedDirectoryId => cachedDirectoryId
      , cachedFileId => cachedFileId
      , resultStateCode => resultStateCode
      , errorCode => errorCode
      , errorMessage => errorMessage
    );
    update
      flh_request r
    set
      used_cached_directory_id = cachedDirectoryId
      , request_state_code = resultStateCode
      , error_code = errorCode
      , error_message = errorMessage
      , is_handler_used = 0
      , last_processed = systimestamp
    ;
  elsif cachedDirectoryId is not null then
    logger.Debug('Данные в кэш не актуальны ('
      || ' cachedDirectoryId = ' || to_char(cachedDirectoryId)
      || ')'
    );
    update
      flh_request r
    set
      used_cached_directory_id = cachedDirectoryId
    where
      request_id = requestId
    ;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка обработки запроса, испольующего кэш' )
    , true
  );
end UseCache;

/* proc: RefreshCachedDirectory
  Обновление информации кэшированной директории

  Параметры:
    cachedDirectoryId        - id кэшированной директории
    requestTime              - время для выполнения запроса

  Замечание:
    - процедура оформлена в виде автономной транзакции
  так как производятся операции в файловой системе
*/
procedure RefreshCachedDirectory(
  cachedDirectoryId integer
  , requestTime timestamp with time zone
)
is
  pragma autonomous_transaction;
                                       -- Данные кэшированной директории
  recCachedDirectory flh_cached_directory%rowtype;

  procedure GetCachedDirectory
  is
  begin
    pkg_TaskHandler.SetAction('reserve dir');
    select
      *
    into
      recCachedDirectory
    from
      flh_cached_directory
    where
      cached_directory_id = cachedDirectoryId
    for update wait 3600
    ;
    pkg_TaskHandler.SetAction('');
  exception when others then
    pkg_TaskHandler.SetAction('');
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка резервирования директории' )
      , true
    );
  end GetCachedDirectory;

  procedure RefreshFileList
  is
  -- Обновление списка файлов
                                       -- Количества добаленных
                                       -- несуществующих файлов
    nNew integer;
    nDeleted integer;

    procedure AddNew
    is
    -- Добавление в список
    begin
      insert into flh_cached_file(
        cached_directory_id
        , file_full_path
        , file_name
        , file_size
        , last_modification
        , existing
      )
      select
        cachedDirectoryId as cached_directory_id
        , pkg_FileHandler.GetFilePath(
            recCachedDirectory.path
            , file_name
          ) as file_full_path
        , file_name as file_name
        , file_size as file_size
        , last_modification as last_modification
        , 1 as existing
      from
        tmp_file_name t
      where
                                       -- Новые файлы
        not exists
        (
        select
          1
        from
          flh_cached_file f
        where
          f.cached_directory_id = cachedDirectoryId
          and f.file_name = t.file_name
        );
      nNew := SQL%ROWCOUNT;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.ErrorStack( 'Ошибка добавления в список' )
        , true
      );
    end AddNew;

    procedure UpdateList
    is
    -- Актуализация списка
    begin
      update
        flh_cached_file f
      set
      (
        file_size
        , last_modification
        , existing
      )
      =
        (
        select
          file_size
          , last_modification
          , 1 as existing
        from
          tmp_file_name t
        where
          t.file_name = f.file_name
        )
      where
        f.cached_directory_id = cachedDirectoryId
        and f.file_name in
        (
        select
          file_name
        from
          tmp_file_name
        );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.ErrorStack( 'Ошибка обновления данных' )
        , true
      );
    end UpdateList;

    procedure DeleteOld
    is
    -- Пометка о несуществовании файла
    begin
      update
        flh_cached_file f
      set
        existing = 0
      where
        f.cached_directory_id = cachedDirectoryId
        and existing = 1
        and not exists
        (
        select
          1
        from
          tmp_file_name t
        where
          t.file_name = f.file_name
        );
      nDeleted := SQL%ROWCOUNT;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.ErrorStack( 'Ошибка записи о несуществущих файлах' )
        , true
      );
    end DeleteOld;

  begin
    pkg_TaskHandler.SetAction('refresh list');
    delete
      tmp_file_name;
    pkg_FileOrigin.FileList(
      fromPath => recCachedDirectory.path
    );
    AddNew;
    UpdateList;
    DeleteOld;
    if nNew > 0 then
      logger.Debug('Добавлено в список: ' || to_char( nNew ) );
    end if;
    if nDeleted > 0 then
      logger.Debug('Удалено из списка: ' || to_char( nDeleted ) );
    end if;
    pkg_TaskHandler.SetAction('');
  exception when others then
    pkg_TaskHandler.SetAction('');
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка обновления списка файлов' )
      , true
    );
  end RefreshFileList;

  procedure RefreshFileData
  is
  -- Обновление данных файлов
                                       -- Id данных текущего файла
    fileDataId integer;
                                       -- Курсор для выборки
                                       -- файлов для загрузки
    cursor curRefreshFileData is
      select
        cached_file_id
        , file_data_id
        , file_full_path
        , text_data
        , binary_data
        , text_mask_id
        , binary_mask_id
      from
        (
        select
          f.cached_file_id
          , f.file_data_id
          , f.file_full_path
          ,
                                       -- Текстовые данные
          (
          select
            t.text_data
          from
            flh_text_data t
          where
            t.file_data_id = f.file_data_id
            and t.order_by = 1
          ) as text_data
                                       -- Двоичные данные
          ,
          (
          select
            fd.binary_data
          from
            flh_file_data fd
          where
            fd.file_data_id = f.file_data_id
          ) as binary_data
          ,
          (
          select
            cached_file_mask_id
          from
            flh_cached_file_mask m
          where
            f.file_full_path like
              pkg_FileHandler.GetFilePath(
                d.path
                , m.file_mask
              )
            and m.cached_directory_id = d.cached_directory_id
            and m.is_text = 1
            and rownum <= 1
          ) as text_mask_id
          ,
          (
          select
            cached_file_mask_id
          from
            flh_cached_file_mask m
          where
            f.file_full_path like
              pkg_FileHandler.GetFilePath(
                d.path
                , m.file_mask
              )
            and m.cached_directory_id = d.cached_directory_id
            and m.is_text = 0
            and rownum <= 1
          ) as binary_mask_id
        from
          flh_cached_directory d
          , flh_cached_file f
        where
          d.cached_directory_id = cachedDirectoryId
          and f.cached_directory_id = d.cached_directory_id
          and f.existing = 1
          and
          (
                                       -- Если файл не загружен
            f.last_load is null
            or
                                       -- Либо истёк заданный интервал
                                       -- в случае задания
            d.file_refresh_timeout is not null
            and f.last_load <= requestTime - d.file_refresh_timeout
          )
        )
                                       -- Если нужно загружать файл
      where
        text_mask_id is not null
        or binary_mask_id is not null
    ;

    procedure LoadText( recFile curRefreshFileData%rowtype )
    is
    -- Загрузка текстовых данных
                                       -- Загружаемый clob
      loadedClob clob;
    begin
      if recFile.text_data is not null then
        loadedClob := recFile.text_data;
      else
        fileDataId := coalesce(
          fileDataId
          , pkg_FileHandlerRequest.CreateFileData()
        );
                                       -- Если clob-а нет,
                                       -- создаём
        insert into flh_text_data(
          file_data_id
          , text_data
          , order_by
        )
        values(
          fileDataId
          , empty_clob()
          , 1
        )
        returning
          text_data
        into
          loadedClob;
      end if;
      pkg_FileOrigin.LoadClobFromFile(
        dstLob => loadedClob
        , fromPath => recFile.file_full_path
      );
      logger.Debug('Загружен текстовый файл: file_full_path = '
        || '"' || recFile.file_full_path || '"'
      );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.ErrorStack( 'Ошибка загрузки текстового файла('
            || 'file_full_path="' || recFile.file_full_path ||'"'
            || ')'
          )
        , true
      );
    end LoadText;

    procedure LoadBinary( recFile curRefreshFileData%rowtype )
    is
    -- Загрузка двоичных данных
                                       -- Загружаемый blob
      loadedBlob blob;
    begin
      if recFile.binary_data is not null then
        loadedBlob := recFile.binary_data;
      else
        fileDataId := coalesce(
          fileDataId
          , pkg_FileHandlerRequest.CreateFileData(
            loadedBlob=>loadedBlob
          )
        );
      end if;
      pkg_FileOrigin.LoadBlobFromFile(
        dstLob => loadedBlob
        , fromPath => recFile.file_full_path
      );
      logger.Debug('Загружен двоичный файл: file_full_path = '
        || '"' || recFile.file_full_path || '"'
      );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.ErrorStack( 'Ошибка загрузки двоичного файла('
            || 'file_full_path="' ||  recFile.file_full_path ||'"'
            || ')'
          )
        , true
      );
    end LoadBinary;

  begin
    pkg_TaskHandler.SetAction('refresh data');
    for recFile in curRefreshFileData loop
      if recFile.text_mask_id is not null then
        LoadText( recFile => recFile );
      end if;
      if recFile.binary_mask_id is not null then
        LoadBinary( recFile => recFile );
      end if;
                                       -- Проверка корректности
                                       -- установки file_data_id
      if recFile.binary_mask_id is not null
      and recFile.file_data_id <> fileDataId then
        raise_application_error(
          pkg_Error.ProcessError
          , 'Внутренняя ошибка: потерянная ссылка file_data_id='
            || to_char( recFile.file_data_id)
        );
      end if;
      update
        flh_cached_file f
      set
        f.last_load = systimestamp
        , f.file_data_id = fileDataId
        , f.used_text_mask_id = recFile.text_mask_id
        , f.used_binary_mask_id = recFile.binary_mask_id
      where
        f.cached_file_id = recFile.cached_file_id;
    end loop;
    pkg_TaskHandler.SetAction('');
  exception when others then
    pkg_TaskHandler.SetAction('');
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка загрузки данных файлов' )
      , true
    );
  end RefreshFileData;

begin
  GetCachedDirectory;
  RefreshFileList;
  RefreshFileData;
  update
    flh_cached_directory c
  set
    c.last_refresh = requestTime
  where
    c.cached_directory_id = cachedDirectoryId;
  commit;
                                       -- Автономная транзакция
                                       -- для обработки запросов
  pkg_FileHandlerRequest.ProcessRequest(
    cachedDirectoryId => cachedDirectoryId
  );
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка обновления кэшированной директории ('
        || 'cachedDirectoryId=' || to_char( cachedDirectoryId )
        || ' )'
      )
    , true
  );
end RefreshCachedDirectory;

/* func: RefreshCachedDirectory(condition)
  Обновление информации кэшированных директорий

  Параметры:
    cachedDirectoryId        - id кэшированной директории
    minPriorityOrder         - минимальный приоритет кэшированных
                               директорий
    maxPriorityOrder         - максимальный приоритет кэшированных
                               директорий
    pathMask                 - макса для путей кэшированных
                               директорий
    batchShortName           - батч, ассоциированный с кэшированной
                               директорией
    maxRefreshCount          - максимальное количество обновлений
                               директорий
  Возврат:
    - количество обновлений
*/
function RefreshCachedDirectory(
  cachedDirectoryId integer := null
  , minPriorityOrder integer := null
  , maxPriorityOrder integer := null
  , pathMask varchar2 := null
  , batchShortName varchar2 := null
  , maxRefreshCount integer := null
)
return integer
is
                                       -- Количество обновлённых директорий
  nCount integer := 0;
                                       -- Текущее время для обновления
  currentRequestTime timestamp with time zone;
                                       -- Курсор для выборки
                                       -- ожидающих обновления директорий
  cursor curRefreshDirectory is
    select
      cached_directory_id
    from
      v_flh_cached_directory_wait v
    where
      (
        cachedDirectoryId is null
        or v.cached_directory_id = cachedDirectoryId
      )
      and
      (
        minPriorityOrder is null
        or v.priority_order >= minPriorityOrder
      )
      and
      (
        maxPriorityOrder is null
        or v.priority_order <= maxPriorityOrder
      )
      and
      (
        pathMask is null
        or v.path like pathMask
      )
      and
      (
        batchShortName is null
        or v.batch_short_name = batchShortName
      )
      and
      (
        maxRefreshCount is null
        or rownum <= maxRefreshCount
      )
    order by
      priority_order nulls last
      , cached_directory_id
  ;
begin
                                       -- Поочерёдное обновление
                                       -- директорий, ожидающих обновление
  currentRequestTime := systimestamp;
  for recRefreshDirectory in curRefreshDirectory loop
    RefreshCachedDirectory(
      requestTime => currentRequestTime
      , cachedDirectoryId => recRefreshDirectory.cached_directory_id
    );
    nCount := nCount + 1;
  end loop;
  return nCount;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
     , logger.ErrorStack(
        'Ошибка обработки кэшированной директории('
        || ' cachedDirectoryId=' || coalesce( to_char( cachedDirectoryId), 'null' )
        || ' minPriorityOrder=' || coalesce( to_char( minPriorityOrder), 'null' )
        || ' maxPriorityOrder=' || coalesce( to_char( maxPriorityOrder), 'null' )
        || ' pathMask="' || pathMask || '"'
        || ' batchShortName="' || batchShortName || '"'
        || ' maxRefreshCount=' || coalesce( to_char( maxRefreshCount), 'null' )
        || ').'
      )
    , true
  );
end RefreshCachedDirectory;

/* proc: HandleCachedDirectory
  Обработчик кэшированных директорий

  Параметры:
    cachedDirectoryId        - id кэшированной директории
    minPriorityOrder         - минимальный приоритет кэшированных
                               директорий
    maxPriorityOrder         - максимальный приоритет кэшированных
                               директорий
    pathMask                 - макса для путей кэшированных
                               директорий
    batchShortName           - батч, ассоциированный с кэшированной
                               директорией
    maxRefreshCount          - максимальное количество обновлений
                               директорий
    checkInterval            - интервал для проверки актуальности
                               информации в кэше директорий
*/
procedure HandleCachedDirectory(
  cachedDirectoryId integer := null
  , minPriorityOrder integer := null
  , maxPriorityOrder integer := null
  , pathMask varchar2 := null
  , batchShortName varchar2 := null
  , maxRefreshCount integer := null
  , checkInterval interval day to second
)
is
                                       -- Количество обновлений
  nHandleCount integer := 0;
                                       -- Результат вызова продедуры
                                       -- RefreshCachedDirectory
  nCurrent integer;
                                       -- Интервал между проверками
                                       -- наличия запросов
  checkRequestTimeout number
    := pkg_TaskHandler.ToSecond( checkInterval );
begin
  pkg_FileHandlerUtility.InitHandler(
    processName  => 'HandleCachedDirectory'
  );
  loop
                                       -- Наступило время проверять запрос
    if pkg_FileHandlerUtility.NextRequestTime(
      checkRequestTimeout => checkRequestTimeout
    )
    then
                                       -- Проверяем команду,
                                       -- если наступило время
      logger.Trace( 'WaitForCommand...' );
      if pkg_FileHandlerUtility.WaitForCommand(
           command => pkg_TaskHandler.Stop_Command
        )
      then
        exit;
      end if;
                                       -- Обработка
      nCurrent :=
        RefreshCachedDirectory(
           cachedDirectoryId => cachedDirectoryId
           , minPriorityOrder => minPriorityOrder
           , maxPriorityOrder => maxPriorityOrder
           , pathMask => pathMask
           , batchShortName => batchShortName
        );
      if nCurrent > 0 then
        nHandleCount := nHandleCount + nCurrent;
                                       -- Если достигнут лимит, выходим
                                       -- из процедуры обработчика
        if nHandleCount >= maxRefreshCount then
          exit;
        end if;
        pkg_FileHandlerUtility.InitRequestCheckTime;
      end if;
    else
                                       -- Время проверки запроса не поступило
                                       -- Тогда проверяем команду
                                       -- с учётом интервала ожидания запроса
      if pkg_FileHandlerUtility.WaitForCommand(
        command => pkg_TaskHandler.Stop_Command
        , checkRequestTimeOut => checkRequestTimeout
      )
      then
        exit;
      end if;
    end if;
  end loop;
  logger.Info('Выполнено обновлений: ' || to_char( nHandleCount ));
  pkg_TaskHandler.CleanHandler;
exception when others then
  pkg_TaskHandler.CleanHandler;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка обработчика кэшированных директорий' )
    , true
  );
end HandleCachedDirectory;

end pkg_FileHandlerCachedDirectory;
/