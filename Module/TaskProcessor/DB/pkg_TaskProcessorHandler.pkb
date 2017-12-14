create or replace package body pkg_TaskProcessorHandler is
/* package body: pkg_TaskProcessorHandler::body */



/* group: Константы */

/* iconst: CheckCommand_Timeout
  Таймаут между проверками наличия команд для обработки.
*/
CheckCommand_Timeout constant interval day to second := interval '1' second;

/* iconst: CheckTask_Timeout
  Таймаут между проверками наличия заданий для обработки.
*/
CheckTask_Timeout constant interval day to second := interval '5' second;

/* iconst: TaskHandler_ProcessName
  Название процесса для обработчика заданий.
*/
TaskHandler_ProcessName constant varchar2(48) := 'TaskHandler';

/* iconst: Idle_Action
  Название действия, устанавливаемое при бездействии.
*/
Idle_Action constant varchar2(32) := 'idle';

/* iconst: ProcessCommand_Action
  Название действия, устанавливаемое при выполнении команды.
*/
ProcessCommand_Action constant varchar2(32) := 'process command';

/* iconst: ExecTask_Action
  Название действия, устанавливаемое при выполнении задания.
*/
ExecTask_Action constant varchar2(32) := 'exec task';

/* iconst: FixAbortedTask_Action
  Название действия, устанавливаемое при исправлении состояния задания,
  выполнение которого было прервано.
*/
FixAbortedTask_Action constant varchar2(32) := 'fix aborted task';



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_TaskProcessorBase.Module_Name
  , objectName  => 'pkg_TaskProcessorHandler'
);

/* ivar: currentTaskId
  Id задания, выполняемого в сессии в данный момент.
*/
currentTaskId tp_task.task_id%type;

/* ivar: currentStartNumber
  Номер запуска задания, выполняемого в сессии в данный момент.
*/
currentStartNumber tp_task.start_number%type;



/* group: Функции */

/* func: getExecCommandText
  Функция возвращает PL/SQL код для выполнения

  Параметры:
  execCommand                 - команда выполнения задачи
  isProcessFile               - признак загрузки файла
  isOnlyParse                 - признак проверки корректности кода задания,
                                при этом код не выполняется
                                ( по умолчанию false)
*/
function getExecCommandText(
  execCommand                 varchar2
, isProcessFile               boolean
, isOnlyParse                 boolean := null
)
return varchar2
is

  /*
    Добавляет текст, если предназначено для выполнения
  */
  function addIfExec(
    addedText varchar2
  )
  return varchar2
  is
  begin
    if not coalesce( isOnlyParse, false) then
      return addedText;
    else
      return '';
    end if;
  end addIfExec;

-- getExecCommandText
begin
  return '
declare
  taskId tp_task.task_id%type' || addIfExec( ' := :taskId') || ';
  manageOperatorId tp_task.manage_operator_id%type'
    || addIfExec( ' := :manageOperatorId') || ';
  startNumber tp_task.start_number%type' || addIfExec( ' := :startNumber') || ';
  startDate tp_task.start_date%type' || addIfExec( ' := :startDate') || ';
  nextStartDate tp_task.next_start_date%type := null;
  resultCode tp_task.result_code%type := pkg_TaskProcessorBase.True_ResultCode;
  execResult tp_task.exec_result%type := null;
  errorCode tp_task.error_code%type := null;
  errorMessage tp_task.error_message%type := null;'
  || case when isProcessFile then
'
  fileName tp_file.file_name%type' || addIfExec( ' := :fileName') || ';
  fileData tp_file.file_data%type' || addIfExec( ' := :fileData') || ';'
    end
  || '
begin'
  -- Обеспечиваем постоянное число и порядок bind-переменных
  || case when not isProcessFile and not coalesce( isOnlyParse, false) then
'
  if :fileName is null and :fileData is null then null; end if;'
    end
  || '
' || execCommand || '
' || addIfExec(
'  :nextStartDate := nextStartDate;
  :resultCode := resultCode;
  :execResult := execResult;
  :errorCode := errorCode;
  :errorMessage := errorMessage;'
  ) || '
end;'
     ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при формировании команды.('
        || 'execCommand="' || execCommand || '"'
        || ')'
      )
    , true
  );
end getExecCommandText;

/* proc: checkExecCommandParsed
  Процедура проверки корректности выполняемого PL/SQL кода

  Параметры:
  execCommand                 - текст выполнения задания
  isProcessFile               - признак загрузки файла
*/
procedure checkExecCommandParsed(
  execCommand                 varchar2
, isProcessFile               boolean
)
is
  cur number;

-- checkExecCommandParsed
begin
  cur := dbms_sql.open_cursor();
  dbms_sql.parse(
    cur
  , getExecCommandText(
      execCommand => execCommand
    , isProcessFile => isProcessFile
    , isOnlyParse => true
    )
  , dbms_sql.native
  );
  dbms_sql.close_cursor( cur);
exception when others then
  dbms_sql.close_cursor( cur);
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка проверки корректности выполняемой задачи.'
      )
    , true
  );
end checkExecCommandParsed;

/* func: taskHandler
  Обработчик заданий.
  Выполняет задания, находящиеся в очереди, а также переводит в корректное
  состояние задания, выполнение которых было прервано.

  Задания выполняются с помощью динамического вызова в PL/SQL-блоке команды,
  соответствующей типу задания ( из поля exec_command таблицы <tp_task_type>).

  Переменные, доступные вызываемой команде:
  taskId                      - Id задания
  manageOperatorId            - Id оператора, поставившего задание на выполнение
  nextStartDate               - дата следующего запуска ( модификация, по
                                по умолчанию null)
  startNumber                 - порядковый номер запуска, начиная с 1
                                ( автоматически увеличивается при каждой
                                попытке запуска задания)
  startDate                   - дата запуска
  fileName                    - имя обрабатываемого файла
                                ( только для заданий обработки файла)
  fileData                    - данные обрабатываемого файла ( тип CLOB)
                                ( только для заданий обработки файла)
  resultCode                  - код результата ( модификация, по умолчанию
                                <pkg_TaskProcessorBase.True_ResultCode>)
  execResult                  - результат выполнения ( модификация, по умолчанию
                                null)
  errorCode                   - код ошибки ( модификация, по умолчанию null)
  errorMessage                - текст ошибки ( модификация, по умолчанию null)

  Если задание было выполнено без исключения, то после выполнения задания
  значения переменных, допускающих модификацию, сохраняются в соответствующих
  полях таблицы <tp_task> и выполняется commit.

  В случае, если после выполнения задания переменная nextStartDate имеет не
  null значение, задание снова попадает в очередь на выполнение, в противном
  случае оно переводится в бездействующие.

  В случае, если при выполнении задания возникло исключение, выполняется
  rollback, устанавливается код результата
  <pkg_TaskProcessorBase.Error_ResultCode>, сохраняются код и сообщение об
  ошибке и задание переводится в бездействующие ( в случае исключения из-за
  инвалидации объектов задание ставится на повторное выполнение, см. замечание
  ниже).

  В случае, если обнаружено задание, обработка которого была прервана,
  устанавливается код результата <pkg_TaskProcessorBase.Abort_ResultCode> и
  задание переводится в бездействующие.

  Параметры:
  isFinishAfterProcess        - флаг завершения обработки после выполнения
                                ( с любым результатом) одного задания либо
                                нескольких идущих подряд заданий одного типа
                                ( 1 завершить, 0 не завершать ( по умолчанию))
  forceTaskTypeIdList         - список идентификаторов типов заданий
                                на выполнение через ";"
                                ( по умолчанию нет ограничений)
  ignoreTaskTypeIdList        - список идентификаторов типов заданий,
                                которые не будут выполняться, через ";"
                                ( по умолчанию нет ограничений)

  Возврат:
  - число обработанных заданий

  Замечания:
  - параметр isFinishAfterProcess предназначен для решения проблемы с
    сохранением фиктивных блокировок прикладных объектов в сессии
    обработчика ( см. <Ошибки>);
  - в случае, если при выполнении задания возникает исключение из-за
    инвалидации объектов, например
    "ORA-04061: existing state of package <packageName>  has been invalidated",
    то задание ставится на повторное выполнение, а функция обработки заданий
    завершается с исключением, т.к. повторное выполнение задания в новой
    сессии может завершиться успешно;
  - предполагается заполнение одного из параметров forceTaskTypeIdList
    или ignoreTaskTypeIdList
*/
function taskHandler(
  isFinishAfterProcess integer := null
, forceTaskTypeIdList varchar2 := null
, ignoreTaskTypeIdList varchar2 := null
)
return integer
is

  -- Максимальное число одновременно выполняемых заданий одного типа от одного
  -- оператора ( по умолчанию без ограничений)
  maxOpTypeTaskExecCount integer;

  -- Число обработанных заданий
  nProcessedTask integer := 0;

  -- Флаг завершения работы
  isFinish boolean := false;

  -- Id типа задания, после завершения обработки идущих подряд заданий по
  -- которому функция завершается ( используется для isFinishAfterProcess)
  finishTaskTypeId tp_task.task_type_id%type := null;

  -- SID и serial# сессии обработчика
  handlerSid number;
  handlerSerial number;

  -- Id текущего оператора, с правами которого выполняется сам обработчик
  handlerOperatorId integer;

  -- Интервал проверки поступления команды ( в секундах)
  checkCommandTimeout number;

  -- Время последней проверки команд
  lastCommandCheck number;

  -- Интервал проверки изменений в таблице заданий ( в секундах)
  checkTaskTimeout number;

  -- Время последней проверки изменений в таблице заданий
  lastTaskCheck number;

  -- Имя текущей команды
  command varchar2(50) := null;

  -- Признак необходимости обработки задания
  isProcessTask boolean := false;

  -- Задание для обработки
  task tp_task%rowtype;



  -- Выполняем подготовительные действия.
  procedure initialize is
  begin

    -- Инициализируем обработчик
    pkg_TaskHandler.InitHandler(
      moduleName                  => pkg_TaskProcessorBase.Module_Name
      , processName               => TaskHandler_ProcessName
    );

    -- Определяем таймауты
    checkCommandTimeout :=
      pkg_TaskHandler.toSecond( CheckCommand_Timeout);
    checkTaskTimeout :=
      pkg_TaskHandler.toSecond( CheckTask_Timeout);

    -- Сохраняем идентификаторы сессии
    handlerSid          := pkg_Common.getSessionSid();
    handlerSerial       := pkg_Common.getSessionSerial();
    handlerOperatorId   := pkg_Operator.getCurrentUserId();

    -- Получаем значения параметров
    maxOpTypeTaskExecCount := opt_option_list_t(
      moduleName => pkg_TaskProcessorBase.Module_Name
    ).getNumber(
      optionShortName => pkg_TaskProcessorBase.MaxOpTpTaskExec_OptionSName
    );
  end initialize;



  -- Выполняет очистку перед завершением работы.
  procedure clean is
  begin
    pkg_TaskHandler.cleanHandler;
  exception when others then            --Игнорируем любые исключения
    null;
  end clean;



  -- Проверка наличия заданий для обработки.
  function checkTaskForProcess
  return boolean
  is

    -- Активные задания для обработки
    cursor curActiveTask is
      select /*+ first_rows */
        case when a.sid is not null then 1 end
          as fix_task_flag
        , a.*
      from
        (
        select
          count( ts.sid)
            over( partition by ts.manage_operator_id)
            as exec_operator_count
          , count( ts.sid)
            over( partition by ts.task_type_id)
            as exec_task_type_count
          , count( ts.sid)
            over( partition by ts.manage_operator_id, ts.task_type_id)
            as exec_operator_task_type_count
          , ts.*
        from
          v_tp_active_task ts
        where
          -- наступило время обработки
          ts.start_order_date <= sysdate
        ) a
      where
        -- задание не выполняется и его можно выполнять
        (
        a.sid is null
          and (
            maxOpTypeTaskExecCount is null
            or a.exec_operator_task_type_count < maxOpTypeTaskExecCount
          )
        -- выполнение задания было прервано
        or a.sid is not null
          and not exists
            (
            select
              null
            from
              v$session ss
            where
              ss.sid = a.sid
              and ss.serial# = a.serial#
            )
        )
        -- ограничение по типам заданий
        and (
            forceTaskTypeIdList is null
            or
            exists (
               select
                1
              from
                table( pkg_Common.split( forceTaskTypeIdList, ';'))
              where
                trim( column_value) = a.task_type_id
              )
            )
        and (
            ignoreTaskTypeIdList is null
            or
            not exists (
               select
                1
              from
                table( pkg_Common.split( ignoreTaskTypeIdList, ';'))
              where
                trim( column_value) = a.task_type_id
              )
            )
      order by
        -- в первую очередь корректируем состояние прерванных заданий
        fix_task_flag nulls last
        , a.exec_operator_count
        , a.exec_task_type_count
        , a.start_order_date
        , a.task_id
    ;

    -- Наличие задания для обработки
    isFound boolean;



    -- Блокирует задание для обработки.
    function lockTask(
      taskId integer
      , taskStatusCode varchar2
      , absentSid number
      , absentSerial# number
    )
    return boolean
    is
    begin
      select
        ts.*
      into task
      from
        tp_task ts
      where
        ts.task_id = taskId
        and ts.task_status_code = taskStatusCode
        and nullif( absentSid, ts.sid) is null
        and nullif( absentSerial#, ts.serial#) is null
      for update nowait;
      return true;
    exception
      when NO_DATA_FOUND then
        return false;
      when others then
        if SQLCODE = pkg_Error.ResourceBusyNowait then
          return false;
        else
          raise_application_error(
            pkg_Error.ErrorStackInfo
            , logger.errorStack(
                'Ошибка при блокировке задания ('
                || ' taskId=' || to_char( taskId)
                || ', taskStatusCode="' || taskStatusCode || '"'
                || ', absentSid=' || to_char( absentSid)
                || ', absentSerial#=' || to_char( absentSerial#)
                || ').'
              )
            , true
          );
        end if;
    end lockTask;



  --checkTaskForProcess
  begin
    logger.trace( 'check new request');
    for rec in curActiveTask loop
      if nullif( finishTaskTypeId, rec.task_type_id) is null then
        isFound := lockTask(
          taskId            => rec.task_id
          , taskStatusCode  => rec.task_status_code
          , absentSid       => rec.sid
          , absentSerial#   => rec.serial#
        );
        exit when isFound;
      else
        isFound := false;
        exit;
      end if;
    end loop;
    return isFound;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке наличия заданий для обработки.'
        )
      , true
    );
  end checkTaskForProcess;



  -- Ожидает наступление какого-либо события.
  procedure waitEvent
  is

    -- Текущее время
    currentTime number;

    -- Время ожидания (в 100-x секунды)
    waitTimeout number;

  --waitEvent
  begin

    -- Устанавливаем информацию о состоянии
    logger.trace( 'start idle event');
    pkg_TaskHandler.setAction( Idle_Action);
    loop

      -- Определяем таймаут ожидания
      currentTime := pkg_TaskHandler.getTime();
      waitTimeout := greatest(
        checkTaskTimeout
          - pkg_TaskHandler.timeDiff( currentTime, lastTaskCheck)
      );

      -- Проверка поступления команды
      if waitTimeout > 0
          or pkg_TaskHandler.NextTime( lastCommandCheck, checkCommandTimeout)
          then
        logger.trace( 'get command: waitTimeout=' || waitTimeout);
        if pkg_TaskHandler.getCommand( command, waitTimeout) then
          lastCommandCheck := null;
          exit;
        else
          lastCommandCheck := pkg_TaskHandler.getTime();
        end if;
      end if;

      -- Проверка изменений в таблице заданий
      if pkg_TaskHandler.NextTime( lastTaskCheck, checkTaskTimeout) then
        if checkTaskForProcess then
          isProcessTask := true;
          lastTaskCheck := null;
          exit;
        elsif finishTaskTypeId is not null then
          isFinish := true;
          logger.trace( 'waitEvent: set isFinish by finishTaskTypeId');
          exit;
        end if;
      end if;
    end loop;
  end waitEvent;



  -- Устанавливает состояние задания и обновляет поля в переменной task.
  -- Выполняет commit.
  procedure setTaskStatus(
    taskStatusCode varchar2
    , nextStartDate date
    , sid number
    , serial number
    , startNumber integer
    , startDate date
    , finishDate date
    , resultCode varchar2
    , execResult integer
    , errorCode integer
    , errorMessage varchar2
  )
  is
  begin
    logger.trace( 'setTaskStatus: taskStatusCode=' || taskStatusCode);

    -- Обновляем в переменной
    task.task_status_code         := taskStatusCode;
    task.next_start_date          := nextStartDate;
    task.sid                      := setTaskStatus.sid;
    task.serial#                  := setTaskStatus.serial;
    task.start_number             := startNumber;
    task.start_date               := startDate;
    task.finish_date              := finishDate;
    task.result_code              := resultCode;
    task.exec_result              := execResult;
    task.error_code               := errorCode;
    task.error_message            := errorMessage;

    -- Обновляем в таблице
    update
      tp_task ts
    set
      ts.task_status_code         = task.task_status_code
      , ts.next_start_date        = task.next_start_date
      , ts.sid                    = task.sid
      , ts.serial#                = task.serial#
      , ts.start_number           = task.start_number
      , ts.start_date             = task.start_date
      , ts.finish_date            = task.finish_date
      , ts.result_code            = task.result_code
      , ts.exec_result            = task.exec_result
      , ts.error_code             = task.error_code
      , ts.error_message          = task.error_message
    where
      ts.task_id = task.task_id
    ;
    commit;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при обновлении состояния задания ('
          || ' task_id=' || to_char( task.task_id)
          || ', taskStatusCode="' || taskStatusCode
          || ').'
        )
      , true
    );
  end setTaskStatus;



  procedure getTaskType(
    taskType in out nocopy tp_task_type%rowtype
    , taskTypeId integer
  )
  is
  begin
    logger.trace( 'getTaskType: task_type_id=' || to_char( taskTypeId));
    select
      tt.*
    into taskType
    from
      tp_task_type tt
    where
      tt.task_type_id = taskTypeId
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при получении параметров типа задания ('
          || ' taskTypeId=' || to_char( taskTypeId)
          || ').'
        )
      , true
    );
  end getTaskType;



  /*
    Выполняет задание.
  */
  procedure runTask(
    execCommand varchar2
    , isProcessFile boolean
  )
  is

    -- Признак успешной установки состояния файла "Обработка данных..."
    isSetFileProcessing boolean := false;

    -- Имя обрабатываемого файла
    fileName tp_file.file_name%type;

    -- Данные обрабатываемого файла
    fileData tp_file.file_data%type;



    procedure setTaskOperator
    is
    begin
      pkg_Operator.setCurrentUserId( operatorId => task.manage_operator_id);
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при установке оператора перед выполнением задания ('
            || ' manage_operator_id=' || to_char( task.manage_operator_id)
            || ').'
          )
        , true
      );
    end setTaskOperator;



    /*
      Устанавливает состояние обрабатываемого файла.
    */
    procedure setFileStatus(
      fileStatusCode varchar2
    )
    is

      -- Текущее состояние файла
      oldFileStatusCode tp_file.file_status_code%type;


    begin
      select
        t.file_status_code
      into oldFileStatusCode
      from
        tp_file t
      where
        t.task_id = task.task_id
      for update nowait;

      if fileStatusCode = pkg_TaskProcessorBase.Processing_FileStatusCode
            and oldFileStatusCode = pkg_TaskProcessorBase.Loading_FileStatusCode
          then
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Не завершена загрузка данных файла.'
        );
      end if;

      update
        tp_file t
      set
        t.file_status_code = fileStatusCode
      where
        t.task_id = task.task_id
      ;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при установке состояния файла ('
            || ' fileStatusCode="' || fileStatusCode || '"'
            || ').'
          )
        , true
      );
    end setFileStatus;



    /*
      Получает файл для обработки.
    */
    procedure getFile
    is
    begin
      select
        t.file_name
        , t.file_data
      into fileName, fileData
      from
        tp_file t
      where
        t.task_id = task.task_id
      ;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка при получении файла для обработки.'
          )
        , true
      );
    end getFile;



  -- runTask
  begin
    logger.trace( 'runTask: start');
    currentTaskId := task.task_id;
    currentStartNumber := task.start_number;

    begin
      setTaskOperator();
      if isProcessFile then
        setFileStatus( pkg_TaskProcessorBase.Processing_FileStatusCode);
        commit;
        isSetFileProcessing := true;
        getFile();
      end if;
      logMessage(
        pkg_Logging.Info_LevelCode
        , case when not isProcessFile then
            'Начало выполнения задания.'
          else
            'Начало выполнения задания по обработке файла'
            || ' "' || fileName || '" ('
            || ' размер файла: '
            || dbms_lob.getlength( fileData)
            || ').'
          end
      );
      task.result_code := pkg_TaskProcessorBase.True_ResultCode;
      execute immediate
        getExecCommandText(
          execCommand => execCommand
        , isProcessFile => isProcessFile
        )
      using
        in task.task_id
        , in task.manage_operator_id
        , in task.start_number
        , in task.start_date
        , in fileName
        , in fileData
        , out task.next_start_date
        , out task.result_code
        , out task.exec_result
        , out task.error_code
        , out task.error_message
      ;
      logger.trace( 'runTask: finished');
    exception when others then
      rollback;
      logger.trace( 'runTask: error');
      task.next_start_date := null;
      task.result_code     := pkg_TaskProcessorBase.Error_ResultCode;
      task.exec_result     := null;
      task.error_code      := SQLCODE;
      task.error_message   := substr( pkg_Logging.getErrorStack(), 1, 4000);
    end;

    if isSetFileProcessing then
      setFileStatus( pkg_TaskProcessorBase.Processed_FileStatusCode);
    end if;

    if task.result_code = pkg_TaskProcessorBase.Error_ResultCode then
      logMessage(
        pkg_Logging.Error_LevelCode
        , 'Выполнение задания завершено с ошибкой:'
          || chr(10) || task.error_message
      );
    else
      logMessage(
        pkg_Logging.Info_LevelCode
        , 'Выполнение задания завершено ('
          || ' resultCode="' || task.result_code || '"'
          || ', execResult=' || task.exec_result
          || ').'
      );
    end if;

    -- Восстанавливаем текущего оператора
    pkg_Operator.setCurrentUserId( operatorId => handlerOperatorId);

    currentTaskId := null;
    currentStartNumber := null;
  end runTask;



  -- Выполняет задание.
  procedure ExecTask
  is

    -- Параметры типа задания
    taskType tp_task_type%rowtype;

    -- Признак ошибки из-за инвалидации объектов, в случае которой возможно
    -- успешное выполнение задания в другой сессии
    isInvalidateError boolean;

  --ExecTask
  begin
    logger.trace( 'ExecTask: start');
    pkg_TaskHandler.setAction(
      action        => ExecTask_Action
      , actionInfo  => to_char( task.task_id)
    );
    getTaskType( taskType, task.task_type_id);

    -- Устанавливаем состояние выполнения
    setTaskStatus(
      taskStatusCode          => pkg_TaskProcessorBase.Running_TaskStatusCode
      , nextStartDate         => null
      , sid                   => handlerSid
      , serial                => handlerSerial
      , startNumber           => coalesce( task.start_number, 0) + 1
      , startDate             => sysdate
      , finishDate            => null
      , resultCode            => null
      , execResult            => null
      , errorCode             => null
      , errorMessage          => null
    );

    -- Запускаем задание на выполнение
    runTask(
      execCommand             => taskType.exec_command
      , isProcessFile         => taskType.file_name_pattern is not null
    );

    -- Сохраняем результат выполнения
    isInvalidateError := task.error_code in (
      -4061, -4062, -4063, -4064, -4065, -4066, -4067, -4068
    );
    if  isInvalidateError then
      task.task_status_code := pkg_TaskProcessorBase.Queued_TaskStatusCode;
      task.next_start_date  := sysdate;
    else
      task.task_status_code :=
        case when task.next_start_date is null then
          pkg_TaskProcessorBase.Idle_TaskStatusCode
        else
          pkg_TaskProcessorBase.Queued_TaskStatusCode
        end
      ;
    end if;
    setTaskStatus(
      taskStatusCode          => task.task_status_code
      , nextStartDate         => task.next_start_date
      , sid                   => null
      , serial                => null
      , startNumber           => task.start_number
      , startDate             => task.start_date
      , finishDate            => sysdate
      , resultCode            => task.result_code
      , execResult            => task.exec_result
      , errorCode             => task.error_code
      , errorMessage          => task.error_message
    );

    if isInvalidateError then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Ошибка из-за инвалидации объектов,'
          || ' необходим запуск обработки заданий в другой сессии.'
          || chr(10) || task.error_message
      );
    end if;

    nProcessedTask := nProcessedTask + 1;
    if finishTaskTypeId is null and isFinishAfterProcess = 1 then
      finishTaskTypeId := task.task_type_id;
      logger.trace(
        'ExecTask: set finishTaskTypeId=' || to_char( finishTaskTypeId)
      );
    end if;
  end ExecTask;



  -- Исправляет состояние задания, выполнение которого было прервано.
  procedure fixAbortedTask
  is
  begin
    logger.trace( 'fixAbortedTask: start');
    pkg_TaskHandler.setAction(
      action        => FixAbortedTask_Action
      , actionInfo  => to_char( task.task_id)
    );
    setTaskStatus(
      taskStatusCode          => pkg_TaskProcessorBase.Idle_TaskStatusCode
      , nextStartDate         => null
      , sid                   => null
      , serial                => null
      , startNumber           => task.start_number
      , startDate             => task.start_date
      , finishDate            => sysdate
      , resultCode            => pkg_TaskProcessorBase.Abort_ResultCode
      , execResult            => null
      , errorCode             => null
      , errorMessage          => null
    );
  end fixAbortedTask;



  -- Обработка задания.
  procedure processTask
  is
  begin
    logger.trace( 'process request: task_id=' || task.task_id);
    if task.task_status_code = pkg_TaskProcessorBase.Queued_TaskStatusCode then
      ExecTask;
    elsif task.sid is not null then
      fixAbortedTask;
    else
      raise_application_error(
        pkg_Error.ProcessError
        , 'Неизвестен способ обработки задания ('
          || ' task_id=' || to_char( task.task_id)
          || ', task_status_code="' || task.task_status_code || '"'
          || ').'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при обработке задания.'
        )
      , true
    );
  end processTask;



  --Выполняет команду управления обработчиком.
  procedure processCommand
  is
  begin
    logger.trace( 'process command: ' || command);
    pkg_TaskHandler.setAction(
      action        => ProcessCommand_Action
      , actionInfo  => command
    );
    case command
      when pkg_TaskHandler.Stop_Command then
        isFinish := true;
      else
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Получена неизвестная управляющая команда "' || command || '".'
        );
    end case;
  end processCommand;



  -- Обрабатывает событие.
  procedure processEvent
  is
  begin
    case
      when command is not null then
        processCommand;
        command := null;
      when isProcessTask then
        processTask;
        isProcessTask := false;
      else
        raise_application_error(
          pkg_Error.ProcessError
          , 'Получено неизвестное событие внутри цикла обработки.'
        );
    end case;
  end processEvent;



--taskHandler
begin
  initialize();
  loop
    waitEvent();
    if not isFinish then
      processEvent();
    end if;
    exit when isFinish;
  end loop;
  clean();
  return nProcessedTask;
exception when others then
  clean();
  raise;
end taskHandler;

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
  - функция выполняется в автономной транзакции;
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
)
is

  pragma autonomous_transaction;

begin
  if currentTaskId is null then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Отсутствует выполняемое задание.'
    );
  end if;

  insert into
    tp_task_log
  (
    task_id
    , start_number
    , line_number
    , level_code
    , message_text
    , operator_id
  )
  values
  (
    currentTaskId
    , currentStartNumber
    , coalesce( lineNumber, 0)
    , levelCode
    , messageText
    , operatorId
  );
  commit;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при записи в лог сообщения ('
        || ' levelCode="' || levelCode || '"'
        || ', lineNumber=' || lineNumber
        || ', operatorId=' || operatorId
        || ', messageText="' || chr(10) || messageText || chr(10) || '"'
        || ').'
      )
    , true
  );
end logMessage;

end pkg_TaskProcessorHandler;
/
