create or replace package pkg_TextCreate is
/* package: pkg_TextCreate
  Набор утилит для работы с clob

  SVN root: Oracle/Module/TextCreate
*/

/* group: Константы */

/* group: Общие */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'TextCreate';


/* group: Кодировки */

/* const: UTF8_CharsetName
  Наименование кодировки UTF-8
*/
UTF8_CharsetName constant varchar2(30) := 'UTF8';

/* const: Windows1251_CharsetName
  Наименование кодировки Windows 1251
*/
Windows1251_CharsetName constant varchar2(30) := 'CL8MSWIN1251';


/* group: Функции */



/* group: Формирование текстовых данных */

/* pproc: newText
  Инициализирует новый текст для формирования

  Подробности:
    - использует dbms_lob.createtemporary
      для инициализации clob
    - открывает clob на запись
    - инициализирует переменные <currentClobLength>,
      <maxBufferLength>
    - очищает <buffer>

  ( <body::newText>)
*/
procedure newText;

/* pproc: append ( str )
  Добавление строки в текст

  Параметры:
    str - строка, при null сбрасывает содержимое буфера

  Замечание:
    - если до вызова добавления не был вызван <NewText>, то есть
      текст не был проинициализирован ранее, то генерируется
      исключение

  ( <body::append ( str )>)
*/
procedure append(
  str varchar2
);

/* pproc: append ( clob )
   Добавление clob в текст

   Параметры:
     с                         - текстовая информация в виде clob

   Замечание:
    - если до вызова добавления не был вызван <newText>, то есть
      текст не был проинициализирован ранее, то генерируется
      исключение

  ( <body::append ( clob )>)
*/
procedure append (
  c in clob
  );

/* pfunc: getClob
  Получает сформированный текст в виде clob

  Параметры:
    filename                 - название файла внутри архива

  Возврат:
    - <destinationClob>

  Замечание:
    - сбрасывает буфер в <destinationClob> с помощью append('')
    - закрывает <destinationClob>,
      предварительно проверяя, открыт ли он

  ( <body::getClob>)
*/
function getClob
return clob;

/* pproc: append ( destClob )
  Добавление строки в текст
  c использованием собственных переменных хранения

  Параметры:
    destClob                 - clob для формирования
    clobLength               - текущий размер clob. Передаётся для
                               оптимизации
    stringBuffer             - строковый буфер
    maxBufferSize            - максимальный размер буфера
    str                      - строка для добавления,
                               при null ( '') сбрасывает содержимое буфера
                               в clob

  Замечание:
    - destClob, clobLength, maxBufferSize должны быть
      инициализированы

  ( <body::append ( destClob )>)
*/
procedure append(
  destClob in out nocopy clob
  , clobLength in out nocopy integer
  , stringBuffer in out nocopy varchar2
  , maxBufferSize integer
  , str varchar2
);

/* pfunc: getZip
  Получает сформированный zip-архив. С возможностью выбора кодировки.

  Параметры:
    filename                 - название файла внутри архива
    charsetName              - наименование кодировки ( по-умолчанию кодировка БД)

  Возврат:
    destinationBlob          - blob с zip-архивом

  Замечание:
      Вызывает GetClob, т.е. предварительно выполняются все действия.

  ( <body::getZip>)
*/
function getZip(
  filename      varchar2
  , charsetName varchar2 default null
)
return blob;



/* group: Преобразование текстовых данных */

/* pfunc: convertToClob
  Преобразование BLOB ( большого объекта двоичных данных) в CLOB ( большого
  объекта текстовых данных). С возможностью выбора кодировки.

  Параметры:
    binaryData               - двоичные данные для преобразования
    charsetName              - наименование кодировки ( по-умолчанию кодировка БД)

  Возврат:
    resultText               - преобразованные текстовые данные

  ( <body::convertToClob>)
*/
function convertToClob(
  binaryData    blob
  , charsetName varchar2 default null
)
return clob;

/* pfunc: convertToBlob
  Преобразование СLOB ( большого объекта текстовых данных) в BLOB ( большого
  объекта двоичных данных). С возможностью выбора кодировки.

  Параметры:
    textData                 - текстовые данные для преобразования
    charsetName              - наименование кодировки ( по-умолчанию кодировка БД)

  Возврат:
    resultBlob               - преобразованные двоичные данные

  ( <body::convertToBlob>)
*/
function convertToBlob(
  textData      clob
  , charsetName varchar2 default null
)
return blob;

/* pfunc: base64Decode
  Преобразование Base64 ( большого объекта текстовых данных в кодировке
  Base64) в BLOB ( большого объекта двоичных данных).

  Входные параметры:
    textData                                  - Данные в Base64

  Возврат:
    resultBlob                                - Результирующий blob

  ( <body::base64Decode>)
*/
function base64Decode(
  textData      clob
)
return blob;

/* pfunc: base64Encode
  Преобразование BLOB ( большого объекта двоичных данных)
  в Base64 ( большого объекта текстовых данных в кодировке Base64).

  Входные параметры:
    binaryData                                - Двоичные данные для преобразования

  Возврат:
    resultClob                                - Результирующий clob

  ( <body::base64Encode>)
*/
function base64Encode(
  binaryData    blob
)
return clob;

end pkg_TextCreate;
/
