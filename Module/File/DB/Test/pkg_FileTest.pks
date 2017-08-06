create or replace package pkg_FileTest is
/* package: pkg_FileTest
  Пакет для тестирования модуля.

  SVN root: Oracle/Module/File
*/



/* group: Константы */



/* group: Параметры тестирования */

/* const: TestDirectoryPath_OptionSName
  Наименование настроечного параметра "Тесты: директория".
*/
TestDirectoryPath_OptionSName constant varchar2(50) := 'TestDirectoryPath';



/* group: Функции */



/* group: Утилиты */

/* pfunc: convertToClob
  Конвертация двоичных данных в символьные.

  Параметры:
  fileData                    - данные файла
  charEncoding                - кодировка файла
                                ( по умолчанию считается, что файл в кодировке
                                БД)

  ( <body::convertToClob>)
*/
function convertToClob(
  fileData in out nocopy blob
  , charEncoding varchar2 := null
)
return clob;



/* group: Тестирование загрузки команд */

/* pproc: setTestDirectory
  Установка тестовой директории.

  Параметры:
  directoryPath               - путь к директории

  ( <body::setTestDirectory>)
*/
procedure setTestDirectory(
  directoryPath varchar2
);

/* pproc: testBinaryFile
  Тестирование загрузки и выгрузки двоичного файла
  ( <pkg_FileOrigin.unloadBlobToFile>, <pkg_FileOrigin.loadBlobFromFile>).

  Параметры:
  fileSize                    - размер файла ( в байтах)

  ( <body::testBinaryFile>)
*/
procedure testBinaryFile(
  fileSize integer
);

/* pproc: testTextFile
  Тестирование загрузки и выгрузки текстового файла
  ( <pkg_FileOrigin.unloadClobToFile>, <pkg_FileOrigin.loadClobFromFile>).

  Параметры:
  fileSize                    - размер файла ( в байтах)

  ( <body::testTextFile>)
*/
procedure testTextFile(
  fileSize integer
);

/* pproc: testLoadTxt
  Тестирование загрузки текстового файла с помощью <pkg_FileOrigin.loadTxt>;

  Параметры:
  fileSize                    - размер файла ( в байтах)

  ( <body::testLoadTxt>)
*/
procedure testLoadTxt(
  fileSize integer
);

/* pproc: testLoadTxtByLine
  Тестирование загрузки текстового файла с помощью <pkg_FileOrigin.loadTxt>;

  Параметры:
  lineCount                   - количество строк в файле

  ( <body::testLoadTxtByLine>)
*/
procedure testLoadTxtByLine(
  lineCount integer
);

/* pproc: testUnloadData
  Тестирование корректности ( отсутствия искажения) выгрузки данных в файл с
  помощью процедур <pkg_FileOrigin.unloadBlobToFile>,
  <pkg_FileOrigin.unloadClobToFile>, <pkg_FileOrigin.unloadTxt>.

  Параметры:
  unloadFunctionName          - имя тестируемой процедуры или функции
                                ( возможные варианты: "unloadBlobToFile",
                                "unloadClobToFile", "unloadTxt", по умолчанию
                                все вышеперечисленные)
  skip0x98CheckFlag          - флаг исключения из проверки выгрузки символа с
                                кодом 0x98, который не определен в кодировке
                                Windows-1251
                                ( 1 да ( по умолчанию), 0 нет)
  charEncoding                - кодировка для выгрузки файла, применяемая при
                                выгрузке с помощью процедуры unloadClobToFile
                                ( по умолчанию тестируется выгрузка без указания
                                  кодировки и выгрузка в кодировке utf8)
  fileName                    - имя файла ( по-умолчанию 'testUnloadData.txt')

  ( <body::testUnloadData>)
*/
procedure testUnloadData(
  unloadFunctionName varchar2 := null
, skip0x98CheckFlag  integer := null
, charEncoding       varchar2 := null
, fileName           varchar2 := null
);

/* pproc: testUnloadTxt
  Тестирование выгрузки файла с помощью <pkg_FileOrigin.unloadTxt>;

  Параметры:
  fileSize                    - размер файла
  stringSize                  - размер строки

  ( <body::testUnloadTxt>)
*/
procedure testUnloadTxt(
  fileSize integer
  , stringSize integer
);

/* pproc: testExecCommand
  Тестирование запуска команд OS ( <pkg_FileOrigin.execCommand>);

  ( <body::testExecCommand>)
*/
procedure testExecCommand;

/* pproc: testEncodingLoad
  Тестирование загрузки файла в определённой кодировке.

  Параметры:
  fileSize                    - размер файла
  charEncoding                - кодировка файла

  ( <body::testEncodingLoad>)
*/
procedure testEncodingLoad(
  fileSize integer
  , charEncoding varchar2
);

/* pproc: testWriteMode
  Тестирование режима перезаписи файла.

  ( <body::testWriteMode>)
*/
procedure testWriteMode(
  writeMode integer
  , expectedExceptionFlag1 number
  , expectedExceptionFlag2 number
);

/* pproc: testMakeDirectory
  Тестирование создания директории.

  Параметры:
  parentDirectory             - родительская директория для создания

  ( <body::testMakeDirectory>)
*/
procedure testMakeDirectory(
  parentDirectory varchar2
);

/* pproc: unitTest
  Общий тест.

  Параметры:
  fileSize                    - размер файла

  ( <body::unitTest>)
*/
procedure unitTest(
  fileSize integer
);



/* group: Тесты по классам файлов */

/* pproc: testFsOperation
  Тестирование выполнения операций с файлами файловой системы.

  ( <body::testFsOperation>)
*/
procedure testFsOperation;

/* pproc: testHttpOperation
  Тестирование выполнения операций по HTTP.

  Параметры:
  httpInternetFileTest        - флаг тестирования выполнения операций по HTTP
                                c файлами в Интернет ( 1 да, 0 нет ( по
                                умолчанию))

  ( <body::testHttpOperation>)
*/
procedure testHttpOperation(
  httpInternetFileTest integer := null
);

end pkg_FileTest;
/
