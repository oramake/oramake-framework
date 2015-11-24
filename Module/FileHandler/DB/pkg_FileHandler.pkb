create or replace package body pkg_FileHandler is
/* package body: pkg_FileHandler::body */

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_FileHandlerBase.Module_Name
    , objectName => 'pkg_FileHandler'
  );

/* group: Функции */

/* group: Файловые операции */

/* func: GetFilePath
  Возвращает путь к файлу, сформированный из двух переданных частей.

  Параметры:
  parent                      - начальная часть пути
  child                       - конечная часть пути
*/
function GetFilePath(
  parent in varchar2
  , child in varchar2
)
return varchar2
is
begin
  return pkg_FileOrigin.GetFilePath(
    parent => parent
    , child => child
  );
end GetFilePath;

/* func: FileListInternal
  Получает список файлов( подкаталогов) каталога и
  помещает его в временную таблицу tmp_file_name.

  Параметры:
  fromPath                    - путь к каталогу
  operationCode               - операция
                                ( <pkg_FileHandlerBase.FileList_OperationCode>
                                  или <pkg_FileHandlerBase.DirList_OperationCode>
                                )
  fileMask                    - маска для файлов. Использование аналогично
                                использованию в sql-операторе like escape '\'
  maxCount                    - максимальное количество файлов в списке
  useCache                    - использовать ли данные кэш-директорий

  Возврат:
    - количество найденных файлов ( подкаталогов )
  Замечание:
    - для успешного выполнения у пользователя должны быть права доступа на уровне
      Java ( см. <DirJava>);
*/
function FileListInternal(
  operationCode varchar2
  , fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
  , useCache boolean := null
)
return integer
is
--FileList
                                       -- Id созданного запроса
                                       -- FileHandler
  requestId integer;
begin
  if operationCode not in (
    pkg_FileHandlerBase.FileList_OperationCode
    , pkg_FileHandlerBase.DirList_OperationCode
  )
  then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Неверное значение operationCode="' || operationCode || '"'
    );
  end if;
                                       -- Очищаем таблицу с результатами
  delete from tmp_file_name;
                                       -- Создаём запрос
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => FileListInternal.operationCode
      , fileFullPath => fromPath
      , fileMask => fileMask
      , maxListCount => maxCount
      , useCache => useCache
    );
                                       -- Ждём выполнения запроса
  pkg_FileHandlerRequest.WaitForRequest(
    requestId => requestId
  );
                                       -- Заполняем временную таблицу
                                       -- результирующим списком
  insert into tmp_file_name(
    file_name
    , file_size
    , last_modification
  )
  select
    file_name
    , file_size
    , last_modification
  from
    flh_request_file_list
  where
    request_id = requestId;
  return SQL%ROWCOUNT;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка получения списка файлов FileHandler('
        || ' fromPath="' || fromPath || '"'
        || ').'
      )
    , true
  );
end FileListInternal;

/* proc: FileList
  Получает список файлов( подкаталогов) каталога и
  помещает его в временную таблицу tmp_file_name.

  Параметры:
  fromPath                    - путь к каталогу
  fileMask                    - маска для файлов. Использование аналогично
                                использованию в sql-операторе like escape '\'
  maxCount                    - максимальное количество файлов в списке
  useCache                    - использовать ли данные кэш-директорий

  Замечание:
    - вызывает <FileListInternal>
*/
procedure FileList(
  fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
  , useCache boolean := null
)
is
begin
  logger.Debug( 'Количество файлов: ' ||
    to_char(
      FileListInternal(
        operationCode => pkg_FileHandlerBase.FileList_OperationCode
        , fromPath => fromPath
        , fileMask => fileMask
        , maxCount => maxCount
        , useCache => useCache
      )
    )
  );
end FileList;

/* func: SubdirList
  Получает список подкаталогов каталога

  Параметры:
  fromPath                    - путь к каталогу

  Возврат:
  - число подкаталогов;

  Замечание:
  - вызывает <FileListInternal>
*/
function SubdirList(
  fromPath varchar2
)
return integer
is
begin
  return FileListInternal(
    operationCode => pkg_FileHandlerBase.DirList_OperationCode
    , fromPath => fromPath
  );
end SubdirList;

/* proc: FileCopy
  Копирует файл.

  Параметры:
  fromPath                    - полное имя файла-источник (каталог + имя)
  toPath                      - путь к назначению (полное имя файла или только
                                каталог), если указан только каталог, тогда имя
                                нового файла будет совпадать с именем исходного
                                файла
  overwrite                   - флаг перезаписи существующего файла ( по
                                умолчанию не переписывать и выбрасывать ошибку)
  waitForRequest              - флаг "ожидать ли обработки запроса" ( по-умолчанию
                                ожидать )

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java
*/
procedure FileCopy(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := 0
  , waitForRequest integer := null
)
is
                                       -- Id созданного запроса
                                       -- FileHandler
  requestId integer;
begin
                                       -- Создаём запрос
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => pkg_FileHandlerBase.Copy_OperationCode
      , fileFullPath => fromPath
      , fileDestPath => toPath
      , isOverwrite => overwrite
    );
  if coalesce( waitForRequest, 1 ) = 1  then
                                       -- Ждём выполнения запроса
    pkg_FileHandlerRequest.WaitForRequest(
      requestId => requestId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка копирования файла FileHandler('
        || ' fromPath="' || fromPath || '"'
        || ', toPath="' || toPath || '"'
        || ', overwrite=' || to_char( overwrite)
        || ').'
      )
    , true
  );
end FileCopy;

/* proc: FileDelete
  Удаляет файл или пустой каталог.

  Параметры:
  fromPath                    - удаляемый файл
  waitForRequest              - флаг "ожидать ли обработки запроса" ( по-умолчанию
                                ожидать )
  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java
*/
procedure FileDelete(
  fromPath varchar2
  , waitForRequest integer := null
)
is
                                       -- Id созданного запроса
                                       -- FileHandler
  requestId integer;
begin
                                       -- Создаём запрос
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => pkg_FileHandlerBase.Delete_OperationCode
      , fileFullPath => fromPath
    );
  if coalesce( waitForRequest, 1 ) = 1  then
                                       -- Ждём выполнения запроса
    pkg_FileHandlerRequest.WaitForRequest(
      requestId => requestId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка удаления файла FileHandler('
        || ' fromPath="' || fromPath || '"'
        || ').'
      )
    , true
  );
end FileDelete;

/* group: Загрузка данных */

/* proc: LoadClobFromFile
  Загружает файл в CLOB.

  Параметры:
  dstLob                      - LOB для загрузки данных ( возврат)
  fromPath                    - путь к файлу

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение
    файла на уровне Java;
*/
procedure LoadClobFromFile(
  dstLob in out nocopy clob
  , fromPath varchar2
  , useCache boolean := null
)
is
                                       -- Id созданного запроса
                                       -- FileHandler
  requestId integer;
  savedClob clob;
                                       -- Длина исходного clob
  lobLength integer;
begin
                                       -- Создаём запрос
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => pkg_FileHandlerBase.LoadText_OperationCode
      , fileFullPath => fromPath
      , useCache => useCache
    );
                                       -- Ждём выполнения запроса
  pkg_FileHandlerRequest.WaitForRequest(
    requestId => requestId
  );
                                       -- Записываем считанный clob
                                       -- в параметр
  select
    t.text_data
  into
    savedClob
  from
    flh_request r
    , flh_text_data t
  where
    t.file_data_id = r.file_data_id
    and r.request_id = requestId;
                                       -- Копируем данные
  if dbms_lob.isopen( dstLob ) = 0 then
    dbms_lob.open( dstLob, dbms_lob.lob_readwrite );
  end if;
  lobLength := dbms_lob.getlength( savedClob );
  if lobLength > 0 then
    dbms_lob.copy( dstLob, savedClob, lobLength );
  end if;
  dbms_lob.close( dstLob );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка считывания текстового файла FileHandler('
        || ' fromPath="' || fromPath || '"'
        || ').'
      )
    , true
  );
end LoadClobFromFile;

/* proc: LoadBlobFromFile
  Загружает файл в BLOB.

  Параметры:
  dstLob                      - LOB для загрузки данных ( возврат)
  fromPath                    - путь к файлу

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение
    файла на уровне Java;
*/
procedure LoadBlobFromFile(
  dstLob in out nocopy blob
  , fromPath varchar2
  , useCache boolean := null
)
is
                                       -- Id созданного запроса
                                       -- FileHandler
  requestId integer;
                                       -- Сохранённый в базе blob
  savedBlob blob;
begin
                                       -- Создаём запрос
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => pkg_FileHandlerBase.LoadBinary_OperationCode
      , fileFullPath => fromPath
      , useCache => useCache
    );
                                       -- Ждём выполнения запроса
  pkg_FileHandlerRequest.WaitForRequest(
    requestId => requestId
  );
                                       -- Записываем считанный blob
                                       -- в параметр
  select
    d.binary_data
  into
    savedBlob
  from
    flh_request r
    , flh_file_data d
  where
    d.file_data_id = r.file_data_id
    and r.request_id = requestId;
                                       -- Копируем данные
  if dbms_lob.isopen( dstLob ) = 0 then
    dbms_lob.open( dstLob, dbms_lob.lob_readwrite );
  end if;
  dbms_lob.copy( dstLob, savedBlob, dbms_lob.getlength( savedBlob ) );
  dbms_lob.close( dstLob );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка считывания двоичного файла FileHandler('
        || ' fromPath="' || fromPath || '"'
        || ').'
      )
    , true
  );
end LoadBlobFromFile;

/* proc: LoadTxt
  Загружает текстовый файл в таблицу doc_input_document.

  Параметры:
  fromPath                    - путь к файлу
  byLine                      - флаг построчной загрузки файла ( для каждой
                                строки файла создается запись в таблице
                                doc_input_document)

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <LoadClobFromFile>);
  - построчная загрузка обладает низкой производительностью;
*/
procedure LoadTxt(
  fromPath varchar2
  , byLine integer
  , useCache boolean := null
)
is


  dataLob CLOB;                         --LOB, в который происходит считывание
                                        --ID документа в случае загрузки целиком
  fullDocID doc_Input_Document.input_document_id%type;

  lineLob CLOB;                         --LOB документа для текущей строки при
                                        --построчном сохранении данных
  lineOffset integer;                   --Текущее смещение для записи в строку

  readCount number;                     --Объем реально считанных данных



  function NewDocument( pLob in out nocopy CLOB)
    return doc_Input_Document.input_document_id%type
  is
  --Создает новый документ (добавляет строку) в таблице doc_Input_Document
  --
  --Параметры:
  --pLob                      - LOB текущего документа
  --
  --Возвращает ID добавленного документа

                                        --ID добавленного документа
    lDocID doc_Input_Document.input_document_id%type;
  begin
    if pLob is not null then            --Закрываем текущий LOB
      dbms_lob.close( pLob);
      pLob := null;
    end if;
    insert into doc_Input_Document      --Создаем новый документ
    (
      input_document
    )
    values
    (
      empty_clob()
    )
    returning input_document_id into lDocID;
    select                              --Получаем LOB нового документа
      input_document
    into pLob
    from
      doc_Input_Document
    where
      input_document_id = lDocID
    ;
                                        --Открываем LOB для записи
    dbms_lob.open( pLob, dbms_lob.lob_readwrite);
    return lDocID;
  end NewDocument;



  procedure WriteLines( pLineLob in out nocopy CLOB
                      , pSrcLob in out nocopy CLOB
                      , pCopyAmount in integer
                      , pLineOffset in out integer
                      )
  is
  --Построчно сохраняет данные в теблице doc_Input_Document
  --
  --Параметры:
  --pLineLob                  - LOB текущей строки
  --pSrcLob                   - LOB с данными для записи
  --pCopyAmount               - длина копируемых данных
  --pLineOffset               - смещение для записи в конец текущей строки

    vSrcOffset integer := 1;            --Смещение для считывания данных
    vAmount integer;                    --Объем копируемых данных
    endlOffset integer;                 --Смещение символа конца строки
                                        --ID документа для вызова функции
                                        --создания документа
    lDocID doc_Input_Document.input_document_id%type;

  begin
    while vSrcOffset <= pCopyAmount loop
                                        --Определяем смещение конца строки
      endlOffset := dbms_lob.instr( pSrcLob, chr(10), vSrcOffset);
      if endlOffset > 0 then            --Определяем объем копируемых данных
        vAmount := endlOffset - vSrcOffset + 1;
      else
        vAmount := pCopyAmount - vSrcOffset + 1;
      end if;
      if pLineLob is null then          --Создаем новый документ для строки
        lDocID := NewDocument( pLineLob);
        pLineOffset := 1;
      end if;
      dbms_lob.copy(                    --Копируем данные
        pLineLob
        , pSrcLob
        , vAmount
        , pLineOffset
        , vSrcOffset
      );
      if endlOffset > 0 then
        dbms_lob.close( pLineLob);      --Закрывает LOB, если скопирована строка
        pLineLob := null;
      else
                                        --Корректируем смещения в LOB
        pLineOffset := pLineOffset + vAmount;
      end if;
      vSrcOffset := vSrcOffset + vAmount;
    end loop;
  end WriteLines;



  procedure CloseLOB is
  --Выполняет закрытие использовавшихся LOB
  begin
    if dataLob is not null then
      if dbms_lob.IsTemporary( dataLob) != 0 then
        dbms_lob.FreeTemporary( dataLob);
      else
        dbms_lob.close( dataLob);
      end if;
      dataLob := null;
    end if;
    if lineLob is not null then
      dbms_lob.close( lineLob);
      lineLob := null;
    end if;
  end CloseLOB;



--LoadTxt
begin
  begin
    if ByLine = 1 then
                                       -- Временный LOB для считывамия данных
      dbms_lob.CreateTemporary( dataLob, true);
    else
      fullDocID := NewDocument( dataLob);
    end if;
    LoadClobFromFile(                  -- Считываем данные из файла
      dataLob
      , FromPath
      , useCache => useCache
    );
                                        --Открываем LOB для записи
    dbms_lob.open( dataLob, dbms_lob.lob_readwrite);
    readCount := dbms_lob.getLength( dataLob);
    logger.Debug('readcount=' || to_char( readcount) );
                                       -- Сохраняем данные построчно
    if ByLine = 1 then
      WriteLines( lineLob, dataLob, readCount, lineOffset);
    end if;
    CloseLOB;
                                       -- Удаляем строку с пустым LOB
    if fullDocID is not null and readCount = 0 then
      delete from
        doc_Input_Document
      where
        input_document_id = fullDocID
      ;
    end if;
  exception when others then           -- Закрываем LOB в случае ошибки
    CloseLOB;
    raise;
  end;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка чтения файла в doc_input_document'
        || chr(10) || ', FileHandler('
        || ' fromPath="' || fromPath || '"'
        || ' byLine="' || to_char( byLine ) || '"'
        || ').'
      )
    , true
  );
end LoadTxt;

/* group: Выгрузка данных */

/* proc: AppendUnloadData
  Добавляет данные для выгрузки ( с буферизацией).

  Параметры:
  str                         - добавляемые данные

  Замечания:
  - добавление пустой строки вызывает запись содержимого буфера и закрытие
    CLOB;
  - после завершения добавления данных нужно вызвать процедуру без параметов,
    чтобы вызвать сброс буфера и закрытие CLOB;
  - вызывает процедуру <pkg_FileOrigin.AppendUnloadData>
*/
procedure AppendUnloadData(
  str varchar2 := null
)
is
begin
  pkg_FileOrigin.AppendUnloadData( str => str );
end AppendUnloadData;

/* proc: DeleteUnloadData
  Очищает всё содержимое таблицы doc_output_document.

  - вызывает процедуру <pkg_FileOrigin.DeleteUnloadData>
*/
procedure DeleteUnloadData
is
begin
   pkg_FileOrigin.DeleteUnloadData;
end DeleteUnloadData;

/* proc: UnloadTxt
  Выгружает текстовый файл из таблицы doc_output_document.

  Параметры:
  toPath                      - путь для выгружаемого файла
  writeMode                   - режим записи в существующий файл ( Mode_Rewrite
                                переписывать, Mode_Append дописывать), по
                                умолчанию Mode_Write ( не перезаписывать)
  charEncoding                - кодировка для выгрузки файла ( по-умолчанию используется
                                кодировка базы)
  isGzipped                   - флаг сжатия с помощью GZIP
  waitForRequest              - флаг "ожидать ли обработки запроса" ( по-умолчанию
                                ожидать )

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <UnloadTxtJava>);
*/
procedure UnloadTxt(
  toPath varchar2
  , writeMode integer := Mode_Write
  , charEncoding varchar2 := null
  , isGzipped integer := null
  , waitForRequest integer := null
)
is
                                       -- Id созданного запроса
                                       -- FileHandler
  requestId integer;
                                       -- Коллекция данных для выгрузки
  colText pkg_FileHandlerBase.tabClob := pkg_FileHandlerBase.tabClob();
                                       -- Длина clob
  lobLength integer;
begin
                                       -- Сбрасываем кэш в LOB ( если есть)
  AppendUnloadData( null);
                                       -- Копируем clob'ы в clob'ы массива
  for recDocument in
    (
    select
      output_document as output_document
    from
      (
      select
        output_document
      from
        doc_output_document
      order by
        output_document_id
      )
   )
  loop
    colText.extend;
    dbms_lob.createtemporary( colText( colText.last ), true );
    dbms_lob.open( colText( colText.last ), dbms_lob.lob_readwrite );
    lobLength := dbms_lob.getlength( recDocument.output_document );
    if lobLength > 0 then 
      dbms_lob.copy(
        colText( colText.last )
        , recDocument.output_document
        , lobLength
      );
    end if;  
    dbms_lob.close( colText( colText.last ));
  end loop;
                                       -- Создаём запрос
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => pkg_FileHandlerBase.UnloadText_OperationCode
      , fileFullPath => toPath
      , writeMode => writeMode
      , charEncoding => charEncoding
      , isGzipped => isGzipped
      , colText => colText
    );
  if coalesce( waitForRequest, 1 ) = 1  then
                                       -- Ждём выполнения запроса
    pkg_FileHandlerRequest.WaitForRequest(
      requestId => requestId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка выгрузки файла, FileHandler('
        || ' toPath="' || toPath || '"'
        || ' writeMode="' || to_char( writeMode ) || '"'
        || ').'
      )
    , true
  );
end UnloadTxt;

/* group: Выполнение команд */

/* func: ExecCommand
  Выполняет команду ОС на сервере.

  Параметры:
  command                     - командная строка для выполнения
  output                      - вывод команды ( stdout, возврат)
  error                       - ошибки ( stderr, возврат)

  Возврат:
  - код завершения команды.

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <ExecCommandJava>);
*/
function ExecCommand(
  command in varchar2
  , output in out nocopy clob
  , error in out nocopy clob
)
return integer
is
                                       -- Код завершения команды
  commandResult integer;
                                       -- Id созданного запроса
                                       -- FileHandler
  requestId integer;
begin
                                       -- Создаём запрос
  requestId :=
    pkg_FileHandlerRequest.CreateRequest(
      operationCode => pkg_FileHandlerBase.Command_OperationCode
      , commandText => command
    );
                                       -- Ждём выполнения запроса
  pkg_FileHandlerRequest.WaitForRequest(
    requestId => requestId
    , output => output
    , error => error
    , commandResult => commandResult
  );
  return commandResult;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка выполнения команды, FileHandler('
        || ' command="' || command || '"'
        || ').'
      )
    , true
  );
end ExecCommand;
/* func: ExecCommand( CMD, ERR)
  Выполняет команду ОС на сервере.

  Параметры:
  command                     - командная строка для выполнения
  error                       - ошибки ( stderr, возврат)

  Возврат:
  - код завершения команды.

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <ExecCommandJava>);
*/
function ExecCommand(
  command in varchar2
  , error in out nocopy clob
)
return integer
is

  output CLOB;

begin
  return ( ExecCommand( command, output, error));
end ExecCommand;
/* proc: ExecCommand( CMD, OUT)
  Выполняет команду ОС на сервере.

  Параметры:
  command                     - командная строка для выполнения
  output                      - вывод команды ( stdout, возврат)

  Замечания:
  - в случае, если код завершения команды ненулевой, выбрасывается исключение
    ( номер pkg_Error.InvalidExitValue);
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <ExecCommandJava>);
*/
procedure ExecCommand(
  command in varchar2
  , output in out nocopy clob
)
is

  exitCode number;
  error CLOB;

begin
  dbms_lob.createTemporary( error, true, dbms_lob.call);
  exitCode := ExecCommand( command, output, error);
  if nvl( exitCode, -1) != 0 then
    raise_application_error(
      pkg_Error.InvalidExitValue
      , substr(
        'Выполнение команды завершилось с ошибкой (код ' || exitCode || ').'
        || chr(10) || chr(10)
        || dbms_lob.substr( error, 4000)
        , 1, 4000)
    );
  end if;
end ExecCommand;
/* proc: ExecCommand( CMD)
  Выполняет команду ОС на сервере.

  Параметры:
  command                     - командная строка для выполнения

  Замечания:
  - в случае, если код завершения команды ненулевой, выбрасывается исключение
    ( номер pkg_Error.InvalidExitValue);
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <ExecCommandJava>);
*/
procedure ExecCommand(
  command in varchar2
)
is
  output CLOB;

begin
  ExecCommand( command, output);
  if output is not null then
    logger.Debug(
      'output="' || to_char( substr( output, 1, 30000 ) ) || '"'
    );
  end if;
end ExecCommand;

end pkg_FileHandler;
/