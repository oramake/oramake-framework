create or replace package body pkg_TaskProcessor is
/* package body: pkg_TaskProcessor::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_TaskProcessorBase.Module_Name
  , objectName  => 'pkg_TaskProcessor'
);



/* group: Функции */

/* ifunc: checkAccess
  Проверяет права доступа оператора и в случае отсутствия прав выбрасывает
  исключение.

  Параметры:
  operatorId                  - Id оператора, для котрого проверяются права
                                ( если null, то используется Id текущего
                                зарегистированного оператора)
  taskTypeId                  - Id типа задания, над которым производиться
                                операция

  Возврат:
  Id оператора, для которого были проверены права ( обязательно указано,
  не равно null)
*/
function checkAccess(
  operatorId integer
  , taskTypeId integer
)
return integer
is

  -- Реально проверяемый Id оператора
  checkOperatorId integer := operatorId;



  /*
    Проверяет доступность типа задания для оператора.
  */
  function isTaskTypeAccess
  return boolean
  is

    -- Роль, дающая права на тип задания
    accessRoleShortName tp_task_type.access_role_short_name%type;

    isOk integer;

  begin

   select
         min( tt.access_role_short_name)
     into accessRoleShortName
     from
      tp_task_type tt
    where
      tt.task_type_id = taskTypeId;

   if accessRoleShortName is not null
   then

       isOk := pkg_Operator.isRole(operatorId    => checkOperatorId
                                 , roleShortName => accessRoleShortName);
    else

       isOk := 1;

    end if;

    return coalesce( isOk > 0, false);
  end isTaskTypeAccess;



-- checkAccess
begin

  -- По умолчанию зарегистрированный оператор
  if checkOperatorId is null then
    checkOperatorId := pkg_Operator.getCurrentUserId();
  end if;

  -- Полный доступ для администратора
  if pkg_Operator.IsRole(
      operatorId => checkOperatorId
      , roleShortName => pkg_TaskProcessorBase.Administrator_RoleName
      ) = 0
    then
    if taskTypeId is null or not isTaskTypeAccess() then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Отсутствуют права доступа ('
          || ' operatorId=' || checkOperatorId
          || ').'
      );
    end if;
  end if;
  return checkOperatorId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при проверке прав доступа оператора ('
        || ' operatorId=' || operatorId
        || ', taskTypeId=' || taskTypeId
        || ').'
      )
    , true
  );
end checkAccess;



/* group: Типы заданий */

/* func: mergeTaskType
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
return integer
is
begin
  merge into
    tp_task_type d
  using
    (
    select
      a.*
      , operatorId as operator_id
    from
      (
      select
        moduleName as module_name
        , processName as process_name
        , taskTypeNameEng as task_type_name_eng
        , taskTypeNameRus as task_type_name_rus
        , execCommand as exec_command
        , fileNamePattern as file_name_pattern
        , accessRoleShortName as access_role_short_name
        , taskKeepDay as task_keep_day
      from dual
      minus
      select
        tt.module_name
        , tt.process_name
        , tt.task_type_name_eng
        , tt.task_type_name_rus
        , tt.exec_command
        , tt.file_name_pattern
        , tt.access_role_short_name
        , tt.task_keep_day
      from
        tp_task_type tt
      where
        tt.module_name = moduleName
        and tt.process_name = processName
      ) a
    ) s
  on
    (
    d.module_name = s.module_name
    and d.process_name = s.process_name
    )
  when not matched then insert
    (
    module_name
    , process_name
    , task_type_name_eng
    , task_type_name_rus
    , exec_command
    , file_name_pattern
    , access_role_short_name
    , task_keep_day
    , operator_id
    )
  values
    (
    s.module_name
    , s.process_name
    , s.task_type_name_eng
    , s.task_type_name_rus
    , s.exec_command
    , s.file_name_pattern
    , s.access_role_short_name
    , s.task_keep_day
    , s.operator_id
    )
  when matched then update set
    d.task_type_name_eng            = s.task_type_name_eng
    , d.task_type_name_rus          = s.task_type_name_rus
    , d.exec_command                = s.exec_command
    , d.file_name_pattern           = s.file_name_pattern
    , d.access_role_short_name      = s.access_role_short_name
    , d.task_keep_day               = s.task_keep_day
  ;
  return SQL%ROWCOUNT;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при обновлении типа задания ('
        || ' moduleName="' || moduleName || '"'
        || ', processName="' || processName || '"'
        || ', fileNamePattern="' || fileNamePattern || '"'
        || ', accessRoleShortName="' || accessRoleShortName || '"'
        || ').'
      )
    , true
  );
end mergeTaskType;

/* func: getTaskType
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
*/
function getTaskType(
  moduleName varchar2
  , operatorId integer := null
)
return sys_refcursor
is

  -- возвращаемый курсор
  rc sys_refcursor;

-- getTaskType
begin
  open rc for
    select
      tt.task_type_id
      , tt.process_name
      , tt.task_type_name_rus as task_type_name
    from
      tp_task_type tt
    where
      tt.module_name = moduleName
      and (
        operatorId is null
        or tt.access_role_short_name is null
        or exists
          (
          select
            null
          from
            v_op_operator_role opr
            inner join v_op_role rl
              on rl.role_id = opr.role_id
          where
            opr.operator_id = operatorId
            and rl.role_short_name = tt.access_role_short_name
          )
      )
    order by
      tt.task_type_name_rus
      , tt.task_type_id
  ;

  return rc;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при получении списка типов задач ('
          || ' moduleName="' || moduleName || '"'
          || ', operatorId=' || operatorId
          || ').'
          )
      , true
    );

end getTaskType;

/* func: getTaskTypeId
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
*/
function getTaskTypeId(
  moduleName varchar2
  , processName varchar2
  , isNotFoundRaised integer := null
)
return integer
is

  -- Id типа задания
  taskTypeId integer;

begin
  select
    min( t.task_type_id)
  into taskTypeId
  from
    tp_task_type t
  where
    t.module_name = moduleName
    and t.process_name = processName
  ;
  if taskTypeId is null and coalesce( isNotFoundRaised, 1) != 0 then
    raise_application_error(
      pkg_Error.RowNotFound
      , 'Не найден тип задания.'
    );
  end if;
  return taskTypeId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении Id типа задания ('
        || ' moduleName="' || moduleName || '"'
        || ', processName="' || processName || '"'
        || ', isNotFoundRaised=' || isNotFoundRaised
        || ').'
      )
    , true
  );
end getTaskTypeId;



/* group: Задания */

/* iproc: lockTask
  Блокирует и возвращает задание.

  Параметры:
  rowData                     - данные записи ( возврат)
  taskId                      - Id задания
*/
procedure lockTask(
  rowData out nocopy tp_task%rowtype
  , taskId integer
)
is
begin
  select
    t.*
  into rowData
  from
    tp_task t
  where
    t.task_id = taskId
  for update nowait;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при блокировке задания ('
        || ' taskId=' || taskId
        || ').'
      )
    , true
  );
end lockTask;

/* iproc: checkTask
  Выполняет проверку перед выполнением операции над заданием.

  Параметры:
  taskId                      - Id задания
  operatorId                  - Id оператора, выполняющего операцию ( если null,
                                то проверяется и возвращается текущий оператор)
  taskStatusCode              - код состояния, в котором должно находиться
                                задание ( по умолчанию без проверки)
*/
procedure checkTask(
  taskId integer
  , operatorId in out nocopy integer
  , taskStatusCode varchar2 := null
)
is

  -- Текущие данные
  rec tp_task%rowtype;

begin

  -- Получаем текущие данные
  lockTask( rec, taskId);

  -- Проверка прав доступа
  operatorId := checkAccess( operatorId, rec.task_type_id);

  -- Проверка состояния задания
  if nullif( taskStatusCode, rec.task_status_code) is not null then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Текущее состояние задания не позволяет выполнить операцию ('
        || ' task_status_code="' || rec.task_status_code || '"'
        || ').'
    );
  end if;
end checkTask;

/* ifunc: createTask( INTERNAL)
  Добавляет задание.

  Параметры:
  moduleName                  - имя прикладного модуля
  processName                 - имя прикладного процесса
  startDate                   - дата запуска ( по умолчанию не запускать до
                                явного вызова <startTask>)
  fileName                    - имя файла для обработки
  mimeTypeCode                - MIME-тип файла
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Возврат:
  - Id добавленной записи
*/
function createTask(
  moduleName varchar2
  , processName varchar2
  , startDate date
  , fileName varchar2
  , mimeTypeCode varchar2
  , operatorId integer
)
return integer
is

  -- Id добавленной записи
  taskId tp_task.task_id%type;

  -- Id типа добавляемого задания
  taskTypeId tp_task.task_type_id%type;

  -- Маска имени файла
  fileNamePattern tp_task_type.file_name_pattern%type;

  -- Id оператора, выполняющего операцию
  manageOperatorId integer := operatorId;




  /*
    Определяет тип задания.
  */
  procedure getTaskType
  is
  begin
    select
      tt.task_type_id
      , tt.file_name_pattern
    into taskTypeId, fileNamePattern
    from
      tp_task_type tt
    where
      tt.module_name = moduleName
      and tt.process_name = processName
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при определении типа задания.'
        )
      , true
    );
  end getTaskType;



  /*
    Добавляет запись в tp_task.
  */
  procedure addTask
  is
  begin
    insert into
      tp_task
    (
      task_type_id
      , task_status_code
      , next_start_date
      , manage_date
      , manage_operator_id
      , operator_id
    )
    values
    (
      taskTypeId
      , case when startDate is null then
          pkg_TaskProcessorBase.Idle_TaskStatusCode
        else
          pkg_TaskProcessorBase.Queued_TaskStatusCode
        end
      , startDate
      , sysdate
      , manageOperatorId
      , manageOperatorId
    )
    returning task_id into taskId;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при добавлении записи для задания.'
        )
      , true
    );
  end addTask;



  /*
    Добавляет запись для файла.
  */
  procedure addFile
  is
  begin
    insert into
      tp_file
    (
      task_id
      , file_status_code
      , file_name
      , mime_type_code
      , operator_id
    )
    values
    (
      taskId
      , pkg_TaskProcessorBase.Loading_FileStatusCode
      , fileName
      , mimeTypeCode
      , manageOperatorId
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при добавлении записи для файла.'
        )
      , true
    );
  end addFile;



-- createTask
begin

  -- Определение типа задания
  getTaskType();

  -- Проверка прав доступа
  manageOperatorId := checkAccess( operatorId, taskTypeId);

  if fileNamePattern is not null then
    if fileName is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Для данного типа задания необходима загрузка файла для обработки ('
        || ' task_type_id=' || taskTypeId
        || ').'
      );
    elsif fileName not like fileNamePattern escape '\' then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Имя файла не соответствует шаблону ('
          || ' fileNamePattern="' || fileNamePattern || '"'
          || ').'
      );
    end if;
  elsif fileName is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Для данного типа задания не разрешена загрузка файла ('
        || ' task_type_id=' || taskTypeId
        || ').'
    );
  end if;

  -- Добавление задания
  addTask();

  -- Добавление записи для файла
  if fileNamePattern is not null then
    addFile();
  end if;

  return taskId;
end createTask;

/* func: createTask
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
*/
function createTask(
  moduleName varchar2
  , processName varchar2
  , startDate date := null
  , operatorId integer := null
)
return integer
is
begin
  return
    createTask(
      moduleName        => moduleName
      , processName     => processName
      , startDate       => startDate
      , fileName        => null
      , mimeTypeCode    => null
      , operatorId      => operatorId
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при добавлении задания ('
        || ' moduleName="' || moduleName || '"'
        || ', processName="' || processName || '"'
        || ', startDate=' || to_char( startDate, 'dd.mm.yyyy hh24:mi:ss')
        || ').'
      )
    , true
  );
end createTask;

/* func: createTask( FILE)
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
*/
function createTask(
  moduleName varchar2
  , processName varchar2
  , fileName varchar2
  , mimeTypeCode varchar2
  , operatorId integer := null
)
return integer
is
begin

  -- По наличию имени файла в функции ниже определяется вид добавляемого задания
  if fileName is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не указано имя файла.'
    );
  end if;

  return
    createTask(
      moduleName        => moduleName
      , processName     => processName
      , startDate       => null
      , fileName        => fileName
      , mimeTypeCode    => mimeTypeCode
      , operatorId      => operatorId
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при добавлении задания для обработки файла ('
        || ' moduleName="' || moduleName || '"'
        || ', processName="' || processName || '"'
        || ', fileName="' || fileName || '"'
        || ', mimeTypeCode="' || mimeTypeCode || '"'
        || ').'
      )
    , true
  );
end createTask;

/* proc: setFileLoaded
  Устанавливает соответствующее состояние файла после завершения загрузки
  данных и ставит задание в очередь на выполнение.
  Функция должна вызываться после завершения загрузки данных файла в поле
  file_data таблицы <tp_file> ( при этом задание должно быть предварительно
  создано функцией createTask( FILE)).

  Параметры:
  taskId                      - Id задания
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)
*/
procedure setFileLoaded(
  taskId integer
  , operatorId integer := null
)
is



  /*
    Устанавливает состояние файла.
  */
  procedure setFileStatus
  is
  begin
    update
      tp_file t
    set
      t.file_status_code = pkg_TaskProcessorBase.Loaded_FileStatusCode
      , t.loaded_date = sysdate
    where
      t.task_id = taskId
    ;
    if SQL%ROWCOUNT = 0 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Не найдена запись для файла.'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при установке состояния файла.'
        )
      , true
    );
  end setFileStatus;



-- setFileLoaded
begin

  -- Делаем первым шагом, чтобы проверить права доступа и заблокировать запись
  -- по заданию
  startTask(
    taskId        => taskId
    , operatorId  => operatorId
  );

  setFileStatus();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при изменении состояния файла после загрузки данных ('
        || ' taskId=' || taskId
        || ').'
      )
    , true
  );
end setFileLoaded;

/* proc: updateTaskParameter
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
*/
procedure updateTaskParameter(
  taskId integer
  , operatorId integer := null
)
is

  -- Id оператора, выполняющего операцию
  manageOperatorId integer := operatorId;

begin

  -- Проверка перед выполнением операции
  checkTask(
    taskId              => taskId
    , operatorId        => manageOperatorId
    , taskStatusCode    => pkg_TaskProcessorBase.Idle_TaskStatusCode
  );

  -- Выполняем операцию
  update
    tp_task t
  set
    t.manage_date = sysdate
    , t.manage_operator_id = manageOperatorId
  where
    t.task_id = taskId
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при изменении параметров задания ('
        || ' taskId=' || taskId
        || ').'
      )
    , true
  );
end updateTaskParameter;

/* proc: deleteTask
  Удаляет задание.

  Параметры:
  taskId                      - Id задания
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Замечания:
  - задание должно находиться в статусе "Бездействие", иначе выбрасывается
    исключение;
*/
procedure deleteTask(
  taskId integer
  , operatorId integer := null
)
is

  -- Id оператора, выполняющего операцию
  manageOperatorId integer := operatorId;

begin

  -- Проверка перед выполнением операции
  checkTask(
    taskId              => taskId
    , operatorId        => manageOperatorId
    , taskStatusCode    => pkg_TaskProcessorBase.Idle_TaskStatusCode
  );

  -- Выполняем операцию
  delete from
    tp_task t
  where
    t.task_id = taskId
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении задания ('
        || ' taskId=' || taskId
        || ').'
      )
    , true
  );
end deleteTask;

/* func: findFile
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
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

  -- Динамически формируемый текст запроса
  dsql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
  select
    t.task_id
    , ts.task_type_id
    , tt.task_type_name_rus as task_type_name
    , t.file_status_code
    , fs.file_status_name
    , t.file_name
    , substr( t.file_name, nullif( instr( t.file_name, ''.'', -1), 0) + 1)
      as extension
    , t.mime_type_code
    , t.loaded_date as file_loaded_date
    , ts.start_date as task_start_date
    , ts.result_code
    , rs.result_name_rus as result_name
    , ts.exec_result
    , ts.error_message
    , t.date_ins as file_date_ins
    , t.operator_id as file_operator_id
    , op.operator_name as file_operator_name
  from
    tp_file t
    inner join tp_task ts
      on ts.task_id = t.task_id
    inner join tp_task_type tt
      on tt.task_type_id = ts.task_type_id
    inner join tp_file_status fs
      on fs.file_status_code = t.file_status_code
    inner join op_operator op
      on op.operator_id = t.operator_id
    left outer join tp_result rs
      on rs.result_code = ts.result_code
  where
    $(condition)
  order by
    t.task_id desc
  ) a
where
  $(rownumCondition)
'
  );

begin
  dsql.addCondition(
    'tt.module_name =', moduleName is null
  );
  dsql.addCondition(
    'tt.process_name =', processName is null
  );
  dsql.addCondition(
    't.task_id =', taskId is null
  );
  dsql.addCondition(
    'upper( t.file_name) like upper( :fileName)', fileName is null
  );
  dsql.addCondition(
    't.date_ins >= trunc( :fromDate)', fromDate is null
  );
  dsql.addCondition(
    't.date_ins < trunc( :toDate) + 1', toDate is null
  );
  dsql.useCondition( 'condition');
  dsql.addCondition(
    'rownum <= :maxRowCount', maxRowCount is null
  );
  dsql.useCondition( 'rownumCondition');
  open rc for
    dsql.getSqlText()
  using
    moduleName
    , processName
    , taskId
    , fileName
    , fromDate
    , toDate
    , maxRowCount
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при поиске обработки файлов ('
        || ' moduleName="' || moduleName || '"'
        || ', processName="' || processName || '"'
        || ', taskId=' || taskId
        || ').'
      )
    , true
  );
end findFile;



/* group: Управление заданиями */

/* proc: startTask
  Ставит задание в очередь на выполнение.

  Параметры:
  taskId                      - Id задания
  startDate                   - дата запуска ( по умолчанию немедленно)
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Замечания:
  - задание должно находиться в статусе "Бездействие", иначе выбрасывается
    исключение;
*/
procedure startTask(
  taskId integer
  , startDate date := null
  , operatorId integer := null
)
is

  -- Id оператора, выполняющего операцию
  manageOperatorId integer := operatorId;

begin

  -- Проверка перед выполнением операции
  checkTask(
    taskId              => taskId
    , operatorId        => manageOperatorId
    , taskStatusCode    => pkg_TaskProcessorBase.Idle_TaskStatusCode
  );

  -- Выполняем операцию
  update
    tp_task t
  set
    t.task_status_code = pkg_TaskProcessorBase.Queued_TaskStatusCode
    , t.next_start_date = coalesce( startDate, sysdate)
    , t.manage_date = sysdate
    , t.manage_operator_id = manageOperatorId
  where
    t.task_id = taskId
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при постановке задания в очередь на выполнение ('
        || ' taskId=' || taskId
        || ').'
      )
    , true
  );
end startTask;

/* proc: stopTask
  Останавливает выполнение задания.

  Параметры:
  taskId                      - Id задания
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)
  Замечания:
  - задание должно находиться в статусе "В очереди", иначе выбрасывается
    исключение;
*/
procedure stopTask(
  taskId integer
  , operatorId integer := null
)
is

  -- Id оператора, выполняющего операцию
  manageOperatorId integer := operatorId;

begin

  -- Проверка перед выполнением операции
  checkTask(
    taskId              => taskId
    , operatorId        => manageOperatorId
    , taskStatusCode    => pkg_TaskProcessorBase.Queued_TaskStatusCode
  );

  -- Выполняем операцию
  update
    tp_task ts
  set
    ts.task_status_code = pkg_TaskProcessorBase.Idle_TaskStatusCode
    , ts.next_start_date = null
    , ts.manage_date = sysdate
    , ts.manage_operator_id = manageOperatorId
  where
    ts.task_id = taskId
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при остановке выполнения задания ('
        || ' taskId=' || taskId
        || ').'
      )
    , true
  );
end stopTask;



/* group: Лог выполнения заданий */

/* proc: logMessage
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
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
)
is
begin
  pkg_TaskProcessorHandler.logMessage(
    levelCode       => levelCode
    , messageText   => messageText
    , lineNumber    => lineNumber
    , operatorId    => operatorId
  );
end logMessage;

/* proc: logError
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
*/
procedure logError(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
)
is
begin
  logMessage(
    levelCode       => pkg_Logging.Error_LevelCode
    , messageText   => messageText
    , lineNumber    => lineNumber
    , operatorId    => operatorId
  );
end logError;

/* proc: logWarning
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
*/
procedure logWarning(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
)
is
begin
  logMessage(
    levelCode       => pkg_Logging.Warning_LevelCode
    , messageText   => messageText
    , lineNumber    => lineNumber
    , operatorId    => operatorId
  );
end logWarning;

/* proc: logInfo
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
*/
procedure logInfo(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
)
is
begin
  logMessage(
    levelCode       => pkg_Logging.Info_LevelCode
    , messageText   => messageText
    , lineNumber    => lineNumber
    , operatorId    => operatorId
  );
end logInfo;

/* proc: logDebug
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
*/
procedure logDebug(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
)
is
begin
  logMessage(
    levelCode       => pkg_Logging.Debug_LevelCode
    , messageText   => messageText
    , lineNumber    => lineNumber
    , operatorId    => operatorId
  );
end logDebug;

/* proc: logTrace
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
*/
procedure logTrace(
  messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
)
is
begin
  logMessage(
    levelCode       => pkg_Logging.Trace_LevelCode
    , messageText   => messageText
    , lineNumber    => lineNumber
    , operatorId    => operatorId
  );
end logTrace;

/* func: findTaskLog
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
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

  -- Динамически формируемый текст запроса
  dsql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  t.*
from (
  select
    t.task_log_id
    , t.task_id
    , t.start_number
    , t.line_number
    , t.level_code
    , lv.level_description as level_name
    , t.message_text
    , t.date_ins
  from
    tp_task_log t
    inner join lg_level lv
      on lv.level_code = t.level_code
  where
    $(condition)
  order by
    t.task_log_id
  ) t
where
  $(rownumCondition)
'
  );

begin
  dsql.addCondition(
    't.task_log_id =', taskLogId is null
  );
  dsql.addCondition(
    't.task_id =', taskId is null
  );
  dsql.addCondition(
    't.start_number =', startNumber is null
  );
  dsql.addCondition(
    't.line_number =', lineNumber is null
  );
  dsql.addCondition(
    't.level_code =', levelCode is null
  );
  dsql.addCondition(
    'upper( t.message_text) like upper( :messageText)', messageText is null
  );
  dsql.addCondition(
    't.task_log_id >= :startTaskLogId', startTaskLogId is null
  );
  dsql.useCondition( 'condition');
  dsql.addCondition(
    'rownum <= :maxRowCount', maxRowCount is null
  );
  dsql.useCondition( 'rownumCondition');
  open rc for
    dsql.getSqlText()
  using
    taskLogId
    , taskId
    , startNumber
    , lineNumber
    , levelCode
    , messageText
    , startTaskLogId
    , maxRowCount
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при поиске лога выполнения задания. ('
        || ' taskLogId=' || to_char( taskLogId )
        || ', taskId=' || to_char( taskId )
        || ', startNumber=' || to_char( startNumber )
        || ', lineNumber=' || to_char( lineNumber )
        || ', levelCode="' || levelCode || '"'
        || ', messageText="' || messageText || '"'
        || ', startTaskLogId=' || to_char( startTaskLogId )
        || ', maxRowCount=' || to_char( maxRowCount )
        || ', operatorId=' || to_char( operatorId )
        || ').'
      )
    , true
  );
end findTaskLog;



/* group: Справочники */

/* func: getLevel
  Возвращает список уровней сообщений лога.

  Возврат ( курсор):
  level_code                  - код уровня сообщения
  level_name                  - название уровня сообщения

  Замечания:
  - возвращаемые записи отсортированы по полю level_code;
*/
function getLevel
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

begin
  open rc for
    select
      t.level_code
      , t.level_description as level_name
    from
      lg_level t
    where
      t.level_code not in (
        pkg_Logging.All_LevelCode
        , pkg_Logging.Off_LevelCode
      )
    order by
      t.level_code
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при возврате списка уровней сообщений лога.'
      )
    , true
  );
end getLevel;

/* func: getResult
  Возвращает возможные результаты выполнения заданий.

  Возврат ( курсор):
  result_code             - код результата выполнения
  result_name             - название результата выполнения

  Замечания:
  - возвращаемые записи отсортированы по result_code;
*/
function getResult
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

begin
  open rc for
    select
      t.result_code
      , t.result_name_rus as result_name
    from
      tp_result t
    order by
      t.result_code
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при выборке возможных результатов выполнения заданий.'
      )
    , true
  );
end getResult;

end pkg_TaskProcessor;
/
