create or replace package pkg_TaskProcessor is
/* package: pkg_TaskProcessor
  Интерфейсный пакет модуля TaskProcessor.

  SVN root: Oracle/Module/TaskProcessor
*/



/* group: Константы */



/* group: Результат выполнения */

/* const: True_ResultCode
  Код результата "Положительный результат".
  Задание было успешно выполнено.
*/
True_ResultCode constant varchar2(10) :=
  pkg_TaskProcessorBase.True_ResultCode
;

/* const: False_ResultCode
  Код результата "Отрицательный результат".
  Задание было выполнено без ошибок, но результат не был достигнут.
*/
False_ResultCode constant varchar2(10) :=
  pkg_TaskProcessorBase.False_ResultCode
;

/* const: Error_ResultCode
  Код результата "Ошибка".
  При выполнении задания возникла ошибка.
*/
Error_ResultCode constant varchar2(10) :=
  pkg_TaskProcessorBase.Error_ResultCode
;

/* const: Stop_ResultCode
  Код результата "Остановлено".
  Выполнение задания было остановлено.
*/
Stop_ResultCode constant varchar2(10) :=
  pkg_TaskProcessorBase.Stop_ResultCode
;

/* const: Abort_ResultCode
  Код результата "Прервано".
  Выполнение задания было прервано.
*/
Abort_ResultCode constant varchar2(10) :=
  pkg_TaskProcessorBase.Abort_ResultCode
;



/* group: Типы контекста выполнения в логе */

/* const: Line_CtxTpName
  Тип контекста выполнения "Строка обрабатываемого файла".
  Обработка строки файла, в context_value_id указывается порядковый номер
  строки (начиная с 1). Тип контекста может использоваться в прикладных
  модулях для добавления сообщений лога, связанных с определенной строкой
  обрабатываемого файла.

  Пример:

  - добавляет в лог сообщение об успешной обработке строки файла с порядковым
    номером lineNumber (переменная logger типа lg_logger_t из модуля Logging).

  (code)

  logger.info(
    'Запись добавлена (строка файла #' || lineNumber || ').'
    , contextTypeShortName  => pkg_TaskProcessor.Line_CtxTpName
    , contextTypeModuleId   => pkg_TaskProcessor.getModuleId()
    , contextValueId        => lineNumber
  );

  (end)
*/
Line_CtxTpName constant varchar2(10) := 'line';



/* group: Функции */

/* pfunc: getModuleId
  Возвращает Id модуля TaskProcessor.

  Возврат:
  значение module_id из таблицы mod_module (модуль ModuleInfo).

  ( <body::getModuleId>)
*/
function getModuleId
return integer;



/* group: Типы заданий */

/* pfunc: mergeTaskType
  Создает или обновляет тип задания.

  Параметры:
  moduleName                  - имя прикладного модуля
  processName                 - имя прикладного процесса, обрабатывающего этот
                                тип задания
  taskTypeNameEng             - название типа задания ( анг.)
  taskTypeNameRus             - название типа задания ( рус.)
  execCommand                 - команда, вызываемая для обработки ( корректный
                                PL/SQL текст, возможно с использованием
                                предопределенных переменных)
  fileNamePattern             - маска имени файла ( для like, экранирующий
                                символ "\") с данными для обработки заданием (
                                если указана, то для выполнения задания нужно
                                загрузить файл с подходящим именем через
                                интерфейс, иначе файл для задания не
                                используется)
  accessRoleShortName         - название роли из модуля AccessOperator,
                                необходимой для доступа к заданиям этого типа
  taskKeepDay                 - время хранения заданий в днях, по истечении
                                которого неиспользуемые бездействующие задания
                                автоматически удаляются ( по умолчанию
                                неограничено)
  ignoreCheckFlag             - признак игнорирования проверки корректности
                                выполняемого действия
                                ( по умолчанию не игнорируется)
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Возврат:
  - флаг внесения изменений ( 0 нет изменений, 1 запись добавлена или обновлена)

  Замечания:
  - каждый тип задания должен быть уникален по комбинации параметров
    moduleName, processName;

  ( <body::mergeTaskType>)
*/
function mergeTaskType(
  moduleName varchar2
  , processName varchar2
  , taskTypeNameEng varchar2
  , taskTypeNameRus varchar2
  , execCommand varchar2
  , fileNamePattern varchar2 := null
  , accessRoleShortName varchar2 := null
  , taskKeepDay integer := null
  , ignoreCheckFlag boolean := null
  , operatorId integer := null
)
return integer;

/* pfunc: getTaskType
  Выводит список типов задач для указанного модуля.

  Параметры:
  moduleName                  - наименование модуля
  operatorId                  - Id оператора для исключения недоступных ему
                                типов задач
                                ( по умолчанию без ограничений)

  Возврат:
  task_type_id                - идентификатор типа задачи
  process_name                - наименование прикладного процесса
  task_type_name              - наименование типа задачи

  ( сортировка по task_type_name, task_type_id)

  Замечания:
  - в случае указания Id оператора в параметра operatorId из списка
    исключаются типы задач, у которых в таблице <tp_task_type> заполнено поле
    access_role_short_name и заданная в этом поле роль недоступна оператору;

  ( <body::getTaskType>)
*/
function getTaskType(
  moduleName varchar2
  , operatorId integer := null
)
return sys_refcursor;

/* pfunc: getTaskTypeId
  Возвращает Id типа задания для указанного процесса.

  Параметры:
  moduleName                  - имя прикладного модуля
  processName                 - имя прикладного процесса, обрабатывающего этот
                                тип задания
  isNotFoundRaised            - генерировать ли исключение в случае
                                отсутствия подходящего типа задания
                                ( 1 да ( по умолчанию), 0 нет)

  Возврат:
  Id типа задания либо null если запись не найдена и значение параметра
  isNotFoundRaised равно 0.

  Замечания:
  - функция предназначена для использования в прикладных модулях;

  ( <body::getTaskTypeId>)
*/
function getTaskTypeId(
  moduleName varchar2
  , processName varchar2
  , isNotFoundRaised integer := null
)
return integer;



/* group: Задания */

/* pfunc: createTask
  Добавляет задание.

  Параметры:
  moduleName                  - имя прикладного модуля
  processName                 - имя прикладного процесса
  startDate                   - дата запуска ( по умолчанию не запускать до
                                явного вызова <startTask>)
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Возврат:
  - Id добавленной записи

  Замечания:
  - в настроечной таблице <tp_task_type> должен быть предварительно добавлен
    соответствующий тип задания ( определяется по имени модуля и процесса);

  ( <body::createTask>)
*/
function createTask(
  moduleName varchar2
  , processName varchar2
  , startDate date := null
  , operatorId integer := null
)
return integer;

/* pfunc: createTask( FILE)
  Добавляет задание для обработки файла.

  Параметры:
  moduleName                  - имя прикладного модуля
  processName                 - имя прикладного процесса
  fileName                    - имя файла для обработки
  mimeTypeCode                - MIME-тип файла
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Возврат:
  - Id добавленной записи

  Замечания:
  - после выполнения функции в поле file_data таблицы <tp_file> ( для записи
    со значением task_id, равным возвращенному функцией значению) должны
    быть загружены данные файла, после чего вызвана функция <setFileLoaded>;
  - в настроечной таблице <tp_task_type> должен быть предварительно добавлен
    соответсвующий тип задания ( определяется по имени модуля и процесса);

  ( <body::createTask( FILE)>)
*/
function createTask(
  moduleName varchar2
  , processName varchar2
  , fileName varchar2
  , mimeTypeCode varchar2
  , operatorId integer := null
)
return integer;

/* pproc: setFileLoaded
  Устанавливает соответствующее состояние файла после завершения загрузки
  данных и ставит задание в очередь на выполнение.
  Функция должна вызываться после завершения загрузки данных файла в поле
  file_data таблицы <tp_file> ( при этом задание должно быть предварительно
  создано функцией createTask( FILE)).

  Параметры:
  taskId                      - Id задания
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  ( <body::setFileLoaded>)
*/
procedure setFileLoaded(
  taskId integer
  , operatorId integer := null
);

/* pproc: updateTaskParameter
  Вызывается при изменении прикладных параметров задания.
  Блокирует бездействующее задание, исключая возможность его запуска до
  завершения транзакции.

  Параметры:
  taskId                      - Id задания
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Замечания:
  - задание должно находиться в статусе "Бездействие", иначе выбрасывается
    исключение;

  ( <body::updateTaskParameter>)
*/
procedure updateTaskParameter(
  taskId integer
  , operatorId integer := null
);

/* pproc: deleteTask
  Удаляет задание.

  Параметры:
  taskId                      - Id задания
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Замечания:
  - задание должно находиться в статусе "Бездействие", иначе выбрасывается
    исключение;

  ( <body::deleteTask>)
*/
procedure deleteTask(
  taskId integer
  , operatorId integer := null
);

/* pfunc: findFile
  Поиск обработки файлов.

  Параметры:
  moduleName                  - название модуля, к которому относится задание
  processName                 - название процесса, к которому относится задание
  taskId                      - Id задания
  fileName                    - имя файла
                                ( сравнение по like без учета регистра)
  fromDate                    - начальная дата добавления файла
                                ( с точностью до дня, включительно)
  toDate                      - конечная дата добавления файла
                                ( с точностью до дня, включительно)
  maxRowCount                 - максимальное число возвращаемых поиском записей
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат ( курсор):
  task_id                     - Id задания
  task_type_id                - Id типа задания
  task_type_name              - название типа задания
  file_status_code            - код состояния файла
  file_status_name            - название состояния файла
  file_name                   - имя файла
  extension                   - расширение файла ( выделяется из имени файла)
  mime_type_code              - MIME-тип файла
  file_loaded_date            - дата загрузки данных файла
  task_start_date             - дата запуска обработки файла
  result_code                 - код результата обработки
  result_name                 - название результата обработки
  exec_result                 - числовой результат обработки
  exec_result_string          - строковый результат обработки
  error_message               - сообщение об ошибке при обработке
  file_date_ins               - дата добавления файла
  file_operator_id            - Id оператора, добавившего файл
  file_operator_name          - оператор, добавивший файл

  Замечания:
  - возвращаемые записи отсортированы по полю task_id в обратном порядке;

  ( <body::findFile>)
*/
function findFile(
  moduleName varchar2 := null
  , processName varchar2 := null
  , taskId integer := null
  , fileName varchar2 := null
  , fromDate date := null
  , toDate date := null
  , maxRowCount integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: Управление заданиями */

/* pproc: startTask
  Ставит задание в очередь на выполнение.

  Параметры:
  taskId                      - Id задания
  startDate                   - дата запуска ( по умолчанию немедленно)
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Замечания:
  - задание должно находиться в статусе "Бездействие", иначе выбрасывается
    исключение;

  ( <body::startTask>)
*/
procedure startTask(
  taskId integer
  , startDate date := null
  , operatorId integer := null
);

/* pproc: stopTask
  Останавливает выполнение задания.

  Параметры:
  taskId                      - Id задания
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)
  Замечания:
  - задание должно находиться в статусе "В очереди", иначе выбрасывается
    исключение;

  ( <body::stopTask>)
*/
procedure stopTask(
  taskId integer
  , operatorId integer := null
);



/* group: Лог выполнения заданий */

/* pfunc: findTaskLog
  Поиск лога выполнения задания.

  Параметры:
  taskLogId                   - Id записи лога
                                (по умолчанию без ограничений)
  taskId                      - Id задания
                                (по умолчанию без ограничений)
  startNumber                 - Номер запуска задания (начиная с 1)
                                (по умолчанию без ограничений)
  lineNumber                  - Номер строки обрабатываемого файла (начиная 1
                                или 0 для сообщений, не связанных со строкой
                                файла)
                                (по умолчанию без ограничений)
  levelCode                   - Код уровня сообщения
                                (по умолчанию без ограничений)
  messageText                 - Текст сообщения
                                (поиск по like без учета регистра)
                                (по умолчанию без ограничений)
  startTaskLogId              - Id записи лога, с которой нужно начать выборку
                                (по умолчанию без ограничений)
  maxRowCount                 - Максимальное число возвращаемых поиском записей
                                (по умолчанию без ограничений)
  operatorId                  - Id оператора, выполняющего операцию
                                (по умолчанию текущий)

  Возврат ( курсор):
  task_log_id                 - Id записи лога
  task_id                     - Id задания
  start_number                - Номер запуска задания ( начиная с 1)
  line_number                 - Номер строки обрабатываемого файла
                                (начиная 1 или 0 для сообщений, не связанных
                                со строкой файла)
  level_code                  - Код уровня сообщения
  level_name                  - Название уровня сообщения
  message_text                - Текст сообщения
  date_ins                    - Дата добавления записи

  (сортировка по полю task_log_id)

  Замечания:
  - обязательно должно быть задано отличное от NULL значение хотя бы для
    одного из параметров taskLogId или taskId;

  ( <body::findTaskLog>)
*/
function findTaskLog(
  taskLogId integer := null
  , taskId integer := null
  , startNumber integer := null
  , lineNumber integer := null
  , levelCode varchar2 := null
  , messageText varchar2 := null
  , startTaskLogId integer := null
  , maxRowCount integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: Справочники */

/* pfunc: getLevel
  Возвращает список уровней сообщений лога.

  Возврат ( курсор):
  level_code                  - код уровня сообщения
  level_name                  - название уровня сообщения

  Замечания:
  - возвращаемые записи отсортированы по полю level_code;

  ( <body::getLevel>)
*/
function getLevel
return sys_refcursor;

/* pfunc: getResult
  Возвращает возможные результаты выполнения заданий.

  Возврат ( курсор):
  result_code             - код результата выполнения
  result_name             - название результата выполнения

  Замечания:
  - возвращаемые записи отсортированы по result_code;

  ( <body::getResult>)
*/
function getResult
return sys_refcursor;



/* group: Устаревшие функции */

/* pproc: logMessage
  Устаревшая функция, вместо нее следует использовать функции логирования
  сообщений из типа lg_logger_t (модуль Logging), при этом для указания строки
  обрабатываемого файла следует использовать контекст выполнения
  <Line_CtxTpName>.

  ( <body::logMessage>)
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logError
  Устаревшая функция аналогично <logMessage>.

  ( <body::logError>)
*/
procedure logError(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logWarning
  Устаревшая функция аналогично <logMessage>.

  ( <body::logWarning>)
*/
procedure logWarning(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logInfo
  Устаревшая функция аналогично <logMessage>.

  ( <body::logInfo>)
*/
procedure logInfo(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logDebug
  Устаревшая функция аналогично <logMessage>.

  ( <body::logDebug>)
*/
procedure logDebug(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logTrace
  Устаревшая функция аналогично <logMessage>.

  ( <body::logTrace>)
*/
procedure logTrace(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

end pkg_TaskProcessor;
/
