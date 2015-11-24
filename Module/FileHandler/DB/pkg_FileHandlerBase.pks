create or replace package pkg_FileHandlerBase is
/* package: pkg_FileHandlerBase
  Константы для модуля FileHandler

  SVN root: Oracle/Module/FileHandler
*/

/* const: Module_Name
  Название модуля
*/
Module_Name constant varchar2(30) := 'FileHandler';

/* type: tabClob
  Массив clob
*/
type tabClob is table of clob;

/* group: Интервалы ожидания */

/* iconst: CheckCommand_Timeout
  Таймаут между проверками наличия команд для обработки
  ( в секундах )
*/
CheckCommand_Timeout integer := 1;

/* iconst: WaitRequest_Timeout
  Таймаут между проверками обработки запроса
  ( в секундах )
*/
WaitRequest_Timeout integer := 0.4;

/* group: Состояния запросов */

/* const: Wait_RequestStateCode
  Код состояния "Ожидание обработки"
*/
Wait_RequestStateCode constant varchar2(10) := 'WAIT';

/* const: Error_RequestStateCode
  Код состояния "Ошибка обработки"
*/
Error_RequestStateCode constant varchar2(10) := 'ERROR';

/* const: Processed_RequestStateCode
  Код состояния "Успешно обработан"
*/
Processed_RequestStateCode constant varchar2(10) := 'PROCESSED';

/* group: Коды операций */

/* const: FileList_OperationCode
  Код операции "Получение списка файлов"
*/
FileList_OperationCode constant varchar2(10) := 'LIST';

/* const: FileList_OperationCode
  Код операции "Получение списка подкаталогов"
*/
DirList_OperationCode constant varchar2(10) := 'DIRLIST';

/* const: Copy_OperationCode
  Код операции "Копирование файла"
*/
Copy_OperationCode constant varchar2(10) := 'COPY';

/* const: Delete_OperationCode
  Код операции "Удаления файла"
*/
Delete_OperationCode constant varchar2(10) := 'DELETE';

/* const: LoadText_OperationCode
  Код операции "Загрузка текстового файла"
*/
LoadText_OperationCode constant varchar2(10) := 'LOADTEXT';

/* const: LoadBinary_OperationCode
  Код операции "Загрузка двоичного файла"
*/
LoadBinary_OperationCode constant varchar2(10) := 'LOADBINARY';

/* const: UnloadText_OperationCode
  Код операции "Загрузка текстового файла"
*/
UnloadText_OperationCode constant varchar2(10) := 'UNLOADTEXT';

/* const: Command_OperationCode
  Код операции "Выполнение команды операционной системы"
*/
Command_OperationCode constant varchar2(10) := 'COMMAND';

/* group: Коды ошибок чтения из cache*/

/* const: FileCacheNotExists_ErrorCode
  Файл помечен как несуществующий
*/
FileCacheNotExists_ErrorCode constant integer := 20100;

/* const: FileCacheNotFound_ErrorCode
  Файл на найден
*/
FileCacheNotFound_ErrorCode constant integer := 20101;

/* const: FileCacheNoData_ErrorCode
  Данные файла не загружены в cache
*/
FileCacheNoData_ErrorCode constant integer := 20102;

end pkg_FileHandlerBase;
/