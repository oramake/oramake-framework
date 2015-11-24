create or replace package body pkg_FileHandlerCachedDirectory is
/* package body: pkg_FileHandlerCachedDirectory::body */

/* ivar: logger
  ������������ ������ � ������ Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_FileHandlerBase.Module_Name
    , objectName => 'pkg_FileHandlerCachedDirectory'
  );

/* proc: SetBatchCreateCache
  ��������� �������� �����������
  ��� �����

  ���������:
  batchShortName             - ��� ����� ( sch_batch )
  textMask                   - ����� ��� ������������ ��������� ������
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
    , logger.ErrorStack( '������ ��������� �������� ��� �����' )
    , true
  );
end SetBatchCreateCache;

/* proc: AddMask
  ���������� ��������� �����

  ���������:
  cachedDirectoryId          - id ������������ ����������
  textFileMask               - ����� ��� ������������ ��������� ������
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
    , logger.ErrorStack( '������ ���������� �����' )
    , true
  );
end AddMask;

/* func: CreateCachedDirectory
  �������� ������ ������������ ����������

  ���������:
  path                       - ���� ��� ������������ ����������
                             ( ��� '\' � �����)
  textFileMask               - ����� ��� ������������ ��������� ������

  �������:
  - id ������������ ����������
*/
function CreateCachedDirectory(
  path varchar2
  , textFileMask varchar2 := null
)
return varchar2
is
  cachedDirectoryId integer;



begin
                                       -- ������ ������
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
    , logger.ErrorStack( '������ �������� ������ ������������ ���������� ('
        || ' path = "' || path || '"'
        || ' textFileMask = "' || textFileMask || '"'
        || ')'
      )
    , true
  );
end CreateCachedDirectory;

/* func: FindCachedDirectory
  ����� ���������� �� ������� ���� � �����

  ���������:
    operationCode             - ��� �������� �������
    fileFullPath              - ������ ���� � ����� ( ���������� )
    requestTime               - ����� ��� ���������� �������
    createCacheTextFileMask   - ����� ��������� ������ ��� �������� ������ � ������
                              ���� ������ �� �������. ���� �� ������, �� ������
                              �� ��������
    isListActual              - ������������ ���� ������������ ������ ������

  �������:
    - id ������������ ����������
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
                                       -- ��������� �������
  foundId integer;
                                       -- ����� ��� ���������� � ����������
                                       -- createCacheTextFileMask
  createCacheTextMaskId integer;
                                       -- ������ ��� ������ ����������
  cursor curFindCachedDirectory is
    select
      cached_directory_id
                                       -- ���� ������������ ������ ������
                                       -- ������
      , case when
                                       -- Ec�� �������� �������� �� ����
          d.last_refresh >= requestTime
            - coalesce( d.list_refresh_timeout, interval '0' second )
          or d.is_actual_when_new_file = 1
                                       -- ���� ����������
                                       -- ��������� ���������� ��� �������
                                       -- �������������� �����
          and exists
            (
            select
              1
            from
              flh_cached_file f
            where
              f.cached_directory_id = d.cached_directory_id
              and f.existing = 1
                                       -- ��� ����� ������ ������������� ����
                                       -- �� ����� �� �����
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
                                       -- ����� �����������
                                       -- � ���������� createCacheTextFileMask
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
                                        -- ��� ��������� ������ ������
                                        -- ���������� ������ ���������
                                        -- � ��������� �� ���������� �����������
      operationCode = pkg_FileHandlerBase.FileList_OperationCode
      and d.path = rtrim( fileFullPath, '\' )
      or
                                        -- ��� ������ ������
                                        -- ������ ���� ������ �����
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
                                        -- ��� ������ �������� ������
                                        -- ������ ���� ������ �����
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
                                        -- ��� ��������� ��������
                                        -- �������� ���� ������ ����������
                                        -- � ����������
      operationCode = pkg_FileHandlerBase.Delete_OperationCode
      and fileFullPath like d.path || '%'
   ;

begin
  logger.Trace('FindCachedDirectory: start...');
  open
    curFindCachedDirectory;
                                        -- � ������ ���� ����������
                                        -- �� �������
                                        -- ������������ �������� �� ����������
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
                                        -- ���� ������ �� �������
    if foundId is null then
      foundId :=
        CreateCachedDirectory(
          path => fileFullPath
          , textFileMask => createCacheTextFileMask
        );
    else
                                        -- ���� ����� ���
      if createCacheTextMaskId is null then
        AddMask(
          cachedDirectoryId => foundId
          , textFileMask => createCacheTextFileMask
        );
      end if;
    end if;
  end if;
                                        -- ���������� id
                                        -- ��������� ���������� ���� null
  logger.Trace('FindCachedDirectory: end...');
  return foundId;
exception when others then
  if curFindCachedDirectory%ISOPEN then
    close
      curFindCachedDirectory;
  end if;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ������ ������������ ����������' )
    , true
  );
end FindCachedDirectory;


/* func: FindCachedFile(error)
  ����� ������������� �����

  ���������:
    operationCode            - ��� �������� �������
    cachedDirectoryId        - id ������������ ����������
    fileFullPath             - ������ ���� � ����� ( ���������� )
    requestTime              - ����� ��� ���������� �������
    isListActual             - ������������ ���� ������������ ������ �����
    errorCode                - ������������ ��� ������ � ������,
                               ���� ���� �� ������, ���� ������
                               �� ���������
    errorMessage             - ������������ ����� ������ � ������,
                               ���� ���� �� ������, ���� ������
                               �� ���������

  �������:
    - id ������������� �����, ���� ������, ���� null
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
                                       -- ������ ��� ������ �����
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
                                       -- ���� ���������� ������� �� �����
        ( d.file_refresh_timeout is null
                                       -- ��� �� ���� �������
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
                                       -- ��������� ������ ������
  recFindCachedFile curFindCachedFile%rowtype;
begin
  open curFindCachedFile;
  fetch
    curFindCachedFile
  into
    recFindCachedFile;
  return
    recFindCachedFile.cached_file_id;
                                       -- ��������� �� ������
  if curFindCachedFile%notfound then
                                       -- ���� �� ������ � ���
    errorCode := pkg_FileHandlerBase.FileCacheNotFound_ErrorCode;
    errorMessage := '���� �� ������ � cache';
  elsif recFindCachedFile.existing = 0 then
                                       -- ���� ������� ��� ��������������
    errorCode := pkg_FileHandlerBase.FileCacheNotExists_ErrorCode;
    errorMessage := '���� ������� ��� ��������������';
    if recFindCachedFile.delete_request_id is not null then
      errorMessage := errorMessage || chr(10)
        || ', ����� �������� (requestId='
        || to_char( recFindCachedFile.delete_request_id) || ')';
    end if;
  elsif recFindCachedFile.file_data_id is null then
                                       -- ��� ������
    errorCode := pkg_FileHandlerBase.FileCacheNoData_ErrorCode;
    errorMessage := '������ ����� �� ��������� � cache';
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
      , '���������� ������ FindCachedFile: '
        || chr(10) || '������ ������� �������������'
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
    , logger.ErrorStack( '������ ������ ������������� ����� ('
        || 'operationCode="' || operationCode || '"'
        || ', cachedDirectoryId="' || to_char(cachedDirectoryId) || '"'
        || ', fileFullPath="' || fileFullPath || '"'
        || ')'
      )
    , true
  );
end FindCachedFile;

/* func: FindCachedFile
  ����� ������������� �����

  ���������:
    operationCode            - ��� �������� �������
    cachedDirectoryId        - id ������������ ����������
    fileFullPath             - ������ ���� � ����� ( ���������� )
    requestTime              - ����� ��� ���������� �������
    isListActual             - ������������ ���� ������������ ������ �����

  �������:
    - id ������������� �����, ���� ������, ���� null
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
                                       -- out-���������
                                       -- ��� ������ ����������
                                       -- FindCachedFile
  errorCode flh_request.error_code%type;
  errorMessage flh_request.error_message%type;
                                       -- ��������� �������
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
    logger.Debug('��������� ������ ������������� �����: '
      || chr(10) || '"' || errorMessage || '"'
    );
  end if;
  return
    foundCachedFileId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ������ ������������� ����� ('
        || 'operationCode="' || operationCode || '"'
        || ', cachedDirectoryId="' || to_char(cachedDirectoryId) || '"'
        || ', fileFullPath="' || fileFullPath || '"'
        || ')'
      )
    , true
  );
end FindCachedFile;


/* proc: SimpleProcessRequest
  ��������� ������� ��� ���������������� ��������������
  ������� � ��������� ������� � �������������� ������������
  ����������

  ���������:
    requestId                - id �������
    cachedDirectoryId        - id ������������ ����������
    cachedFileId             - id ������������� �����,
                             ���� �� ��� ������ �������
    resultStateCode          - ������������ ����� ��������� �������

    fileFullPath             - ������ ���� � ����� ( ���������� )
    requestTime              - ����� ��� ���������� �������
    isListActual             - ������������ ���� ������������ ������ �����
    errorCode                - ������������ ��� ������ � ������,
                               ���� ���� �� ������, ���� ������
                               �� ���������
    errorMessage             - ������������ ����� ������ � ������,
                               ���� ���� �� ������, ���� ������
                               �� ���������
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
  -- ��������� ���� ��������
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
      , logger.ErrorStack( '������ ��������� ��������' )
      , true
    );
  end GetRequestData;

  procedure ProcessFileList
  is
  -- ��������� ������ ������ �� cache
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
      , logger.ErrorStack( '������ ��������� ������ ������' )
      , true
    );
  end ProcessFileList;

  procedure ProcessLoad
  is
  -- �������� ����� � �������������� cache
                                       -- �������������� id
                                       -- �����
    usedCachedFileId integer;
                                       -- ���������� ��� out-���������
                                       -- FindCachedFile
    isFileActual integer;
  begin
                                       -- �������� ������������ ��������
    if recRequest.file_data_id is not null then
      raise_application_error(
        pkg_Error.ProcessError
        , '��� ������� (request_id = '
          || to_char( recRequest.request_id) || ')'
          || ' file_data_id ��� ����������'
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
                                       -- �������� ������������������ ������
    if usedCachedFileId is null and
    ( errorMessage is not null or errorCode is not null )
    or
    usedCachedFileId is null and
    ( errorMessage is null or errorCode is null )
    then
      raise_application_error(
        pkg_Error.ProcessError
        , '���������� ������: ������ ������ ����� � cache �������������'
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
      , logger.ErrorStack( '������ ��������� ������ ������' )
      , true
    );
  end ProcessLoad;

begin
                                       -- �������� ������ �������
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
      , '�������� � ����� "' || recRequest.operation_code  || '"'
        || ' �� ����� ���� ���������� � ������� cache'
    );
  end case;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��������� ������� � ������� ����( '
        || 'requestId = ' || to_char( requestId)
        || ')'
      )
    , true
  );
end SimpleProcessRequest;

/* proc: UseCache
  ��������� ������� � ��������������
  ���.

  ���������:
    requestId                - id �������
    operationCode            - ��� �������� �������
    fileFullPath             - ������ ���� � ����� ( ���������� )
    requestTime              - ����� ��� ���������� �������
    createCacheTextFileMask  - ����� ��������� ������ ��� �������� ������
                               ������������ ���������� � ������ ���� ������ �� �������.
                               ���� �� ������, �� ������ ������������ ����������
                               � ������ ���������� �� ��������.
*/
procedure UseCache(
  requestId integer
  , operationCode varchar2
  , fileFullPath varchar2
  , requestTime timestamp with time zone
  , createCacheTextFileMask varchar2 := null
)
is
                                       -- Id ��������� ����������
  cachedDirectoryId integer;
                                       -- Id ���������� �����
  cachedFileId integer;
                                       -- ��������� �� ������
                                       -- ������ ������ ����������
  isListActual integer;
                                       -- ��������� �� ������ �����
  isFileActual integer;
                                       -- out-��������� SimpleProcessRequest
  errorCode flh_request.error_code%type;
  errorMessage flh_request.error_message%type;
  resultStateCode flh_request.request_state_code%type;

  procedure GetActuality
  is
  -- ��������� ������ ������������ ������ � cache
  begin
    cachedDirectoryId :=
      FindCachedDirectory(
        operationCode => operationCode
        , fileFullPath => fileFullPath
        , requestTime => requestTime
        , createCacheTextFileMask => createCacheTextFileMask
        , isListActual => isListActual
      );
                                       -- ���� ���������� �������
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
      , logger.ErrorStack( '������ ��������� ������ �����������' )
      , true
    );
  end GetActuality;

  procedure ProcessDelete
  is
  -- ��������� ������� �� �������� ��� cache
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
      , logger.ErrorStack( '������ ��������� ������� �� �������� ��� cache' )
      , true
    );
  end ProcessDelete;

begin
                                       -- ���������� ����������
                                       -- �� ������������
  GetActuality;
  if operationCode = pkg_FileHandlerBase.Delete_OperationCode then
                                       -- ������ ���������� �� ��������
    ProcessDelete;
  end if;
  if
                                       -- ���� ������ ���������
    cachedDirectoryId is not null
    and isListActual = 1
    and
    (
      operationCode = pkg_FileHandlerBase.FileList_OperationCode
      or
                                       -- ��� ���������� �����
                                       -- ����� ������������� � ������������
                                       -- ������
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
    logger.Debug('������ � ��� �� ��������� ('
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
    , logger.ErrorStack( '������ ��������� �������, ������������ ���' )
    , true
  );
end UseCache;

/* proc: RefreshCachedDirectory
  ���������� ���������� ������������ ����������

  ���������:
    cachedDirectoryId        - id ������������ ����������
    requestTime              - ����� ��� ���������� �������

  ���������:
    - ��������� ��������� � ���� ���������� ����������
  ��� ��� ������������ �������� � �������� �������
*/
procedure RefreshCachedDirectory(
  cachedDirectoryId integer
  , requestTime timestamp with time zone
)
is
  pragma autonomous_transaction;
                                       -- ������ ������������ ����������
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
      , logger.ErrorStack( '������ �������������� ����������' )
      , true
    );
  end GetCachedDirectory;

  procedure RefreshFileList
  is
  -- ���������� ������ ������
                                       -- ���������� ����������
                                       -- �������������� ������
    nNew integer;
    nDeleted integer;

    procedure AddNew
    is
    -- ���������� � ������
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
                                       -- ����� �����
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
        , logger.ErrorStack( '������ ���������� � ������' )
        , true
      );
    end AddNew;

    procedure UpdateList
    is
    -- ������������ ������
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
        , logger.ErrorStack( '������ ���������� ������' )
        , true
      );
    end UpdateList;

    procedure DeleteOld
    is
    -- ������� � ��������������� �����
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
        , logger.ErrorStack( '������ ������ � ������������� ������' )
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
      logger.Debug('��������� � ������: ' || to_char( nNew ) );
    end if;
    if nDeleted > 0 then
      logger.Debug('������� �� ������: ' || to_char( nDeleted ) );
    end if;
    pkg_TaskHandler.SetAction('');
  exception when others then
    pkg_TaskHandler.SetAction('');
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( '������ ���������� ������ ������' )
      , true
    );
  end RefreshFileList;

  procedure RefreshFileData
  is
  -- ���������� ������ ������
                                       -- Id ������ �������� �����
    fileDataId integer;
                                       -- ������ ��� �������
                                       -- ������ ��� ��������
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
                                       -- ��������� ������
          (
          select
            t.text_data
          from
            flh_text_data t
          where
            t.file_data_id = f.file_data_id
            and t.order_by = 1
          ) as text_data
                                       -- �������� ������
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
                                       -- ���� ���� �� ��������
            f.last_load is null
            or
                                       -- ���� ���� �������� ��������
                                       -- � ������ �������
            d.file_refresh_timeout is not null
            and f.last_load <= requestTime - d.file_refresh_timeout
          )
        )
                                       -- ���� ����� ��������� ����
      where
        text_mask_id is not null
        or binary_mask_id is not null
    ;

    procedure LoadText( recFile curRefreshFileData%rowtype )
    is
    -- �������� ��������� ������
                                       -- ����������� clob
      loadedClob clob;
    begin
      if recFile.text_data is not null then
        loadedClob := recFile.text_data;
      else
        fileDataId := coalesce(
          fileDataId
          , pkg_FileHandlerRequest.CreateFileData()
        );
                                       -- ���� clob-� ���,
                                       -- ������
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
      logger.Debug('�������� ��������� ����: file_full_path = '
        || '"' || recFile.file_full_path || '"'
      );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.ErrorStack( '������ �������� ���������� �����('
            || 'file_full_path="' || recFile.file_full_path ||'"'
            || ')'
          )
        , true
      );
    end LoadText;

    procedure LoadBinary( recFile curRefreshFileData%rowtype )
    is
    -- �������� �������� ������
                                       -- ����������� blob
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
      logger.Debug('�������� �������� ����: file_full_path = '
        || '"' || recFile.file_full_path || '"'
      );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.ErrorStack( '������ �������� ��������� �����('
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
                                       -- �������� ������������
                                       -- ��������� file_data_id
      if recFile.binary_mask_id is not null
      and recFile.file_data_id <> fileDataId then
        raise_application_error(
          pkg_Error.ProcessError
          , '���������� ������: ���������� ������ file_data_id='
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
      , logger.ErrorStack( '������ �������� ������ ������' )
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
                                       -- ���������� ����������
                                       -- ��� ��������� ��������
  pkg_FileHandlerRequest.ProcessRequest(
    cachedDirectoryId => cachedDirectoryId
  );
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ���������� ������������ ���������� ('
        || 'cachedDirectoryId=' || to_char( cachedDirectoryId )
        || ' )'
      )
    , true
  );
end RefreshCachedDirectory;

/* func: RefreshCachedDirectory(condition)
  ���������� ���������� ������������ ����������

  ���������:
    cachedDirectoryId        - id ������������ ����������
    minPriorityOrder         - ����������� ��������� ������������
                               ����������
    maxPriorityOrder         - ������������ ��������� ������������
                               ����������
    pathMask                 - ����� ��� ����� ������������
                               ����������
    batchShortName           - ����, ��������������� � ������������
                               �����������
    maxRefreshCount          - ������������ ���������� ����������
                               ����������
  �������:
    - ���������� ����������
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
                                       -- ���������� ���������� ����������
  nCount integer := 0;
                                       -- ������� ����� ��� ����������
  currentRequestTime timestamp with time zone;
                                       -- ������ ��� �������
                                       -- ��������� ���������� ����������
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
                                       -- ���������� ����������
                                       -- ����������, ��������� ����������
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
        '������ ��������� ������������ ����������('
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
  ���������� ������������ ����������

  ���������:
    cachedDirectoryId        - id ������������ ����������
    minPriorityOrder         - ����������� ��������� ������������
                               ����������
    maxPriorityOrder         - ������������ ��������� ������������
                               ����������
    pathMask                 - ����� ��� ����� ������������
                               ����������
    batchShortName           - ����, ��������������� � ������������
                               �����������
    maxRefreshCount          - ������������ ���������� ����������
                               ����������
    checkInterval            - �������� ��� �������� ������������
                               ���������� � ���� ����������
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
                                       -- ���������� ����������
  nHandleCount integer := 0;
                                       -- ��������� ������ ���������
                                       -- RefreshCachedDirectory
  nCurrent integer;
                                       -- �������� ����� ����������
                                       -- ������� ��������
  checkRequestTimeout number
    := pkg_TaskHandler.ToSecond( checkInterval );
begin
  pkg_FileHandlerUtility.InitHandler(
    processName  => 'HandleCachedDirectory'
  );
  loop
                                       -- ��������� ����� ��������� ������
    if pkg_FileHandlerUtility.NextRequestTime(
      checkRequestTimeout => checkRequestTimeout
    )
    then
                                       -- ��������� �������,
                                       -- ���� ��������� �����
      logger.Trace( 'WaitForCommand...' );
      if pkg_FileHandlerUtility.WaitForCommand(
           command => pkg_TaskHandler.Stop_Command
        )
      then
        exit;
      end if;
                                       -- ���������
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
                                       -- ���� ��������� �����, �������
                                       -- �� ��������� �����������
        if nHandleCount >= maxRefreshCount then
          exit;
        end if;
        pkg_FileHandlerUtility.InitRequestCheckTime;
      end if;
    else
                                       -- ����� �������� ������� �� ���������
                                       -- ����� ��������� �������
                                       -- � ������ ��������� �������� �������
      if pkg_FileHandlerUtility.WaitForCommand(
        command => pkg_TaskHandler.Stop_Command
        , checkRequestTimeOut => checkRequestTimeout
      )
      then
        exit;
      end if;
    end if;
  end loop;
  logger.Info('��������� ����������: ' || to_char( nHandleCount ));
  pkg_TaskHandler.CleanHandler;
exception when others then
  pkg_TaskHandler.CleanHandler;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ����������� ������������ ����������' )
    , true
  );
end HandleCachedDirectory;

end pkg_FileHandlerCachedDirectory;
/