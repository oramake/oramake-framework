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



/* group: Функции */



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

  ( возвращаемые записи отсортированы по полю task_type_id)

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

/* pproc: logMessage
  Записывает в лог сообщение, относящееся к текущему выполняемому заданию.

  Параметры:
  levelCode                   - код уровня сообщения
  messageText                 - текст сообщения
  lineNumber                  - номер строки обрабатываемого файла, к которой
                                относится сообщение ( нумерация подряд начиная
                                с 1, 0 если сообщение не относится к строке
                                ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - функция предназначена для логирования процесса выполнения текущего
    задания, в случае вызова при отсутствии выполняемого задания будет
    выброшено исключение;

  ( <body::logMessage>)
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logError
  Записывает в лог сообщение по ошибке, относящееся к текущему выполняемому
  заданию.

  Параметры:
  messageText                 - текст сообщения
  lineNumber                  - номер строки обрабатываемого файла, к которой
                                относится сообщение ( нумерация подряд начиная
                                с 1, 0 если сообщение не относится к строке
                                ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - функция предназначена для логирования процесса выполнения текущего
    задания, в случае вызова при отсутствии выполняемого задания будет
    выброшено исключение;

  ( <body::logError>)
*/
procedure logError(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logWarning
  Записывает в лог предупреждающее сообщение, относящееся к текущему
  выполняемому заданию.

  Параметры:
  messageText                 - текст сообщения
  lineNumber                  - номер строки обрабатываемого файла, к которой
                                относится сообщение ( нумерация подряд начиная
                                с 1, 0 если сообщение не относится к строке
                                ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - функция предназначена для логирования процесса выполнения текущего
    задания, в случае вызова при отсутствии выполняемого задания будет
    выброшено исключение;

  ( <body::logWarning>)
*/
procedure logWarning(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logInfo
  Записывает в лог информационное сообщение, относящееся к текущему
  выполняемому заданию.

  Параметры:
  messageText                 - текст сообщения
  lineNumber                  - номер строки обрабатываемого файла, к которой
                                относится сообщение ( нумерация подряд начиная
                                с 1, 0 если сообщение не относится к строке
                                ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - функция предназначена для логирования процесса выполнения текущего
    задания, в случае вызова при отсутствии выполняемого задания будет
    выброшено исключение;

  ( <body::logInfo>)
*/
procedure logInfo(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logDebug
  Записывает в лог отладочное сообщение, относящееся к текущему выполняемому
  заданию.

  Параметры:
  messageText                 - текст сообщения
  lineNumber                  - номер строки обрабатываемого файла, к которой
                                относится сообщение ( нумерация подряд начиная
                                с 1, 0 если сообщение не относится к строке
                                ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - функция предназначена для логирования процесса выполнения текущего
    задания, в случае вызова при отсутствии выполняемого задания будет
    выброшено исключение;

  ( <body::logDebug>)
*/
procedure logDebug(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pproc: logTrace
  Записывает в лог трассировочное сообщение, относящееся к текущему
  выполняемому заданию.

  Параметры:
  messageText                 - текст сообщения
  lineNumber                  - номер строки обрабатываемого файла, к которой
                                относится сообщение ( нумерация подряд начиная
                                с 1, 0 если сообщение не относится к строке
                                ( по умолчанию))
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - функция предназначена для логирования процесса выполнения текущего
    задания, в случае вызова при отсутствии выполняемого задания будет
    выброшено исключение;

  ( <body::logTrace>)
*/
procedure logTrace(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
);

/* pfunc: findTaskLog
  Поиск лога выполнения задания.

  Параметры:
  taskLogId                   - Id записи лога
  taskId                      - Id задания
  startNumber                 - номер запуска задания ( начиная с 1)
  lineNumber                  - номер строки обрабатываемого файла ( начиная 1
                                или 0 для сообщений, не связанных со строкой
                                файла)
  levelCode                   - код уровня сообщения
  messageText                 - текст сообщения
                                ( поиск по like без учета регистра)
  startTaskLogId              - Id записи лога, с которой нужно начать выборку
  maxRowCount                 - максимальное число возвращаемых поиском записей
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат ( курсор):
  task_log_id                 - Id записи лога
  task_id                     - Id задания
  start_number                - номер запуска задания ( начиная с 1)
  line_number                 - номер строки обрабатываемого файла ( начиная 1
                                или 0 для сообщений, не связанных со строкой
                                файла)
  level_code                  - код уровня сообщения
  level_name                  - название уровня сообщения
  message_text                - текст сообщения
  date_ins                    - дата добавления записи

  Замечания:
  - возвращаемые записи отсортированы по полю task_log_id;

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

end pkg_TaskProcessor;
/
