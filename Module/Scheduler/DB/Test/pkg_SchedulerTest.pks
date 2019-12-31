create or replace package pkg_SchedulerTest is
/* package: pkg_SchedulerTest
  Пакет для тестирования модуля.

  SVN root: Oracle/Module/Scheduler
*/



/* group: Константы */



/* group: Допустимые коды операций */

/* const: Activate_OperCode
  Код операции "Активация батча".
*/
Activate_OperCode constant varchar2(20) := 'ACTIVATE';

/* const: Deactivate_OperCode
  Код операции "Деактивация батча".
*/
Deactivate_OperCode constant varchar2(20) := 'DEACTIVATE';

/* const: Run_OperCode
  Код операции "Запуск батча".
*/
Run_OperCode constant varchar2(20) := 'RUN';

/* const: ShowLog_OperCode
  Код операции "Показ лога батча".
*/
ShowLog_OperCode constant varchar2(20) := 'SHOW_LOG';

/* const: WaitRun_OperCode
  Код операции "Ожидание окончания работы батча".
*/
WaitRun_OperCode constant varchar2(20) := 'WAIT_RUN';

/* const: WaitSession_OperCode
  Код операции "Ожидание активной сессии батча".
*/
WaitSession_OperCode constant varchar2(20) := 'WAIT_SESSION';

/* const: WaitAbsentSession_OperCode
  Код операции "Ожидание активной сессии батча".
*/
WaitAbsentSession_OperCode constant varchar2(20) := 'SESSION_ABSENT';



/* group: Функции */

/* pproc: killBatchSession
  Прерывает выполнение сессии батча.

  Параметры:
  batchShortName              - Краткое наименование пакетного задания
  waitSecond                  - Максимальное время ожидания завершения сессии
                                в секундах
                                (по умолчанию без ожидания)

  ( <body::killBatchSession>)
*/
procedure killBatchSession(
  batchShortName varchar2
  , waitSecond number := null
);

/* pproc: testBatchOperation
  Тестирует корректность выполнения операций над пакетными заданиями.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                (по умолчанию без ограничений)
  saveDataFlag                - Флаг сохранения тестовых данных
                                (1 да, 0 нет (по умолчанию))

  ( <body::testBatchOperation>)
*/
procedure testBatchOperation(
  testCaseNumber integer := null
  , saveDataFlag integer := null
);

/* pproc: setOutputFlag
  Установка флаг вывода в буфер dbms_output.

  Параметры:
  outputFlag                  - флаг вывода в буфер dbms_output.

  ( <body::setOutputFlag>)
*/
procedure setOutputFlag(
  outputFlag number
);

/* pproc: showLastRunLog
  Выводит лог последнего выполнения батча на экран.

  Параметры:
  batchId                     - id батча

  ( <body::showLastRunLog>)
*/
procedure showLastRunLog(
  batchId integer
);

/* pfunc: isOfMask
  Проверка соответствия строки маскам.

  Параметры:
  testString                  - строка
  maskList                    - список масок

  ( <body::isOfMask>)
*/
function isOfMask(
  testString varchar2
  , maskList varchar2
)
return integer;

/* pproc: execBatchOperation
  Выполняет операцию с батчами.

  batchShortNameList          - список масок батчей через ","
  operationCode               - код операции ( см. <pkg_SchedulerTest::Константы);

  ( <body::execBatchOperation>)
*/
procedure execBatchOperation(
  batchShortNameList varchar2
  , operationCode varchar2
);

/* pproc: testBatch
  Активирует батчи, запускает, ожидает завершения работы и деактивирует, затем
  показывает лог выполнения.

  Параметры:
  batchShortNameList          - список масок батчей через ","
  batchWaitSecond             - время ожидания работы батча в секундах ( по
                                истечению генерируется исключение,
                                по-умолчанию минута);
  raiseWhenRetryFlag          - генерация исключения в случае статуса выполнения
                                батча "Повторить попытку". По-умолчанию генерировать.

  ( <body::testBatch>)
*/
procedure testBatch(
  batchShortNameList varchar2
  , batchWaitSecond number := null
  , raiseWhenRetryFlag number := null
);

/* pproc: testLoadBatch
  Тестирование загрузки батча.

  Параметры:
  jobWhat                     - plsql-код задания ( job)
  batchXmlText                - спефикация пакетного задания в виде xml
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений если не указаны
                                  параметры jobWhat и batchXmlText, иначе
                                  только 1 тест ( загрузка задания и батча))

  ( <body::testLoadBatch>)
*/
procedure testLoadBatch(
  jobWhat varchar2 := null
  , batchXmlText clob := null
  , testCaseNumber integer := null
);

/* pproc: testNlsLanguage
  Проверка языка сообщения.

  Параметры:
  nlsLanguage                 - значение переменной NLS_LANGUAGE

  ( <body::testNlsLanguage>)
*/
procedure testNlsLanguage(
  nlsLanguage varchar2
);

/* pproc: testWebApi
  Тест API для web-интерфейса.

  ( <body::testWebApi>)
*/
procedure testWebApi;

/* pproc: testBatchOption
  Тест типа sch_batch_option_t.

  ( <body::testBatchOption>)
*/
procedure testBatchOption;

end pkg_SchedulerTest;
/
