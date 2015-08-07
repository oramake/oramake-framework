create or replace package pkg_TextCreateJava as
/* package: pkg_TextCreateJava
  Интерфейс к Java библиотеке для сжатия текстовых данных для сохранения их в поле Blob

  SVN root: Oracle/Module/TextCreate
*/

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'TextCreate';
/* pfunc: blobCompress

  Сжатие входящего blob

  Параметры:

   sourceBlob   - данные для сжатия
   sourceFileName - название файла внутри архива

  Возвращаемое значение:  
  
  blob (zip архив)

*/
 function blobCompress(
     sourceBlob blob
   , sourceFileName varchar2
 ) return blob as language java name
   'pkg_TextCreate.compress(oracle.sql.BLOB, java.lang.String) return oracle.sql.BLOB';
end;
/