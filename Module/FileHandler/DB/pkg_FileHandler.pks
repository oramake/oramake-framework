create or replace package pkg_FileHandler is
/* package: pkg_FileHandler
  Интерфейсный пакет модуля FileHandler.

  SVN root: Oracle/Module/FileHandler
*/

/* const: Module_Name
  Название модуля File для обратной совместимости с пакетом
  pkg_FileUtility
*/
Module_Name constant varchar2(30) := 'File';

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

/* pfunc: GetFilePath
  Возвращает путь к файлу, сформированный из двух переданных частей
  ( <body::GetFilePath>).
*/
function GetFilePath(
  parent in varchar2
  , child in varchar2
)
return varchar2;
/* pproc: FileList
  Сохраняет список файлов каталога во временной таблице tmp_file_name
  ( <body::FileList>).
*/
procedure FileList(
  fromPath varchar2
  , fileMask varchar2 := null
  , maxCount integer := null
  , useCache boolean := null
);

/* pfunc: SubdirList
  Получает список подкаталогов каталога
  ( <body::SubdirList>).
*/
function SubdirList(
  fromPath varchar2
)
return integer;

/* pproc: FileCopy
  Копирует файл
  ( <body::FileCopy>).
*/
procedure FileCopy(
  fromPath varchar2
  , toPath varchar2
  , overwrite integer := 0
  , waitForRequest integer := null
);
/* pproc: FileDelete
  Удаляет файл или пустой каталог
  ( <body::FileDelete>).
*/
procedure FileDelete(
  fromPath varchar2
  , waitForRequest integer := null
);
/* group: Загрузка данных */

/* pproc: LoadBlobFromFile
  Загружает файл в BLOB
  ( <body::LoadBlobFromFile>).
*/
procedure LoadBlobFromFile(
  dstLob in out nocopy blob
  , fromPath varchar2
  , useCache boolean := null
);
/* pproc: LoadClobFromFile
  Загружает файл в CLOB
  ( <body::LoadClobFromFile>).
*/
procedure LoadClobFromFile(
  dstLob in out nocopy clob
  , fromPath varchar2
  , useCache boolean := null
);
/* pproc: LoadTxt
  Загружает текстовый файл в таблицу doc_input_document
  ( <body::LoadTxt>).
*/
procedure LoadTxt(
  fromPath varchar2
  , byLine integer
  , useCache boolean := null
);
/* group: Выгрузка данных */

/* pproc: AppendUnloadData
  Добавляет данные для выгрузки ( с буферизацией)
  ( <body::AppendUnloadData>).
*/
procedure AppendUnloadData(
  str varchar2 := null
);
/* pproc: DeleteUnloadData
  Очищает всё содержимое таблицы doc_output_document
  ( <body::DeleteUnloadData>).
*/
procedure DeleteUnloadData;
/* pproc: UnloadTxt
  Выгружает текстовый файл из таблицы doc_output_document
  ( <body::UnloadTxt>).
*/
procedure UnloadTxt(
  toPath varchar2
  , writeMode integer := Mode_Write
  , charEncoding varchar2 := null
  , isGzipped integer := null
  , waitForRequest integer := null
);

/* group: Выполнение команд */

/* pfunc: ExecCommand
  Выполняет команду ОС на сервере
  ( <body::ExecCommand>).
*/
function ExecCommand(
  command in varchar2
  , output in out nocopy clob
  , error in out nocopy clob
)
return integer;
/* pfunc: ExecCommand( CMD, ERR)
  Выполняет команду ОС на сервере
  ( <body::ExecCommand( CMD, ERR)>).
*/
function ExecCommand(
  command in varchar2
  , error in out nocopy clob
)
return integer;
/* pproc: ExecCommand( CMD, OUT)
  Выполняет команду ОС на сервере и проверяет ее код завершения
  ( <body::ExecCommand( CMD, OUT)>).
*/
procedure ExecCommand(
  command in varchar2
  , output in out nocopy clob
);
/* pproc: ExecCommand( CMD)
  Выполняет команду ОС на сервере и проверяет ее код завершения
  ( <body::ExecCommand( CMD)>).
*/
procedure ExecCommand(
  command in varchar2
);

end pkg_FileHandler;
/