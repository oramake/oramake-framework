create or replace package body pkg_FileHandlerRequest is
/* package body: pkg_FileHandlerRequest::body */

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_FileHandlerBase.Module_Name
    , objectName => 'pkg_FileHandlerRequest'
  );

/* iconst: Max_Records_Block_Size
 Максимальное количество записей в блоке
 обработки записей
*/
  Max_Records_Block_Size integer := 1;

/* ivar: curLockRequest
  Курсор для резервирования запросов
*/
  cursor curLockRequest(
    requestId integer
    , minPriorityOrder integer
    , maxPriorityOrder integer
    , operationCode varchar2
    , batchShortName varchar2
    , maxRecordsCount integer
    , cachedDirectoryId integer
  )
  is
                                       -- Для использования
                                       -- доступа по первичному ключу
    select /*+ordered*/
      request_id
      , used_cached_directory_id
    from
      flh_request
    where
      request_id in
      (
      select
        request_id
      from
      (
      select
        request_id
      from
        v_flh_request_wait w
      where
                                     -- Если соотв. параметр не задан
                                     -- то условие не применяется
        ( requestId is null
          or w.request_id = requestId
        )
        and
        ( minPriorityOrder is null
          or minPriorityOrder <= priority_order
        )
        and
        ( maxPriorityOrder is null
          or maxPriorityOrder >= priority_order
        )
        and
        ( operationCode is null
          or operationCode = operation_code
        )
        and
        ( batchShortName is null
          or batchShortName = batch_short_name
        )
        and
        ( cachedDirectoryId is null
          or
          operation_code in
          ( pkg_FileHandlerBase.FileList_OperationCode
            , pkg_FileHandlerBase.LoadText_OperationCode
            , pkg_FileHandlerBase.LoadBinary_OperationCode
          )
          and
          cachedDirectoryId = used_cached_directory_id
        )
                                     -- Записи ещё не захвачены другим
                                     -- сеансом
        and
        (
          handler_sid is null
          or not exists
          (
          select
            null
          from
            v$session ss
          where
            ss.sid = w.handler_sid
            and ss.serial# = w.handler_serial#
          )
        )
                                     -- Упорядочиваем записи
                                     -- при заливке в массив
      order by
        w.priority_order desc nulls last
        , w.request_id
      )
    where
      rownum <= maxRecordsCount
    )
    for update of
      request_state_code
      , handler_sid
      , handler_serial#
    nowait;

/* func: CreateFileData
  Добавление записи данных файла

  Возврат:
    - id добавленной записи
*/
function CreateFileData
return integer
is
                                       -- Id данных файла
  fileDataId integer := null;
begin
  logger.Debug('CreateFileData: start');
                                       -- Записываем заголовок данных
                                       -- файла
  insert into flh_file_data(
    file_data_id
  )
  values
  (
    flh_file_data_seq.nextVal
  )
  returning
    file_data_id
  into
    fileDataId;
  return fileDataId;
exception when others then
                                       -- Не записываем
                                       -- данные в log,
                                       -- так как exception может
                                       -- отлавливаться
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка добавления данных файла'
    , true
  );
end CreateFileData;

/* func: CreateFileData(loadedBlob)
  Добавление записи данных файла

  Параметры:
    loadedBlob               - добавленный в таблицу
                               blob для обработки двоичных данных

  Возврат:
    - id добавленной записи
*/
function CreateFileData(
  loadedBlob in out nocopy blob
)
return integer
is
                                       -- Id данных файла
  fileDataId integer := null;
begin
                                       -- Записываем заголовок данных
                                       -- файла
  insert into flh_file_data(
    file_data_id
    , binary_data
  )
  values
  (
    flh_file_data_seq.nextVal
    , empty_blob()
  )
  returning
    file_data_id
    , binary_data
  into
    fileDataId
    , loadedBlob;
  return fileDataId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка добавления данных файла'
    , true
  );
end CreateFileData;

/* func: CreateRequest
  Создаёт запрос для обработчика.

  Параметры:
    operationCode        - код операции ( см. <pkg_FileHandlerBase> )
    commandText          - текст OS-команды
    fileFullPath         - путь к имени файла( директории)
    fileMask             - маска для файлов. Использование аналогично
                           использованию в sql-операторе like escape '\'
    maxListCount         - максимальное количество файлов в списке
    fileDestPath         - путь к имени файла-назначения
                           для операции копирования
    isOverwrite          - флаг перезаписи файла
                         ( см. <pkg_FileHandler.FileCopy )
    writeMode            - режим записи в существующий файл
                         ( см. <pkg_FileHandler.UnloadTxt> )
    charEncoding         - кодировка для выгрузки файла ( по-умолчанию используется
                           кодировка базы)
    isGzipped            - флаг сжатия с помощью GZIP
    colText              - коллекция clob для выгрузки в файл
    useCache             - использовать ли данные кэш-директории.
                           По-умолчанию использовать.

  Примечание:
    - функция выполняется в автономной транзакции
    для того, чтобы обработчик мог увидеть данные
    запроса
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
return integer
is
  pragma autonomous_transaction;
                                       -- Id созданного запроса
  requestId integer;
                                       -- Id данных файла
  fileDataId integer := null;

  procedure AddTextData
  is
  -- Добавление данных для выгрузки
                                       -- Коллекция для инициализации
                                       -- order-by
    type tabInteger is table of integer;
    colInteger tabInteger := tabInteger();
  begin
    fileDataId := CreateFileData;
    logger.Debug('AddTextData: start');
                                       -- Записываем данные
                                       -- в нужном поряде
                                       -- из временной таблицы
                                       -- уровня сессии
    colInteger.extend( colText.count );
    logger.Debug('AddTextData: colInteger assign');
    if colInteger.count > 0 then
      for i in colInteger.first..colInteger.last loop
        colInteger(i) := i;
      end loop;
      logger.Debug('AddTextData: forall');
      forall i in colText.first..colText.last
        insert into flh_text_data(
          file_data_id
          , order_by
          , text_data
        )
        values(
          fileDataId
          , colInteger(i)
          , colText(i)
        );
      logger.Debug('AddTextData: sql%rowcount=' || sql%rowcount);
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка добавления данных файла' )
      , true
    );
  end AddTextData;

begin
  if operationCode = pkg_FileHandlerBase.UnloadText_OperationCode
  and colText is not null
  then
    AddTextData;
  end if;
                                      -- Добавляем запрос
  insert into flh_request(
    operation_code
    , command_text
    , file_full_path
    , file_mask
    , max_list_count
    , file_dest_path
    , is_ovewrite
    , write_mode
    , char_encoding
    , is_gzipped
    , file_data_id
    , batch_short_name
  )
  values(
    operationCode
    , commandText
    , fileFullPath
    , fileMask
    , maxListCount
    , fileDestPath
    , isOverwrite
    , writeMode
    , charEncoding
    , isGzipped
    , fileDataId
    , pkg_FileHandlerUtility.GetBatchShortName
  )
  returning
    request_id
  into
    requestId;
  if coalesce( useCache, true ) and operationCode in
  ( pkg_FileHandlerBase.FileList_OperationCode
    , pkg_FileHandlerBase.LoadText_OperationCode
    , pkg_FileHandlerBase.LoadBinary_OperationCode
    , pkg_FileHandlerBase.Delete_OperationCode
    , pkg_FileHandlerBase.Copy_OperationCode
  )
  then
    pkg_FileHandlerCachedDirectory.UseCache(
      requestId => requestId
      , operationCode => operationCode
      , fileFullPath => fileFullPath
      , requestTime => systimestamp
                                       -- Используем
                                       -- маску для создания записи
                                       -- кэшированной директории
                                       -- если она задана через пакет
                                       -- pkg_FileHandlerUtility
      , createCacheTextFileMask => pkg_FileHandlerUtility.GetCreateCacheTextMask
    );
  end if;
  commit;
  return requestId;
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка создания запроса' )
    , true
  );
end CreateRequest;

/* proc: WaitForRequestInternal
  Ожидание запроса для обработки без генерации
  exception в случае ошибки обработки

  Параметры:
    requestId          - id запроса
*/
procedure WaitForRequestInternal(
  requestId integer
)
is
                                       -- Временная переменная
                                       -- для количества запросов в ожидании
  nCount integer;
begin
  pkg_FileHandlerUtility.InitCheckTime;
  pkg_TaskHandler.SetAction('file request wait');
  logger.Debug( 'WaitForRequestInternal: start' );
  loop
                                       -- Наступило время проверять запрос
    if pkg_FileHandlerUtility.NextRequestTime(
      checkRequestTimeout => pkg_FileHandlerBase.WaitRequest_Timeout
    )
    then
      logger.Trace( 'WaitForRequestInternal: check start' );
      select
        count(1)
      into
        nCount
      from
        v_flh_request_wait
      where
        request_id = requestId;
      logger.Trace( 'WaitForRequestInternal: check end' );
      exit when nCount = 0;
    else
      dbms_lock.sleep( pkg_FileHandlerBase.WaitRequest_Timeout);
    end if;
  end loop;
  logger.Debug( 'WaitForRequestInternal: end' );
  pkg_TaskHandler.SetAction('');
exception when others then
  pkg_TaskHandler.SetAction('');
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Внутренняя ошибка ожидания запроса' )
    , true
  );
end WaitForRequestInternal;

/* proc: WaitForRequest
  Ожидание запроса для обработки

  Параметры:
    requestId          - id запроса
*/
procedure WaitForRequest(
  requestId integer
)
is
                                       -- Переменные для считывания состояния
                                       -- обработки
  requestStateCode flh_request.request_state_code%type;
  errorMessage flh_request.error_message%type;
begin
  WaitForRequestInternal( requestId => requestId );
                                       -- Получаем состояние контракта
  select
    r.request_state_code
    , error_message
  into
    requestStateCode
    , errorMessage
  from
    flh_request r
  where
    request_id = requestId;
  if requestStateCode = pkg_FileHandlerBase.Error_RequestStateCode then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Возникла ошибка обработки запроса. Сообщение: ' || chr(10)
        ||  '"' || errorMessage || '"'
    );
  else
    logger.Debug('Запрос обработан( код состояния: "'
      || requestStateCode || '")'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка ожидания запроса для обработки' )
    , true
  );
end WaitForRequest;

/* proc: WaitForRequest(command)
  Ожидание запроса для обработки
*/
procedure WaitForRequest(
  requestId integer
  , output in out nocopy clob
  , error in out nocopy clob
  , commandResult out integer
)
is
begin
  WaitForRequest( requestId => requestId );
                                       -- Получаем данные выполнения
  select
    r.command_result
    , tout.text_data
    , terr.text_data
  into
    commandResult
    , output
    , error
  from
    flh_request r
    , flh_text_data tout
    , flh_text_data terr
  where
    request_id = requestId
    and tout.file_data_id = r.file_data_id
    and tout.order_by = 1
    and terr.file_data_id = r.file_data_id
    and terr.order_by = 2
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка ожидания запроса для обработки' )
    , true
  );
end WaitForRequest;

/* proc: SimpleProcessRequest
  Обработка запроса без предварительного резервирования
  записей и установки статуса.

  Параметры:
    requestId                - id запроса
    resultStateCode          - новое состояние запроса
    errorCode                - код ошибки обработки.
                               В случае успешного выполнения null.
    errorMessage             - сообщение ошибки обработки
                               В случае успешного выполнения null.
*/
procedure SimpleProcessRequest(
  requestId integer
  , resultStateCode out varchar2
  , errorCode out integer
  , errorMessage out varchar2
)
is
                                       -- Данные запроса
  recRequest flh_request%rowtype;

  procedure GetRequest
  is
  begin
    select
      *
    into
      recRequest
    from
      flh_request
    where
      request_id = requestId
    for update nowait;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Ошибка получения данных запроса'
        )
      , true
    );
  end GetRequest;

  procedure ProcessRequestInternal
  is
  -- Обработка запроса в зависимости от операции
  -- и с "отловом" исключения

    procedure ProcessFileList
    is
    -- Получение списка файлов
    begin
      if recRequest.operation_code = pkg_FileHandlerBase.FileList_OperationCode
      then
        pkg_FileOrigin.FileList(
          fromPath => recRequest.file_full_path
          , fileMask => recRequest.file_mask
          , maxCount => recRequest.max_list_count
        );
      elsif recRequest.operation_code = pkg_FileHandlerBase.DirList_OperationCode
      then
        logger.Trace(
          'SubDirList: count='
          || to_char(
               pkg_FileOrigin.SubdirList(
                 fromPath => recRequest.file_full_path
               )
             )
        );
      else
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Неверная ветка программы'
        );
      end if;
                                       -- Загружаем список файлов
                                       -- из временной таблицы
      delete from
        flh_request_file_list
      where
        request_id = recRequest.request_id;
      insert into flh_request_file_list(
        request_id
        , operation_code
        , file_name
        , file_size
        , last_modification
      )
      select
        recRequest.request_id
        , recRequest.operation_code
        , file_name
        , file_size
        , last_modification
      from
        tmp_file_name;
    end ProcessFileList;

    procedure CleanFileData
    is
    begin
                                       -- Удаляем записи
                                       -- данных запроса
      delete from
        flh_text_data
      where
        file_data_id = recRequest.file_data_id;
      delete from
        flh_file_data
      where
        file_data_id = recRequest.file_data_id;
    end CleanFileData;

    procedure ProcessLoadClob
    is
    -- Считывание clob из файла
                                       -- id данных файла
      fileDataId integer;
                                       -- Считываемый clob
      loadedClob clob;
    begin
      CleanFileData;
                                       -- Создаём записи
      fileDataId := CreateFileData;
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
      pkg_FileOrigin.LoadClobFromFile(
        fromPath => recRequest.file_full_path
        , dstLob => loadedClob
      );
                                       -- Записываем ссылку
                                       -- на данные
      update
        flh_request
      set
        file_data_id = fileDataId
      where
        request_id = recRequest.request_id;
    end ProcessLoadClob;

    procedure ProcessLoadBlob
    is
    -- Считывание blob из файла
                                       -- Считываемый clob
      loadedBlob blob;
                                       -- id данных файла
      fileDataId integer;
    begin
                                       -- Чистим данные по запросу
      CleanFileData;
                                       -- Создаём запись
      fileDataId := CreateFileData( loadedBlob => loadedBlob );
      pkg_FileOrigin.LoadBlobFromFile(
        fromPath => recRequest.file_full_path
        , dstLob => loadedBlob
      );
                                       -- Записываем ссылку
                                       -- на данные
      update
        flh_request
      set
        file_data_id = fileDataId
      where
        request_id = recRequest.request_id;
    end ProcessLoadBlob;

    procedure ProcessCopy
    is
    -- Копирование файла
    begin
      pkg_FileOrigin.FileCopy(
        fromPath => recRequest.file_full_path
        , toPath => recRequest.file_dest_path
        , overwrite => recRequest.is_ovewrite
      );
    end ProcessCopy;

    procedure ProcessDelete
    is
    -- Удаление файла
    begin
      pkg_FileOrigin.FileDelete(
        fromPath => recRequest.file_full_path
      );
    end ProcessDelete;

    procedure ProcessUnloadTxt
    is
    -- Копирование файла
    begin
      insert into doc_output_document(
        output_document
      )
      select
        t.text_data
      from
        flh_text_data t
      where
        file_data_id = recRequest.file_data_id
      order by
        order_by;
      pkg_FileOrigin.UnloadTxt(
        toPath => recRequest.file_full_path
        , writeMode => recRequest.write_mode
        , charEncoding => recRequest.char_encoding
        , isGZipped => recRequest.is_gzipped
      );
    end ProcessUnloadTxt;

    procedure ProcessCommand
    is
    -- Копирование файла
                                       -- id данных файла
      fileDataId integer;
                                       -- Результаты выполнения
      output clob;
      error clob;
      commandResult flh_request.command_result%type;
    begin
      CleanFileData;
                                       -- Создаём записи
      fileDataId := CreateFileData;
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
        output;
      insert into flh_text_data(
        file_data_id
        , text_data
        , order_by
      )
      values(
        fileDataId
        , empty_clob()
        , 2
      )
      returning
        text_data
      into
        error;
                                       -- Выполняем команду через
                                       -- java
      commandResult :=
        pkg_FileOrigin.ExecCommand(
          command => recRequest.command_text
          , output => output
          , error => error
        );
      update
        flh_request
      set
        file_data_id = fileDataId
        , command_result = commandResult
      where
        request_id = recRequest.request_id;
    end ProcessCommand;

  begin
    savepoint beginProcess;
    case when
                                       -- Получение списка файлов
      recRequest.operation_code = pkg_FileHandlerBase.FileList_OperationCode
      or recRequest.operation_code = pkg_FileHandlerBase.DirList_OperationCode
    then
      ProcessFileList;
    when
                                       -- Чтение clob из файла
      recRequest.operation_code = pkg_FileHandlerBase.LoadText_OperationCode
    then
      ProcessLoadClob;
    when
                                       -- Чтение blob из файла
      recRequest.operation_code = pkg_FileHandlerBase.LoadBinary_OperationCode
    then
      ProcessLoadBlob;
    when
                                       -- Копирование файла
      recRequest.operation_code = pkg_FileHandlerBase.Copy_OperationCode
    then
      ProcessCopy;
    when
                                       -- Выгрузка файла
      recRequest.operation_code = pkg_FileHandlerBase.UnloadText_OperationCode
    then
      ProcessUnloadTxt;
    when
                                       -- Команда OS
      recRequest.operation_code = pkg_FileHandlerBase.Command_OperationCode
    then
      ProcessCommand;
    when
                                       -- Удаление файла
      recRequest.operation_code = pkg_FileHandlerBase.Delete_OperationCode
    then
      ProcessDelete;
    else
      raise_application_error(
        pkg_Error.ProcessError
        , 'Обработка для операции "' || recRequest.operation_code || '"'
          || ' не реализована'
      );
    end case;
                                       -- Успешно обработали запрос
    resultStateCode := pkg_FileHandlerBase.Processed_RequestStateCode;
  exception when others then
                                       -- Ошибка обработки
    resultStateCode := pkg_FileHandlerBase.Error_RequestStateCode;
    errorCode := SQLCODE;
    errorMessage := SQLERRM;
    rollback to beginProcess;
  end ProcessRequestInternal;

begin
  logger.Info('Process start  :(requestId='
    || to_char( requestId ) || ')');
  GetRequest;
  ProcessRequestInternal;
  logger.Info('Process finish :(requestId='
    || to_char( requestId ) || ')');
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка обработки запроса( '
        || 'requestId=' || to_char( requestId )
        || 'operationCode="' || recRequest.operation_code ||'")'
      )
    , true
  );
end SimpleProcessRequest;

/* func: ProcessRequest(func)
  Обработка текущих ожидающих запросов
  с фильтрующими условиями

  Параметры:
    requestId                - id запроса
    minPriorityOrder         - минимальный приоритет запроса
    maxPriorityOrder         - максимальный приоритет запроса
    operationCode            - код операции запроса
    batchShortName           - наименования батча, создавшего запрос
    maxRequestCount          - максимальное количество обрабатываемых
                               запросов
    cachedDirectoryId        - id кэшированной директории

  Возврат:
    - количество записей, для которых была выполнена попытка обработки

  Замечание:
    - процедура оформлена как автономная транзакция,
   так как связана с операциями в файловой системе
*/
function ProcessRequest(
  requestId integer := null
  , minPriorityOrder integer := null
  , maxPriorityOrder integer:= null
  , operationCode varchar2 := null
  , batchShortName varchar2:= null
  , maxRequestCount integer := null
  , cachedDirectoryId integer := null
)
return integer
is
  pragma autonomous_transaction;
                                       -- Типы коллекций
                                       -- информации о загрузке
                                       -- На каждое поле создаётся отдельная коллекция
                                       -- в связи с ограничениями реализации оператора forall
  type TColRequestId is table of flh_request.request_id%type;
  type TColCachedDirId is table of flh_request.used_cached_directory_id%type;
  type TColRequestStateCode is table of flh_request.request_state_code%type;
  type TColErrorCode is table of flh_request.error_code%type;
  type TColErrorMessage is table of flh_request.error_message%type;
                                      -- Коллекции для хранения информации
                                      -- о загрузке
  colRequestId TColRequestId := TColRequestId();
  colCachedDirId TColCachedDirId := TColCachedDirId();
  colRequestStateCode TColRequestStateCode := TColRequestStateCode();
  colErrorCode TColErrorCode := TColErrorCode();
  colErrorMessage TColErrorMessage := TColErrorMessage();

  handlerSid number := pkg_Common.GetSessionSid;
  handlerSerial# number := pkg_Common.GetSessionSerial;
                                       -- Количество обработанных записей
  nProcessed integer := 0;
                                       -- Количество ошибок
  nError integer := 0;

  procedure ReserveRequest
  is
    couldLock boolean;

    procedure GetRequest
    is
    -- Открытие курсора и получения массива
    begin
      open
        curLockRequest(
          requestId => requestId
          , minPriorityOrder => minPriorityOrder
          , maxPriorityOrder => maxPriorityOrder
          , operationCode => operationCode
          , batchShortName => batchShortName
          , cachedDirectoryId => cachedDirectoryId
          , maxRecordsCount =>
              least(
                coalesce(
                  maxRequestCount - nProcessed
                  , Max_Records_Block_Size
                )
                , Max_Records_Block_Size
              )
        );
      couldLock := true;
                                       -- Загоняем данные из курсора в массив
      fetch
        curLockRequest
      bulk collect into
        colRequestId
        , colCachedDirId;
      close curLockRequest;
    exception when others then
                                       -- Если не удаётся зарезервировать
      if SQLCODE = pkg_Error.ResourceBusyNowait then
        couldLock := false;
      end if;
      if curLockRequest%ISOPEN then
        close curLockRequest;
      end if;
    end GetRequest;

  begin
    pkg_TaskHandler.SetAction( 'Reserve' );
                                       -- Получаем id записей
    GetRequest;
                                       -- Коллекция инициализирована
    if colRequestId.Count > 0 then
                                       -- Присваиваем записям атрибуеты сеанса
      forall i in colRequestId.first..colRequestId.last
        update
          flh_request r
        set
          r.handler_sid = handlerSid
          , r.handler_serial# = handlerSerial#
          , r.handler_reserved_time = systimestamp
        where
          r.request_id = colRequestId( i );
                                       -- Заполняем массивы
      colRequestStateCode.delete;
      colRequestStateCode.extend( 1 );
      colRequestStateCode( 1 ) := pkg_FileHandlerBase.Wait_RequestStateCode;
      colRequestStateCode.extend( colRequestId.count - 1, 1 );
      colErrorCode.delete;
      colErrorCode.extend( colRequestId.count );
      colErrorMessage.delete;
      colErrorMessage.extend( colRequestId.count );
    end if;
    if colRequestId.Count > 0 then
      logger.Debug('Зарезервировано записей: '
        || to_char( colRequestId.Count )
      );
    end if;
    pkg_TaskHandler.SetAction( '' );
  exception when others then
    pkg_TaskHandler.SetAction( '' );
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка резервирования записей' )
      , true
    );
  end ReserveRequest;

  procedure ProcessRequest
  -- Процедура обработки захваченных данным сеансом записей
  is
  -- ProcessClients
  begin
    logger.Debug('Обработка ' || colRequestId.Count || ' записей...');
                                       --Пытаемся сначала обработать все записи
    pkg_TaskHandler.SetAction( 'Process' );
    for i in colRequestId.first..colRequestId.last loop
      if cachedDirectoryId is not null then
        pkg_FileHandlerCachedDirectory.SimpleProcessRequest(
          requestId => colRequestId(i)
          , cachedDirectoryId => cachedDirectoryId
          , resultStateCode => colRequestStateCode(i)
          , errorCode => colErrorCode(i)
          , errorMessage => colErrorMessage(i)
        );
      else
        SimpleProcessRequest(
          requestId => colRequestId(i)
          , resultStateCode => colRequestStateCode(i)
          , errorCode => colErrorCode(i)
          , errorMessage => colErrorMessage(i)
        );
      end if;
                                       -- Увеличиваем счётчики
      if colRequestStateCode(i)
        = pkg_FileHandlerBase.Error_RequestStateCode
      then
        nError := nError + 1;
      elsif colRequestStateCode(i)
        = pkg_FileHandlerBase.Processed_RequestStateCode
      then
        nProcessed := nProcessed + 1;
      else
        raise_application_error(
          pkg_Error.ProcessError
          , 'Некорректный статус обработки'
        );
      end if;
    end loop;
    pkg_TaskHandler.SetAction( '' );
  exception when others then
    pkg_TaskHandler.SetAction( '' );
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Ошибка обработки блока. request_id:('
          || to_char( colRequestId(1) )
          || ' - ' || to_char( colRequestId( colRequestId.Last ) )
          || ')'
        )
      , true
    );
  end ProcessRequest;

  procedure UpdateRequest
  is
  -- Обновление информации о загрузке
  begin
    pkg_TaskHandler.SetAction( 'UpdateRequest' );
    forall i in colRequestId.first..colRequestId.last
      update
        flh_request r
      set
        request_state_code = colRequestStateCode(i)
        , error_code = colErrorCode(i)
        , error_message = colErrorMessage(i)
        , last_processed  = systimestamp
        , is_handler_used = 1
      where
        request_id = colRequestId(i)
      ;
    logger.Debug('Установлен статус обработки. Записей: '
      || to_char( SQL%ROWCOUNT )
    );
    pkg_TaskHandler.SetAction( '' );
  exception when others then
    pkg_TaskHandler.SetAction( '' );
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка обновления состояния запросов' )
      , true
    );
  end UpdateRequest;

begin
  loop
                                       -- Резервируем записи для обработки,
                                       -- записав информацию о потоке
    ReserveRequest;
    commit;
    exit when colRequestId.Count = 0;
                                       -- Обрабатываем записи, записав информацию
                                       -- в массивы
    ProcessRequest;
                                       -- Используя массив, обновляем записи
    UpdateRequest;
    commit;
  end loop;
  if nProcessed > 0 or nError > 0 then
    logger.Debug('Обработано: ' || nProcessed || ' ; Ошибок: ' || nError );
  end if;
  commit;
  return nProcessed + nError;
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
     , logger.ErrorStack(
        'Ошибка обработки('
        || ' requestId=' || coalesce( to_char( requestId), 'null' )
        || ' minPriorityOrder=' || coalesce( to_char( minPriorityOrder), 'null' )
        || ' maxPriorityOrder=' || coalesce( to_char( maxPriorityOrder), 'null' )
        || ' batchShortName="' || batchShortName || '"'
        || ').'
      )
    , true
  );
end ProcessRequest;

/* proc: ProcessRequest
  Обработка текущих ожидающих запросов
  с фильтрующими условиями

  Параметры:
    requestId                - id запроса
    minPriorityOrder         - минимальный приоритет запроса
    maxPriorityOrder         - максимальный приоритет запроса
    operationCode            - код операции запроса
    batchShortName           - наименования батча, создавшего запрос
    maxRequestCount          - максимальное количество обрабатываемых
                               запросов
    cachedDirectoryId        - id кэшированной директории

  Возврат:
    - количество записей, для которых была выполнена попытка обработки

  Замечание:
    - вызывает <ProcessRequest(func)>
*/
procedure ProcessRequest(
  requestId integer := null
  , minPriorityOrder integer := null
  , maxPriorityOrder integer:= null
  , operationCode varchar2 := null
  , batchShortName varchar2:= null
  , maxRequestCount integer := null
  , cachedDirectoryId integer := null
)
is
  nRecords integer;
begin
  nRecords := ProcessRequest(
    requestId => requestId
    , minPriorityOrder => minPriorityOrder
    , maxPriorityOrder => maxPriorityOrder
    , operationCode => operationCode
    , batchShortName => batchShortName
    , maxRequestCount => maxRequestCount
    , cachedDirectoryId => cachedDirectoryId
  );
  if nRecords > maxRequestCount then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Внутренняя ошибка: число записей ' || to_char( nRecords )
         || 'превысило лимит ' || to_char( maxRequestCount )
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка процедуры обработки запросов' )
    , true
  );
end ProcessRequest;

/* proc: HandleRequest
  Циклическая realtime-обработка запросов
  Выход из цикла осуществляется с помощью процедуры
  pkg_TaskHandler.SendStopCommand из другой сессии, которая
  передаёт комнаду через pipe.

  Параметры:
    minPriorityOrder         - минимальный приоритет запроса
    maxPriorityOrder         - максимальный приоритет запроса
    operationCode            - код операции запроса
    batchShortName           - наименования батча, создавшего запрос
    maxRequestCount          - максимальное количество обрабатываемых
                               запросов
    cachedDirectoryId        - id кэшированной директории
    checkRequestInterval     - интервал для проверки наличия запросов
                               для обработки
  Замечание:
    - циклически вызывает <ProcessRequest(func)>
*/
procedure HandleRequest(
  minPriorityOrder integer := null
  , maxPriorityOrder integer:= null
  , operationCode varchar2 := null
  , batchShortName varchar2:= null
  , maxRequestCount integer := null
  , checkRequestInterval interval day to second
)
is
                                       -- Количество запросов
                                       -- для которых выполнена попытка обработки
  nRecords integer := 0;
                                       -- Результат вызова ProcessRequest
  nCurrent integer;
                                       -- Интервал между проверками
                                       -- наличия запросов
  checkRequestTimeout number
    := pkg_TaskHandler.ToSecond( checkRequestInterval );
begin
  pkg_FileHandlerUtility.InitHandler(
    processName  => 'FileRequestHandler'
  );
  logger.Debug( 'HandleRequest: checkRequestTimeout='
    || to_char( checkRequestTimeout)
  );
  loop
                                       -- Наступило время проверять запрос
    if pkg_FileHandlerUtility.NextRequestTime(
      checkRequestTimeout => checkRequestTimeout
    )
    then
                                       -- Проверяем команду,
                                       -- если наступило время
      if pkg_FileHandlerUtility.WaitForCommand(
           command => pkg_TaskHandler.Stop_Command
        )
      then
        exit;
      end if;
                                       -- Обработка при существовании
                                       -- запросов в состоянии ожидания
      nCurrent :=
         ProcessRequest(
            minPriorityOrder => minPriorityOrder
            , maxPriorityOrder => maxPriorityOrder
            , operationCode => operationCode
            , batchShortName => batchShortName
            , maxRequestCount => maxRequestCount - nRecords
         );
                                       -- Если запросы были обработаны
      if nCurrent > 0 then
        nRecords := nRecords + nCurrent;
                                       -- Если достигнут лимит, выходим
                                       -- из процедуры обработчика
        if nRecords >= maxRequestCount then
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
  pkg_TaskHandler.CleanHandler;
exception when others then
  pkg_TaskHandler.CleanHandler;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка обработчика запросов' )
    , true
  );
end HandleRequest;

end pkg_FileHandlerRequest;
/