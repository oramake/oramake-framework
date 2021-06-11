create or replace package pkg_TextCreate is
/* package: pkg_TextCreate
  Набор утилит для работы с clob

  SVN root: Oracle/Module/TextCreate
*/

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'TextCreate';


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
  Получает сформированный zip-архив

  Параметры:
    filename                 - название файла внутри архива

  Возврат:
    - blob с zip-архивом

  Замечание:
      Вызывает GetClob, т.е. предварительно выполняются все действия.

  ( <body::getZip>)
*/
function getZip(filename varchar2)
return blob;



/* group: Преобразование текстовых данных */

/* pfunc: convertToClob
  Преобразование BLOB ( большого объекта двоичных данных) в CLOB ( большого
  объекта текстовых данных). Предполагается, что данные в кодировке БД.

  Параметры:
  binaryData                  - двоичные данные для преобразования

  ( <body::convertToClob>)
*/
function convertToClob(
  binaryData blob
)
return clob;

/* pfunc: convertToBlob
  Преобразование СLOB ( большого объекта текстовых данных) в BLOB ( большого
  объекта двоичных данных). Предполагается, что данные в кодировке БД.

  Параметры:
  textData                    - текстовые данные для преобразования

  ( <body::convertToBlob>)
*/
function convertToBlob(
  textData clob
)
return blob;

end pkg_TextCreate;
/
