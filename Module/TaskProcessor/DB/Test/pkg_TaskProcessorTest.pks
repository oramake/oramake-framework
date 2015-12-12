create or replace package pkg_TaskProcessorTest is
/* package: pkg_TaskProcessorTest
  Пакет для тестирования модуля.

  SVN root: Oracle/Module/TaskProcessor
*/



/* group: Функции */

/* pfunc: createProcessFileTask
  Создает задание по обработке файла ( без выполнения commit).

  Параметры:
  moduleName                  - название модуля, к которому относится задание
  processName                 - название процесса, к которому относится задание
  fileData                    - текстовые данные файла
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id задания.

  ( <body::createProcessFileTask>)
*/
function createProcessFileTask(
  moduleName varchar2
  , processName varchar2
  , fileData clob
  , operatorId integer := null
)
return integer;

/* pproc: executeLoadFileTask
  Создаёт задание по загрузке файла и ожидает его выполнения.

  Параметры:
  moduleName                  - название модуля, к которому относится задание
  processName                 - название процесса, к которому относится задание
  fileData                    - текстовые данные файла

  ( <body::executeLoadFileTask>)
*/
procedure executeLoadFileTask(
  moduleName varchar2
  , processName varchar2
  , fileData clob
);

/* pproc: userApiTest
  Тестирование API для пользовательского интерфейса.

  ( <body::userApiTest>)
*/
procedure userApiTest;

end pkg_TaskProcessorTest;
/
