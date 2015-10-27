create or replace package body pkg_FileOrigin is
/* package body: pkg_FileOrigin::body */



/* group: Константы */

/* iconst: File_Path_Separator
  Символ-разделитель для файлового пути ОС.
*/
File_Path_Separator constant varchar2(1) := '\';

/* iconst: UnloadDataBuf_Size
  Размер буфера для выгружаемых данных.
*/
UnloadDataBuf_Size constant integer := 32767;

/* iconst: UnloadDataLob_MaxLength
  Максимальный объем выгружаемых данных, записываемый в один CLOB.
*/
UnloadDataLob_MaxLength constant integer := 1000000000;



/* group: Режимы записи файла в Java-реализации */

/* iconst: WriteModeCode_New
  Режим записи файла "Новый".
*/
WriteModeCode_New constant varchar2(10) := 'NEW';

/* iconst: WriteModeCode_Rewrite
  Режим записи файла "Перезапись".
*/
WriteModeCode_Rewrite constant varchar2(10) := 'REWRITE';

/* iconst: WriteModeCode_Append
  Режим записи файла "Добавление".
*/
WriteModeCode_Append constant varchar2(10) := 'APPEND';



/* group: Переменные */

/* ivar: UnloadDataLob
  CLOB для выгружаемых данных.
*/
UnloadDataLob clob := null;

/* ivar: UnloadDataBuf
  Буфер для выгружаемых данных.
*/
UnloadDataBuf varchar2(32767) := null;

/* ivar: UnloadWriteSize
  Число символов, записываемых в CLOB за один раз.
*/
UnloadWriteSize integer := null;

/* ivar: UnloadDataLobLength
  Число символов, записанных в CLOB.
*/
UnloadDataLobLength integer;

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName => Module_Name
  , objectName => 'pkg_FileOrigin'
);



/* group: Функции */



/* group: Файловые операции */

/* func: getFilePath
  Возвращает путь к файлу, сформированный из двух переданных частей.

  Параметры:
  parent                      - начальная часть пути
  child                       - конечная часть пути
*/
function getFilePath(
  parent in varchar2
  , child in varchar2
)
return varchar2
is

  pathSeparator varchar2(1);  --Символ-разделитель файлового пути
  path varchar2(2048);        --Сформированный путь

begin
  path := parent || child;    --Формируем путь для определения разделителя
  pathSeparator :=            --Определяем символ-разделитель в пути
    case
      when instr( path, '/') > 0 then '/'
      when instr( path, '\') > 0 then '\'
      else File_Path_Separator
    end;
                              --Формируем путь с разделителем
  path := parent || pathSeparator || child;
  return ( path);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при формировании пути к файлу ('
      || ' parent="' || parent || '"'
      || ', child="' || child || '"'
      || ').'
    , true
  );
end getFilePath;

/* ifunc: dirJava
  Сохраняет список элементов каталога во временной таблице tmp_file_name.
  Представляет собой обертку для соответствующей Java-функции.

  Параметры:
  fromPath                    - путь к каталогу
  entryType                   - тип возвращаемых элементов каталога ( 1 файлы,
                                2 каталоги)
  fileMask                    - маска для файлов. Использование аналогично
                                использованию в sql-операторе like escape '\'
  maxCount                    - максимальное количество файлов в списке

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение
    каталога, а также всех его элементов, на уровне Java
*/
function dirJava(
  fromPath varchar2
  , entryType number
  , fileMask varchar2
  , maxCount number
)
return number
is
language java name
  'pkg_File.dir(
     java.lang.String
     , java.math.BigDecimal
     , java.lang.String
     , java.math.BigDecimal
   ) return java.math.BigDecimal';

/* proc: fileList
  Получает список файлов каталога и помещает его в временную таблицу
  tmp_file_name.

  Параметры:
  fromPath                    - путь к каталогу
  fileMask                    - маска для файлов. Использование аналогично
                                использованию в sql-операторе like escape '\'
  maxCount                    - максимальное количество файлов в списке

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <dirJava>);
*/
procedure fileList(
  fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
)
is
                                        --Число найденных элементов
  nFound integer;

--fileList
begin
                                        --Очищаем таблицу с результатами
  delete from tmp_file_name;
  nFound := dirJava(
    FromPath
    , 1
    , fileMask
    , maxCount
  );
  logger.Trace('nFound=' || to_char( nFound));
end fileList;

/* func: fileList( EXCEPTION)
  Получает список файлов каталога по маске и помещает его в временную таблицу
  tmp_file_name.

  Параметры:
  fromPath                    - путь к каталогу
  riseException               - флаг генерации исключения при ошибке
                                ( 0 игнорировать ошибки, 1 выбрасывать
                                исключение, по умолчанию 1)
  fileMask                    - маска для файлов. Использование аналогично
                                использованию в sql-операторе like escape '\'
  maxCount                    - максимальное количество файлов в списке

  Возвращаемое значение:
  1     - при успешном выполнении
  0     - при ошибке ( если не установлен riseException)

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <dirJava>);
*/
function fileList(
  fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
  , riseException integer := 1
)
return integer
is

                                        --Результат выполнения
  isOk integer := 1;

--fileList
begin
  begin
    fileList( FromPath, fileMask, maxCount );
  exception when others then            --Выбрасываем исключение либо
                                        --устанавливаем ошибочный результат
    if RiseException = 1 then
      raise;
    else
      isOk := 0;
    end if;
  end;
  return ( isOk);                       --Возвращаем результат выполнения
end fileList;

/* func: subdirList
  Получает список подкаталогов каталога и сохраняет его в временную таблицу
  tmp_file_name.

  Параметры:
  fromPath                    - путь к каталогу

  Возврат:
  - число подкаталогов;

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <dirJava>);
*/
function subdirList(
  fromPath varchar2
)
return integer
is

                                        --Число найденных элементов
  nFound integer;

--subdirList
begin
                                        --Очищаем таблицу с результатами
  delete from tmp_file_name;
  nFound := dirJava( FromPath, 2, null, null);
  return ( nFound);
end subdirList;

/* ifunc: checkExistsJava
  Проверяет существование файла или каталога

  Параметры:
  fromPath                    - путь к файлу или каталогу

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение
    каталога, а также всех его элементов, на уровне Java
*/
function checkExistsJava(
  fromPath varchar2
)
return number
is
language java name
  'pkg_File.exists(
     java.lang.String
   ) return java.math.BigDecimal';

/* func: checkExists
  Проверяет существование файла или каталога

  Параметры:
  fromPath                    - путь к файлу или каталогу

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <checkExistsJava>);
*/
function checkExists(
  fromPath varchar2
)
return boolean
is
                                       -- Результат вызова
  nExists integer;
begin
  nExists := checkExistsJava( fromPath => fromPath);
  return
    case when
      nExists = 1
    then
      true
    else
      false
    end;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при проверке существования файла ('
        || ' fromPath="' || fromPath || '"'
        || ').'
      )
    , true
  );
end checkExists;

/* iproc: fileCopyJava
  Копирует файл.
  Представляет собой оберку для соответствующей Java-функции.

  Параметры:
  fromPath                    - полное имя файла-источник (каталог + имя)
  toPath                      - путь к назначению (полное имя файла или только
                                каталог), если указан только каталог, тогда имя
                                нового файла будет совпадать с именем исходного
                                файла
  overwrite                   - флаг перезаписи существующего файла
  tempFileDir                 - каталог для временных файлов

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение/запись
    соответствующих файлов ( или любых элементов соответствующих каталогов),
    на уровне Java;
*/
procedure fileCopyJava(
  fromPath varchar2
  , toPath varchar2
  , overwrite number
  , tempFileDir varchar2
)
is
language java name 'pkg_File.fileCopy(java.lang.String,java.lang.String,java.math.BigDecimal,java.lang.String)';

/* proc: fileCopy
  Копирует файл.

  Параметры:
  fromPath                    - полное имя файла-источник (каталог + имя)
  toPath                      - путь к назначению (полное имя файла или только
                                каталог), если указан только каталог, тогда имя
                                нового файла будет совпадать с именем исходного
                                файла
  overwrite                   - флаг перезаписи существующего файла
                                ( 1 перезаписывать, 0 не перезаписывать и
                                  выбрасывать ошибку ( по умолчанию))
*/
procedure fileCopy(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
)
is
begin
  begin
    fileCopyJava(
      fromPath
      , toPath
      , case when overwrite = 1 then 1 else 0 end
      , Temporary_File_Dir
    );
  exception when others then
    if sqlcode = pkg_Error.UncaughtJavaException and
        sqlerrm like '%java.lang.IllegalArgumentException: Destination file'
          || '%already exist'
        then
      raise_application_error(
        pkg_Error.FileAlreadyExists
        , 'Файл уже существует.'
        , true
      );
    else
      raise;
    end if;
  end;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при копировании файла ('
      || ' fromPath="' || fromPath || '"'
      || ', toPath="' || toPath || '"'
      || ', overwrite=' || overwrite
      || ').'
    , true
  );
end fileCopy;

/* func: fileCopy( EXCEPTION)
  Копирует файл.

  Параметры:
  fromPath                    - полное имя файла-источник (каталог + имя)
  toPath                      - путь к назначению (полное имя файла или только
                                каталог), если указан только каталог, тогда имя
                                нового файла будет совпадать с именем исходного
                                файла
  overwrite                   - флаг перезаписи существующего файла
                                ( 1 перезаписывать, 0 не перезаписывать и
                                  выбрасывать ошибку ( по умолчанию))
  riseException               - флаг генерации исключения при ошибке
                                ( 0 игнорировать ошибки, 1 выбрасывать
                                исключение ( по умолчанию))

  Возвращаемое значение:
  1     - при успешном выполнении
  0     - при ошибке ( если не установлен riseException)
*/
function fileCopy(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
  , riseException integer := null
)
return integer
is

  -- Результат выполнения
  isOk integer := 1;

begin
  begin
    fileCopy( fromPath, toPath, overwrite);
  exception when others then
    if riseException = 0 then
      isOk := 0;
    else
      raise;
    end if;
  end;
  return isOk;
end fileCopy;

/* iproc: fileMoveJava
  Копирует файл.
  Представляет собой оберку для соответствующей Java-функции.

  Параметры:
  fromPath                    - полное имя файла-источник (каталог + имя)
  toPath                      - путь к назначению (полное имя файла или только
                                каталог), если указан только каталог, тогда имя
                                нового файла будет совпадать с именем исходного
                                файла
  overwrite                   - флаг перезаписи существующего файла
  tempFileDir                 - каталог для временных файлов

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение/запись
    соответствующих файлов ( или любых элементов соответствующих каталогов),
    на уровне Java;
*/
procedure fileMoveJava(
  fromPath varchar2
  , toPath varchar2
  , overwrite number
  , tempFileDir varchar2
)
is
language java name 'pkg_File.fileMove(java.lang.String,java.lang.String,java.math.BigDecimal,java.lang.String)';

/* proc: fileMove
  Копирует файл.

  Параметры:
  fromPath                    - полное имя файла-источник (каталог + имя)
  toPath                      - путь к назначению (полное имя файла или только
                                каталог), если указан только каталог, тогда имя
                                нового файла будет совпадать с именем исходного
                                файла
  overwrite                   - флаг перезаписи существующего файла
                                ( 1 перезаписывать, 0 не перезаписывать и
                                  выбрасывать ошибку ( по умолчанию))
*/
procedure fileMove(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
)
is
begin
  begin
    fileMoveJava(
      fromPath
      , toPath
      , case when overwrite = 1 then 1 else 0 end
      , Temporary_File_Dir
    );
  exception when others then
    if sqlcode = pkg_Error.UncaughtJavaException and
        sqlerrm like '%java.lang.IllegalArgumentException: Destination file'
          || '%already exist'
        then
      raise_application_error(
        pkg_Error.FileAlreadyExists
        , 'Файл уже существует.'
        , true
      );
    else
      raise;
    end if;
  end;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при копировании файла ('
      || ' fromPath="' || fromPath || '"'
      || ', toPath="' || toPath || '"'
      || ', overwrite=' || overwrite
      || ').'
    , true
  );
end fileMove;

/* func: fileMove( EXCEPTION)
  Копирует файл.

  Параметры:
  fromPath                    - полное имя файла-источник (каталог + имя)
  toPath                      - путь к назначению (полное имя файла или только
                                каталог), если указан только каталог, тогда имя
                                нового файла будет совпадать с именем исходного
                                файла
  overwrite                   - флаг перезаписи существующего файла
                                ( 1 перезаписывать, 0 не перезаписывать и
                                  выбрасывать ошибку ( по умолчанию))
  riseException               - флаг генерации исключения при ошибке
                                ( 0 игнорировать ошибки, 1 выбрасывать
                                исключение ( по умолчанию))

  Возвращаемое значение:
  1     - при успешном выполнении
  0     - при ошибке ( если не установлен riseException)
*/
function fileMove(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
  , riseException integer := null
)
return integer
is

  -- Результат выполнения
  isOk integer := 1;

begin
  begin
    fileMove( fromPath, toPath, overwrite);
  exception when others then
    if riseException = 0 then
      isOk := 0;
    else
      raise;
    end if;
  end;
  return isOk;
end fileMove;

/* iproc: fileDeleteJava
  Удаляет файл или пустой каталог.
  Представляет собой оберку для соответствующей Java-функции.

  Параметры:
  fromPath                    - удаляемый файл

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение и
    удаление элементов соответствующего каталога ( или конкретно указанного
    файла) на уровне Java;
*/
procedure fileDeleteJava(
  fromPath varchar2
)
is language java name 'pkg_File.fileDelete(java.lang.String)';

/* proc: fileDelete
  Удаляет файл или пустой каталог.

  Параметры:
  fromPath                    - удаляемый файл

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <fileDeleteJava>);
*/
procedure fileDelete(
  fromPath varchar2
)
is
begin
  fileDeleteJava( fromPath);
exception when others then              --Транслируем ошбку в PL/SQL ошибку
  if SQLCODE = pkg_Error.UncaughtJavaException and
      SQLERRM like '%java.io.FileNotFoundException:%'
    then
    raise_application_error(
      pkg_Error.FileNotFound
      , 'Файл не найден.'
      , true
    );
  else
    raise;
  end if;
end fileDelete;

/* func: fileDelete( EXCEPTION)
  Удаляет файл или пустой каталог.

  Параметры:
  fromPath                    - удаляемый файл
  riseException               - флаг генерации исключения при ошибке
                                ( 0 игнорировать ошибки, 1 выбрасывать
                                исключение, по умолчанию 1)

  Возвращаемое значение:
  1     - при успешном выполнении
  0     - при ошибке ( если не установлен riseException)

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <fileDeleteJava>);
*/
function fileDelete(
  fromPath varchar2
  , riseException integer := 1
)
return integer
is

                                        --Результат выполнения
  isOk integer := 1;

begin
  begin
    fileDelete( FromPath);
  exception when others then            --Выбрасываем исключение либо
                                        --устанавливаем ошибочный результат
    if RiseException = 1 then
      raise;
    else
      isOk := 0;
    end if;
  end;
  return ( isOk);                       --Возвращаем результат выполнения
end fileDelete;

/* iproc: makeDirectoryJava
  Создаёт директорию.
  Представляет собой оберку для соответствующей Java-функции.

  Параметры:
  dirPath                     - путь к директории
  raiseExceptionFlag          - флаг генерации исключения в случае
                                существования директории или отсутствия
                                родительских директорий
*/
procedure makeDirectoryJava(
  dirPath varchar2
  , raiseExceptionFlag number
)
is language java name
  'pkg_File.makeDirectory(
    java.lang.String
    , java.math.BigDecimal
  )';

/* proc: makeDirectory
  Создание директории.

  Параметры:
  dirPath                     - путь к директории
  raiseExceptionFlag          - флаг генерации исключения в случае
                                существования директории или отсутствия
                                родительских директорий ( по-умолчанию, false,
                                то есть создаются все промежуточные директории,
                                если это возможно, и при существовании ошибка
                                не возникает)
*/
procedure makeDirectory(
  dirPath varchar2
  , raiseExceptionFlag boolean := null
)
is
-- makeDirectory
begin
  makeDirectoryJava(
    dirPath => dirPath
    , raiseExceptionFlag =>
        case when
          raiseExceptionFlag
        then
          1
        else
          0
        end
  );
  logger.trace( 'makeDirectory: "' || dirPath || '"');
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка создания директории ('
        || 'dirPath="' || dirPath || '"'
        || ', raiseExceptionFlag=' ||
          case when
            raiseExceptionFlag
          then
            'true'
          else
            'false'
          end
        || ')'
      )
    , true
  );
end makeDirectory;



/* group: Загрузка данных */

/* iproc: loadBlobFromFileJava
  Загружает файл в BLOB.
  Представляет собой оберку для соответствующей Java-функции.

  Параметры:
  dstLob                      - LOB для загрузки данных ( возврат)
  fromPath                    - путь к файлу

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение
    файла на уровне Java;
*/
procedure loadBlobFromFileJava(
  dstLob in out nocopy blob
  , fromPath varchar2
)
is
language java name 'pkg_File.loadBlobFromFile(oracle.sql.BLOB[],java.lang.String)';

/* iproc: loadClobFromFileJava
  Загружает файл в CLOB.
  Представляет собой оберку для соответствующей Java-функции.

  Параметры:
  dstLob                      - LOB для загрузки данных ( возврат)
  fromPath                    - путь к файлу
  charEncoding                - кодировка для выгрузки файла ( по-умолчанию
                                используется кодировка базы)

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение
    файла на уровне Java;
*/
procedure loadClobFromFileJava(
  dstLob in out nocopy clob
  , fromPath varchar2
  , charEncoding varchar2
)
is
language java name '
  pkg_File.loadClobFromFile(
    oracle.sql.CLOB[]
    , java.lang.String
    , java.lang.String
  )';

/* proc: loadBlobFromFile
  Загружает файл в BLOB.

  Параметры:
  dstLob                      - LOB для загрузки данных ( возврат)
  fromPath                    - путь к файлу

  Замечание:
  - при передаче null в параметр dstLob, создаётся временный LOB;
  - для успешного выполнения у пользователя должны быть права доступа на
    уровне Java ( см. <loadBlobFromFileJava>);
*/
procedure loadBlobFromFile(
  dstLob in out nocopy blob
  , fromPath varchar2
)
is
begin
  if dstLob is null then
    dbms_lob.createtemporary( dstLob, true);
  end if;
  loadBlobFromFileJava(
    dstLob => dstLob
    , fromPath => fromPath
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при загрузке файла в BLOB ('
        || ' fromPath="' || fromPath || '"'
        || ').'
      )
    , true
  );
end loadBlobFromFile;

/* proc: loadClobFromFile
  Загружает файл в CLOB.

  Параметры:
  dstLob                      - LOB для загрузки данных ( возврат)
  fromPath                    - путь к файлу
  charEncoding                - кодировка для выгрузки файла ( по-умолчанию
                                используется кодировка базы)

  Замечание:
  - при передаче null в параметр dstLob, создаётся временный LOB;
  - для успешного выполнения у пользователя должны быть права доступа на
    уровне Java ( см. <loadClobFromFileJava>);
*/
procedure loadClobFromFile(
  dstLob in out nocopy clob
  , fromPath varchar2
  , charEncoding varchar2 := null
)
is
begin
  if dstLob is null then
    dbms_lob.createtemporary( dstLob, true);
  end if;
  loadClobFromFileJava(
    dstLob => dstLob
    , fromPath => fromPath
    , charEncoding => charEncoding
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при загрузке файла в CLOB ('
        || ' fromPath="' || fromPath || '"'
        || ', charEncoding="' || charEncoding || '"'
        || ').'
      )
    , true
  );
end loadClobFromFile;

/* proc: loadTxt
  Загружает текстовый файл в таблицу doc_input_document.

  Параметры:
  fromPath                    - путь к файлу
  byLine                      - флаг построчной загрузки файла ( для каждой
                                строки файла создается запись в таблице
                                doc_input_document)

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <loadClobFromFileJava>);
  - построчная загрузка обладает низкой производительностью;
*/
procedure loadTxt(
  fromPath varchar2
  , byLine integer
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



--loadTxt
begin
  begin
    if ByLine = 1 then
                                        --Временный LOB для считывамия данных
      dbms_lob.CreateTemporary( dataLob, true);
    else
      fullDocID := NewDocument( dataLob);
    end if;
    loadClobFromFileJava(             --Считываем данные из файла
      dataLob
      , FromPath
      , null
    );
    readCount := dbms_lob.getLength( dataLob);
                                      --Сохраняем данные построчно
    if ByLine = 1 then
      WriteLines( lineLob, dataLob, readCount, lineOffset);
    end if;
    CloseLOB;
                                        --Удаляем строку с пустым LOB
    if fullDocID is not null and readCount = 0 then
      delete from
        doc_Input_Document
      where
        input_document_id = fullDocID
      ;
    end if;
  exception when others then            --закрываем LOB в случае ошибки
    CloseLOB;
    raise;
  end;
end loadTxt;

/* func: loadTxt( EXCEPTION)
  Загружает текстовый файл в таблицу doc_input_document.

  Параметры:
  fromPath                    - путь к файлу
  byLine                      - флаг построчной загрузки файла
  riseException               - флаг генерации исключения при ошибке
                                ( 0 игнорировать ошибки, 1 выбрасывать
                                исключение, по умолчанию 1)

  Возвращаемое значение:
  1     - при успешном выполнении
  0     - при ошибке ( если не установлен riseException)

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <loadClobFromFileJava>);
  - построчная загрузка обладает низкой производительностью;
*/
function loadTxt(
  fromPath varchar2
  , byLine integer
  , riseException integer := 1
)
return integer
is

                                        --Результат выполнения
  isOk integer := 1;
begin
  begin
    loadTxt( FromPath, ByLine);
  exception when others then            --Выбрасываем исключение либо
                                        --устанавливаем ошибочный результат
    if RiseException = 1 then
      raise;
    else
      isOk := 0;
    end if;
  end;
  return ( isOk);                       --Возвращаем результат выполнения
end loadTxt;



/* group: Выгрузка данных */

/* ifunc: convertWriteMode
  Конвертация флага writeMode процедур модуля во внутренний код
  для передачи Java-реализации.

  Параметры:
  writeMode                   - режим записи в существующий файл ( <Mode_Rewrite>
                                переписывать, <Mode_Append> дописывать), по
                                умолчанию <Mode_Write> ( не перезаписывать)
*/
function convertWriteMode(
  writeMode number
)
return varchar2
is
-- convertWriteMode
begin
  return
    case when
      writeMode = Mode_Rewrite
    then
      WriteModeCode_Rewrite
    when
      writeMode = Mode_Append
    then
      WriteModeCode_Append
    else
      WriteModeCode_New
    end
  ;
end convertWriteMode;

/* iproc: unloadBlobToFileJava
  Выгружает двоичные данные в файл.

  Параметры:
  binaryData                  - данные для выгрузки
  toPath                      - путь для выгружаемого файла
  writeModeCode               - режим записи в существующий файл
  isGzipped                   - флаг сжатия с помощью GZIP

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение/запись
    файла ( или всех элементов каталога) на уровне Java;
*/
procedure unloadBlobToFileJava(
  binaryData in blob
  , toPath varchar2
  , writeModeCode varchar2
  , isGzipped number
)
is
language java name
  'pkg_File.unloadBlobToFile(
     oracle.sql.BLOB
     , java.lang.String
     , java.lang.String
     , java.math.BigDecimal
   )';

 /* proc: unloadBlobToFile
  Выгружает двоичные данные в файл.

  Параметры:
  binaryData                  - данные для выгрузки
  toPath                      - путь для выгружаемого файла
  writeMode                   - режим записи в существующий файл ( <Mode_Rewrite>
                                переписывать, <Mode_Append> дописывать), по
                                умолчанию <Mode_Write> ( не перезаписывать)
  isGzipped                   - флаг сжатия с помощью GZIP

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение/запись
    файла ( или всех элементов каталога) на уровне Java;
*/
procedure unloadBlobToFile(
  binaryData in blob
  , toPath varchar2
  , writeMode number := null
  , isGzipped number := null
)
is
begin
  unloadBlobToFileJava(
    binaryData => binaryData
    , toPath => toPath
    , writeModeCode => convertWriteMode( writeMode)
    , isGzipped => isGzipped
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка выгрузки двоичных данных в файл ('
        || ' toPath="' || toPath || '"'
        || ', writeMode=' || to_char( writeMode)
        || ', isGzipped=' || to_char( isGzipped)
        || ').'
      )
    , true
  );
end unloadBlobToFile;

/* iproc: unloadClobToFileJava
  Выгружает текстовые данные в файл.

  Параметры:
  fileText                    - данные для выгрузки
  toPath                      - путь для выгружаемого файла
  writeModeCod                - режим записи в существующий файл
  charEncoding                - кодировка для выгрузки файла
                                ( по-умолчанию используется кодировка базы)
  isGzipped                   - флаг сжатия с помощью GZIP

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение/запись
    файла ( или всех элементов каталога) на уровне Java;
*/
procedure unloadClobToFileJava(
  fileText in clob
  , toPath varchar2
  , writeModeCode varchar2
  , charEncoding varchar2
  , isGzipped number
)
is
language java name
  'pkg_File.unloadClobToFile(
     oracle.sql.CLOB
     , java.lang.String
     , java.lang.String
     , java.lang.String
     , java.math.BigDecimal
   )';

/* proc: unloadClobToFile
  Выгружает текстовые данные в файл.

  Параметры:
  fileText                    - данные для выгрузки
  toPath                      - путь для выгружаемого файла
  writeMode                   - режим записи в существующий файл ( <Mode_Rewrite>
                                переписывать, <Mode_Append> дописывать), по
                                умолчанию <Mode_Write> ( не перезаписывать)
  charEncoding                - кодировка для выгрузки файла
                                ( по-умолчанию используется кодировка базы)
  isGzipped                   - флаг сжатия с помощью GZIP

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение/запись
    файла ( или всех элементов каталога) на уровне Java;
*/
procedure unloadClobToFile(
  fileText in clob
  , toPath varchar2
  , writeMode number := null
  , charEncoding varchar2 := null
  , isGzipped number := null
)
is
begin
  unloadClobToFileJava(
    fileText => fileText
    , toPath => toPath
    , writeModeCode => convertWriteMode( writeMode)
    , charEncoding => charEncoding
    , isGzipped => isGzipped
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка выгрузки текстовых данных в файл ('
        || ' toPath="' || toPath || '"'
        || ', writeMode=' || to_char( writeMode)
        || ', charEncoding="' || charEncoding || '"'
        || ', isGzipped=' || to_char( isGzipped)
        || ').'
      )
    , true
  );
end unloadClobToFile;

/* proc: appendUnloadData
  Добавляет данные для выгрузки ( с буферизацией).

  Параметры:
  str                         - добавляемые данные

  Замечания:
  - добавление пустой строки вызывает запись содержимого буфера и закрытие
    CLOB;
  - после завершения добавления данных нужно вызвать процедуру без параметов,
    чтобы вызвать сброс буфера и закрытие CLOB;
*/
procedure appendUnloadData(
  str varchar2 := null
)
is

  len integer := nvl( length( str), 0);
  bufLen integer := nvl( length( unloadDataBuf), 0);
  addLen integer;



  procedure OpenLob is
  --Создает LOB для выгружаемых данных.

                                        --ID временного документа
    docID doc_output_document.output_document_id%type;

  --OpenLob
  begin
    insert into doc_output_document     --Создаем новый документ
    (
      output_document
    )
    values
    (
      empty_clob()
    )
    returning output_document_id into docID;
    select                              --Получаем LOB нового документа
      output_document
    into unloadDataLob
    from
      doc_output_document
    where
      output_document_id = docID
    ;
                                        --Открываем LOB для записи
    dbms_lob.open( unloadDataLob, dbms_lob.lob_readwrite);
                                        --Определяем оптимальный размер
                                        --для записи в LOB
    unloadWriteSize := UnloadDataBuf_Size
      - mod( UnloadDataBuf_Size, dbms_lob.getChunkSize( unloadDataLob));
    unloadDataLobLength := 0;
  end OpenLob;



  procedure CloseLob is
  --Закрывает LOB.
  begin
    dbms_lob.close( unloadDataLob);
    unloadDataLob := null;
    unloadDataLobLength := null;
  end CloseLob;



--appendUnloadData
begin
  if len > 0 or bufLen > 0 then
                                        --Закрываем LOB, если достигается
                                        --ограничение по максимальной длине
    if unloadDataLobLength > 0
        and unloadDataLobLength + coalesce( len, 0) + coalesce( bufLen, 0)
         > UnloadDataLob_MaxLength
        then
      CloseLob;
    end if;
                                        --Открываем LOB, если его еще нет
    if unloadDataLob is null then
      OpenLob;
    end if;
    if len > 0 and bufLen + len < unloadWriteSize then
                                        --Добавляем данные в буфер
      unloadDataBuf := unloadDataBuf || str;
    else
                                        --Добавляем в LOB содержимое буфера
      addLen := least( unloadWriteSize - bufLen, len);
      if addLen > 0 then
        unloadDataBuf := unloadDataBuf || substr( str, 1, addLen);
        bufLen := bufLen + addLen;
      end if;
      dbms_lob.writeAppend(
        unloadDataLob
        , bufLen
        , unloadDataBuf
      );
      unloadDataBuf := substr( str, 1 + addLen);
      unloadDataLobLength := unloadDataLobLength + bufLen;
    end if;
  end if;
                                        --Закрываем LOB если вызов с null
  if str is null and unloadDataLob is not null then
    CloseLob;
  end if;
end appendUnloadData;

/* proc: deleteUnloadData
  Очищает всё содержимое таблицы doc_output_document.
*/
procedure deleteUnloadData
is
begin
  UnloadDataLob := null;
  delete from doc_output_document;
end deleteUnloadData;

/* iproc: unloadTxtJava
  Выгружает текстовый файл из таблицы doc_output_document.
  Представляет собой оберку для соответствующей Java-функции.

  Параметры:
  toPath                      - путь для выгружаемого файла
  writeModeCode               - режим записи в существующий файл
  charEncoding                - кодировка для выгрузки файла ( по-умолчанию используется
                                кодировка базы)
  izGzipped                   - сжимать ли с помощью GZIP (1-да,0-нет)

  Замечание:
  - для успешного выполнения у пользователя должны быть права на чтение/запись
    файла ( или всех элементов каталога) на уровне Java;
*/
procedure unloadTxtJava(
  toPath varchar2
  , writeModeCode varchar2
  , charEncoding varchar2
  , isGzipped number
)
is
language java name
  'pkg_File.unloadTxt(
     java.lang.String
     , java.lang.String
     , java.lang.String
     , java.math.BigDecimal
   )';

/* proc: unloadTxt
  Выгружает текстовый файл из таблицы doc_output_document.

  Параметры:
  toPath                      - путь для выгружаемого файла
  writeMode                   - режим записи в существующий файл ( <Mode_Rewrite>
                                переписывать, <Mode_Append> дописывать), по
                                умолчанию <Mode_Write> ( не перезаписывать)
  charEncoding                - кодировка для выгрузки файла
                                ( по-умолчанию используется кодировка базы)
  isGzipped                   - флаг сжатия с помощью GZIP

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <unloadTxtJava>);
*/
procedure unloadTxt(
  toPath varchar2
  , writeMode integer := Mode_Write
  , charEncoding varchar2 := null
  , isGzipped integer := null
)
is

begin
                                        --Сбрасываем кэш в LOB ( если есть)
  appendUnloadData( null);
                                        --Выгружаем файл
  unloadTxtJava(
    ToPath
    , convertWriteMode( writeMode)
    , charEncoding
    , isGzipped
  );
end unloadTxt;



/* group: Выполнение команд */

/* ifunc: execCommandJava
  Выполняет команду ОС на сервере.
  Представляет собой оберку для соответствующей Java-функции.

  Параметры:
  command                     - командная строка для выполнения
  output                      - вывод команды ( stdout, возврат)
  error                       - ошибки ( stderr, возврат)

  Возврат:
  - код завершения команды.

  Замечание:
  - для успешного выполнения у пользователя должны быть права на выполнение
    указанной ( или любой) команды, а также права на запись и чтение
    дескрипторов файлов на уровне Java;
*/
function execCommandJava(
  command in varchar2
  , output in out nocopy clob
  , error in out nocopy clob
)
return number
is
language java name 'pkg_File.execCommand(java.lang.String,oracle.sql.CLOB[],oracle.sql.CLOB[]) return java.math.BigDecimal';

/* func: execCommand
  Выполняет команду ОС на сервере.

  Параметры:
  command                     - командная строка для выполнения
  output                      - вывод команды ( stdout, возврат)
  error                       - ошибки ( stderr, возврат)

  Возврат:
  - код завершения команды.

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <execCommandJava>);
*/
function execCommand(
  command in varchar2
  , output in out nocopy clob
  , error in out nocopy clob
)
return integer
is

begin
  return ( execCommandJava( command, output, error));
end execCommand;

/* func: execCommand( CMD, ERR)
  Выполняет команду ОС на сервере.

  Параметры:
  command                     - командная строка для выполнения
  error                       - ошибки ( stderr, возврат)

  Возврат:
  - код завершения команды.

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <execCommandJava>);
*/
function execCommand(
  command in varchar2
  , error in out nocopy clob
)
return integer
is

  output CLOB;

begin
  dbms_lob.createTemporary( output, true, dbms_lob.call);
  return ( execCommand( command, output, error));
end execCommand;

/* proc: execCommand( CMD, OUT)
  Выполняет команду ОС на сервере.

  Параметры:
  command                     - командная строка для выполнения
  output                      - вывод команды ( stdout, возврат)

  Замечания:
  - в случае, если код завершения команды ненулевой, выбрасывается исключение
    ( номер pkg_Error.InvalidExitValue);
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <execCommandJava>);
*/
procedure execCommand(
  command in varchar2
  , output in out nocopy clob
)
is

  exitCode number;
  error CLOB;

begin
  dbms_lob.createTemporary( error, true, dbms_lob.call);
  exitCode := execCommandJava( command, output, error);
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
end execCommand;

/* proc: execCommand( CMD)
  Выполняет команду ОС на сервере.

  Параметры:
  command                     - командная строка для выполнения

  Замечания:
  - в случае, если код завершения команды ненулевой, выбрасывается исключение
    ( номер pkg_Error.InvalidExitValue);
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <execCommandJava>);
*/
procedure execCommand(
  command in varchar2
)
is
  output CLOB;

begin
  dbms_lob.createTemporary( output, true, dbms_lob.call);
  execCommand( command, output);
end execCommand;

end pkg_FileOrigin;
/
