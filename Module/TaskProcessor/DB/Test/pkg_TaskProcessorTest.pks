create or replace package pkg_TaskProcessorTest is
/* package: pkg_TaskProcessorTest
  Пакет для тестирования модуля.

  SVN root: Oracle/Module/TaskProcessor
*/



/* group: Функции */

/* pproc: stopTask
  Снимает задания с выполнения.

  Параметры:
  moduleName                  - имя прикладного модуля
  processName                 - имя прикладного процесса, обрабатывающего этот
                                тип задания

  Замечания:
  - выполняется в автономной транзакции;

  ( <body::stopTask>)
*/
procedure stopTask(
  moduleName varchar2 := null
  , processName varchar2 := null
);

/* pproc: waitForTask
  Ожидание обработки задания.

  taskId                      - дентификатор задания
  maxCount                    - интервал ожидания в сек
                                ( по умолчанию 200)

  ( <body::waitForTask>)
*/
procedure waitForTask(
  taskId                      integer
, maxCount                    integer := null
);

/* pfunc: createProcessFileTask
  Создает задание по обработке файла ( без выполнения commit).

  Параметры:
  moduleName                  - название модуля, к которому относится задание
  processName                 - название процесса, к которому относится задание
  fileData                    - текстовые данные файла
  fileName                    - имя файла
                                (по умолчанию "Тестовый файл.csv")
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id задания.

  ( <body::createProcessFileTask>)
*/
function createProcessFileTask(
  moduleName varchar2
  , processName varchar2
  , fileData clob
  , fileName varchar2 := null
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
