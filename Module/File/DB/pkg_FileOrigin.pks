create or replace package pkg_FileOrigin is
/* package: pkg_FileOrigin
  Интерфейсный пакет модуля File
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'File';

/* const: Temporary_File_Dir
  Каталог для временных файлов на сервере.
*/
Temporary_File_Dir constant varchar2(255) := 'C:\TEMP';



/* group: Режимы открытия файла */

/* const: Mode_Read
  Режим чтения.
*/
Mode_Read constant integer := 0;

/* const: Mode_Append
  Режим добавления.
*/
Mode_Append constant integer := 1;

/* const: Mode_Write
  Режим записи.
*/
Mode_Write constant integer := 2;

/* const: Mode_Rewrite
  Режим перезаписи.
*/
Mode_Rewrite constant integer := 3;

/* group: Кодировки */

/* const: Encoding_Utf8
  Кодировка "UTF8"
*/
Encoding_Utf8 constant varchar2( 10 ) := 'UTF-8';

/* const: Encoding_Utf8Bom
  Кодировка "UTF8" с маркером BOM.
*/
Encoding_Utf8Bom constant varchar2( 10 ) := 'UTF-8-BOM';

/* const: Encoding_Unicode
  Кодировка "Encoding_Unicode"
*/
Encoding_Unicode constant varchar2( 10 ) := 'Unicode';

/* const: Encoding_Cp866
  Кодировка "Encoding_Cp866"
*/
Encoding_Cp866 constant varchar2( 10 ) := 'Cp866';



/* group: Функции */



/* group: Файловые операции */

/* pfunc: getFilePath
  Возвращает путь к файлу, сформированный из двух переданных частей.

  Параметры:
  parent                      - начальная часть пути
  child                       - конечная часть пути

  ( <body::getFilePath>)
*/
function getFilePath(
  parent in varchar2
  , child in varchar2
)
return varchar2;

/* pproc: fileList
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

  ( <body::fileList>)
*/
procedure fileList(
  fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
);

/* pfunc: fileList( EXCEPTION)
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

  ( <body::fileList( EXCEPTION)>)
*/
function fileList(
  fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
  , riseException integer := 1
)
return integer;

/* pfunc: subdirList
  Получает список подкаталогов каталога и сохраняет его в временную таблицу
  tmp_file_name.

  Параметры:
  fromPath                    - путь к каталогу

  Возврат:
  - число подкаталогов;

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <dirJava>);

  ( <body::subdirList>)
*/
function subdirList(
  fromPath varchar2
)
return integer;

/* pfunc: checkExists
  Проверяет существование файла или каталога

  Параметры:
  fromPath                    - путь к файлу или каталогу

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <checkExistsJava>);

  ( <body::checkExists>)
*/
function checkExists(
  fromPath varchar2
)
return boolean;

/* pproc: fileCopy
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

  ( <body::fileCopy>)
*/
procedure fileCopy(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
);

/* pfunc: fileCopy( EXCEPTION)
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

  ( <body::fileCopy( EXCEPTION)>)
*/
function fileCopy(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
  , riseException integer := null
)
return integer;

/* pproc: fileMove
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

  ( <body::fileMove>)
*/
procedure fileMove(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
);

/* pfunc: fileMove( EXCEPTION)
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

  ( <body::fileMove( EXCEPTION)>)
*/
function fileMove(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := null
  , riseException integer := null
)
return integer;

/* pproc: fileDelete
  Удаляет файл или пустой каталог.

  Параметры:
  fromPath                    - удаляемый файл

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <fileDeleteJava>);

  ( <body::fileDelete>)
*/
procedure fileDelete(
  fromPath varchar2
);

/* pfunc: fileDelete( EXCEPTION)
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

  ( <body::fileDelete( EXCEPTION)>)
*/
function fileDelete(
  fromPath varchar2
  , riseException integer := 1
)
return integer;

/* pproc: makeDirectory
  Создание директории.

  Параметры:
  dirPath                     - путь к директории
  raiseExceptionFlag          - флаг генерации исключения в случае
                                существования директории или отсутствия
                                родительских директорий ( по-умолчанию, false,
                                то есть создаются все промежуточные директории,
                                если это возможно, и при существовании ошибка
                                не возникает)

  ( <body::makeDirectory>)
*/
procedure makeDirectory(
  dirPath varchar2
  , raiseExceptionFlag boolean := null
);



/* group: Загрузка данных */

/* pproc: loadBlobFromFile
  Загружает файл в BLOB.

  Параметры:
  dstLob                      - LOB для загрузки данных ( возврат)
  fromPath                    - путь к файлу

  Замечание:
  - при передаче null в параметр dstLob, создаётся временный LOB;
  - для успешного выполнения у пользователя должны быть права доступа на
    уровне Java ( см. <loadBlobFromFileJava>);

  ( <body::loadBlobFromFile>)
*/
procedure loadBlobFromFile(
  dstLob in out nocopy blob
  , fromPath varchar2
);

/* pproc: loadClobFromFile
  Загружает файл в CLOB.

  Параметры:
  dstLob                      - LOB для загрузки данных ( возврат)
  fromPath                    - путь к файлу
  charEncoding                - кодировка для выгрузки файла
                                ( по-умолчанию используется кодировка базы)

  Замечание:
  - при передаче null в параметр dstLob, создаётся временный LOB;
  - для успешного выполнения у пользователя должны быть права доступа на
    уровне Java ( см. <loadClobFromFileJava>);

  ( <body::loadClobFromFile>)
*/
procedure loadClobFromFile(
  dstLob          in out nocopy clob
, fromPath        varchar2
, charEncoding    varchar2
);

/* pproc: loadTxt
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

  ( <body::loadTxt>)
*/
procedure loadTxt(
  fromPath varchar2
  , byLine integer
);

/* pfunc: loadTxt( EXCEPTION)
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

  ( <body::loadTxt( EXCEPTION)>)
*/
function loadTxt(
  fromPath varchar2
  , byLine integer
  , riseException integer := 1
)
return integer;



/* group: Выгрузка данных */

 /* pproc: unloadBlobToFile
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

  ( <body::unloadBlobToFile>)
*/
procedure unloadBlobToFile(
  binaryData in blob
  , toPath varchar2
  , writeMode number := null
  , isGzipped number := null
);

/* pproc: unloadClobToFile
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

  ( <body::unloadClobToFile>)
*/
procedure unloadClobToFile(
  fileText      in clob
, toPath        varchar2
, writeMode     number := null
, charEncoding  varchar2 := null
, isGzipped     number := null
);

/* pproc: appendUnloadData
  Добавляет данные для выгрузки ( с буферизацией).

  Параметры:
  str                         - добавляемые данные

  Замечания:
  - добавление пустой строки вызывает запись содержимого буфера и закрытие
    CLOB;
  - после завершения добавления данных нужно вызвать процедуру без параметов,
    чтобы вызвать сброс буфера и закрытие CLOB;

  ( <body::appendUnloadData>)
*/
procedure appendUnloadData(
  str varchar2 := null
);

/* pproc: deleteUnloadData
  Очищает всё содержимое таблицы doc_output_document.

  ( <body::deleteUnloadData>)
*/
procedure deleteUnloadData;

/* pproc: unloadTxt
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

  ( <body::unloadTxt>)
*/
procedure unloadTxt(
  toPath        varchar2
, writeMode     integer := Mode_Write
, charEncoding  varchar2 := null
, isGzipped     integer := null
);



/* group: Выполнение команд */

/* pfunc: execCommand
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

  ( <body::execCommand>)
*/
function execCommand(
  command in varchar2
  , output in out nocopy clob
  , error in out nocopy clob
)
return integer;

/* pfunc: execCommand( CMD, ERR)
  Выполняет команду ОС на сервере.

  Параметры:
  command                     - командная строка для выполнения
  error                       - ошибки ( stderr, возврат)

  Возврат:
  - код завершения команды.

  Замечание:
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <execCommandJava>);

  ( <body::execCommand( CMD, ERR)>)
*/
function execCommand(
  command in varchar2
  , error in out nocopy clob
)
return integer;

/* pproc: execCommand( CMD, OUT)
  Выполняет команду ОС на сервере.

  Параметры:
  command                     - командная строка для выполнения
  output                      - вывод команды ( stdout, возврат)

  Замечания:
  - в случае, если код завершения команды ненулевой, выбрасывается исключение
    ( номер pkg_Error.InvalidExitValue);
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <execCommandJava>);

  ( <body::execCommand( CMD, OUT)>)
*/
procedure execCommand(
  command in varchar2
  , output in out nocopy clob
);

/* pproc: execCommand( CMD)
  Выполняет команду ОС на сервере.

  Параметры:
  command                     - командная строка для выполнения

  Замечания:
  - в случае, если код завершения команды ненулевой, выбрасывается исключение
    ( номер pkg_Error.InvalidExitValue);
  - для успешного выполнения у пользователя должны быть права доступа на уровне
    Java ( см. <execCommandJava>);

  ( <body::execCommand( CMD)>)
*/
procedure execCommand(
  command in varchar2
);

end pkg_FileOrigin;
/
