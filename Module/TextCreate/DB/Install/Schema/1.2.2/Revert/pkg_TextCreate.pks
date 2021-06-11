create or replace package pkg_TextCreate is
/* package: pkg_TextCreate
  Набор утилит для работы с clob

  SVN root: Oracle/Module/TextCreate
*/

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'TextCreate';

/* pproc: NewText
  Инициализирует новый текст для формирования
  ( <body::NewText>)
*/
procedure NewText;

/* pproc: Append
  Добавление строки в текст
  ( <body::Append>)
*/  
procedure Append( 
  str varchar2
);  

/* pfunc: GetClob
  Получает сформированный clob
  ( <body::GetClob>).
*/
function GetClob
return clob;

/* pproc: Append(destClob)
  Добавление строки в текст 
  c использованием собственных переменных хранения
  ( <body::Append(destClob)>)
*/  
procedure Append(
  destClob in out nocopy clob
  , clobLength in out nocopy integer
  , stringBuffer in out nocopy varchar2
  , maxBufferSize integer
  , str varchar2
);

/* pfunc: GetZip
  Получает сформированный zip-архив
  ( <body::GetZip>).
*/
function GetZip(filename varchar2)
return blob;

end pkg_TextCreate;
/
