create or replace package body pkg_TaskProcessorHandler is
/* package body: pkg_TaskProcessorHandler::body */



/* group: ��������� */

/* iconst: CheckCommand_Timeout
  ������� ����� ���������� ������� ������ ��� ���������.
*/
CheckCommand_Timeout constant interval day to second := interval '1' second;

/* iconst: CheckTask_Timeout
  ������� ����� ���������� ������� ������� ��� ���������.
*/
CheckTask_Timeout constant interval day to second := interval '5' second;

/* iconst: TaskHandler_ProcessName
  �������� �������� ��� ����������� �������.
*/
TaskHandler_ProcessName constant varchar2(48) := 'TaskHandler';

/* iconst: Idle_Action
  �������� ��������, ��������������� ��� �����������.
*/
Idle_Action constant varchar2(32) := 'idle';

/* iconst: ProcessCommand_Action
  �������� ��������, ��������������� ��� ���������� �������.
*/
ProcessCommand_Action constant varchar2(32) := 'process command';

/* iconst: ExecTask_Action
  �������� ��������, ��������������� ��� ���������� �������.
*/
ExecTask_Action constant varchar2(32) := 'exec task';

/* iconst: FixAbortedTask_Action
  �������� ��������, ��������������� ��� ����������� ��������� �������,
  ���������� �������� ���� ��������.
*/
FixAbortedTask_Action constant varchar2(32) := 'fix aborted task';



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_TaskProcessorBase.Module_Name
  , objectName  => 'pkg_TaskProcessorHandler'
);

/* ivar: currentTaskId
  Id �������, ������������ � ������ � ������ ������.
*/
currentTaskId tp_task.task_id%type;

/* ivar: currentStartNumber
  ����� ������� �������, ������������ � ������ � ������ ������.
*/
currentStartNumber tp_task.start_number%type;



/* group: ������� */

/* func: getExecCommandText
  ������� ���������� PL/SQL ��� ��� ����������

  ���������:
  execCommand                 - ������� ���������� ������
  isProcessFile               - ������� �������� �����
  isOnlyParse                 - ������� �������� ������������ ���� �������,
                                ��� ���� ��� �� �����������
                                ( �� ��������� false)
*/
function getExecCommandText(
  execCommand                 varchar2
, isProcessFile               boolean
, isOnlyParse                 boolean := null
)
return varchar2
is

  /*
    ��������� �����, ���� ������������� ��� ����������
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
  -- ������������ ���������� ����� � ������� bind-����������
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
        '������ ��� ������������ �������.('
        || 'execCommand="' || execCommand || '"'
        || ')'
      )
    , true
  );
end getExecCommandText;

/* proc: checkExecCommandParsed
  ��������� �������� ������������ ������������ PL/SQL ����

  ���������:
  execCommand                 - ����� ���������� �������
  isProcessFile               - ������� �������� �����
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
        '������ �������� ������������ ����������� ������.'
      )
    , true
  );
end checkExecCommandParsed;

/* func: taskHandler
  ���������� �������.
  ��������� �������, ����������� � �������, � ����� ��������� � ����������
  ��������� �������, ���������� ������� ���� ��������.

  ������� ����������� � ������� ������������� ������ � PL/SQL-����� �������,
  ��������������� ���� ������� ( �� ���� exec_command ������� <tp_task_type>).

  ����������, ��������� ���������� �������:
  taskId                      - Id �������
  manageOperatorId            - Id ���������, ������������ ������� �� ����������
  nextStartDate               - ���� ���������� ������� ( �����������, ��
                                �� ��������� null)
  startNumber                 - ���������� ����� �������, ������� � 1
                                ( ������������� ������������� ��� ������
                                ������� ������� �������)
  startDate                   - ���� �������
  fileName                    - ��� ��������������� �����
                                ( ������ ��� ������� ��������� �����)
  fileData                    - ������ ��������������� ����� ( ��� CLOB)
                                ( ������ ��� ������� ��������� �����)
  resultCode                  - ��� ���������� ( �����������, �� ���������
                                <pkg_TaskProcessorBase.True_ResultCode>)
  execResult                  - ��������� ���������� ( �����������, �� ���������
                                null)
  errorCode                   - ��� ������ ( �����������, �� ��������� null)
  errorMessage                - ����� ������ ( �����������, �� ��������� null)

  ���� ������� ���� ��������� ��� ����������, �� ����� ���������� �������
  �������� ����������, ����������� �����������, ����������� � ���������������
  ����� ������� <tp_task> � ����������� commit.

  � ������, ���� ����� ���������� ������� ���������� nextStartDate ����� ��
  null ��������, ������� ����� �������� � ������� �� ����������, � ���������
  ������ ��� ����������� � ��������������.

  � ������, ���� ��� ���������� ������� �������� ����������, �����������
  rollback, ��������������� ��� ����������
  <pkg_TaskProcessorBase.Error_ResultCode>, ����������� ��� � ��������� ��
  ������ � ������� ����������� � �������������� ( � ������ ���������� ��-��
  ����������� �������� ������� �������� �� ��������� ����������, ��. ���������
  ����).

  � ������, ���� ���������� �������, ��������� �������� ���� ��������,
  ��������������� ��� ���������� <pkg_TaskProcessorBase.Abort_ResultCode> �
  ������� ����������� � ��������������.

  ���������:
  isFinishAfterProcess        - ���� ���������� ��������� ����� ����������
                                ( � ����� �����������) ������ ������� ����
                                ���������� ������ ������ ������� ������ ����
                                ( 1 ���������, 0 �� ��������� ( �� ���������))
  forceTaskTypeIdList         - ������ ��������������� ����� �������
                                �� ���������� ����� ";"
                                ( �� ��������� ��� �����������)
  ignoreTaskTypeIdList        - ������ ��������������� ����� �������,
                                ������� �� ����� �����������, ����� ";"
                                ( �� ��������� ��� �����������)

  �������:
  - ����� ������������ �������

  ���������:
  - �������� isFinishAfterProcess ������������ ��� ������� �������� �
    ����������� ��������� ���������� ���������� �������� � ������
    ����������� ( ��. <������>);
  - � ������, ���� ��� ���������� ������� ��������� ���������� ��-��
    ����������� ��������, ��������
    "ORA-04061: existing state of package <packageName>  has been invalidated",
    �� ������� �������� �� ��������� ����������, � ������� ��������� �������
    ����������� � �����������, �.�. ��������� ���������� ������� � �����
    ������ ����� ����������� �������;
  - �������������� ���������� ������ �� ���������� forceTaskTypeIdList
    ��� ignoreTaskTypeIdList
*/
function taskHandler(
  isFinishAfterProcess integer := null
, forceTaskTypeIdList varchar2 := null
, ignoreTaskTypeIdList varchar2 := null
)
return integer
is

  -- ������������ ����� ������������ ����������� ������� ������ ���� �� ������
  -- ��������� ( �� ��������� ��� �����������)
  maxOpTypeTaskExecCount integer;

  -- ����� ������������ �������
  nProcessedTask integer := 0;

  -- ���� ���������� ������
  isFinish boolean := false;

  -- Id ���� �������, ����� ���������� ��������� ������ ������ ������� ��
  -- �������� ������� ����������� ( ������������ ��� isFinishAfterProcess)
  finishTaskTypeId tp_task.task_type_id%type := null;

  -- SID � serial# ������ �����������
  handlerSid number;
  handlerSerial number;

  -- Id �������� ���������, � ������� �������� ����������� ��� ����������
  handlerOperatorId integer;

  -- �������� �������� ����������� ������� ( � ��������)
  checkCommandTimeout number;

  -- ����� ��������� �������� ������
  lastCommandCheck number;

  -- �������� �������� ��������� � ������� ������� ( � ��������)
  checkTaskTimeout number;

  -- ����� ��������� �������� ��������� � ������� �������
  lastTaskCheck number;

  -- ��� ������� �������
  command varchar2(50) := null;

  -- ������� ������������� ��������� �������
  isProcessTask boolean := false;

  -- ������� ��� ���������
  task tp_task%rowtype;



  -- ��������� ���������������� ��������.
  procedure initialize is
  begin

    -- �������������� ����������
    pkg_TaskHandler.InitHandler(
      moduleName                  => pkg_TaskProcessorBase.Module_Name
      , processName               => TaskHandler_ProcessName
    );

    -- ���������� ��������
    checkCommandTimeout :=
      pkg_TaskHandler.toSecond( CheckCommand_Timeout);
    checkTaskTimeout :=
      pkg_TaskHandler.toSecond( CheckTask_Timeout);

    -- ��������� �������������� ������
    handlerSid          := pkg_Common.getSessionSid();
    handlerSerial       := pkg_Common.getSessionSerial();
    handlerOperatorId   := pkg_Operator.getCurrentUserId();

    -- �������� �������� ����������
    maxOpTypeTaskExecCount := opt_option_list_t(
      moduleName => pkg_TaskProcessorBase.Module_Name
    ).getNumber(
      optionShortName => pkg_TaskProcessorBase.MaxOpTpTaskExec_OptionSName
    );
  end initialize;



  -- ��������� ������� ����� ����������� ������.
  procedure clean is
  begin
    pkg_TaskHandler.cleanHandler;
  exception when others then            --���������� ����� ����������
    null;
  end clean;



  -- �������� ������� ������� ��� ���������.
  function checkTaskForProcess
  return boolean
  is

    -- �������� ������� ��� ���������
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
          -- ��������� ����� ���������
          ts.start_order_date <= sysdate
        ) a
      where
        -- ������� �� ����������� � ��� ����� ���������
        (
        a.sid is null
          and (
            maxOpTypeTaskExecCount is null
            or a.exec_operator_task_type_count < maxOpTypeTaskExecCount
          )
        -- ���������� ������� ���� ��������
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
        -- ����������� �� ����� �������
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
        -- � ������ ������� ������������ ��������� ���������� �������
        fix_task_flag nulls last
        , a.exec_operator_count
        , a.exec_task_type_count
        , a.start_order_date
        , a.task_id
    ;

    -- ������� ������� ��� ���������
    isFound boolean;



    -- ��������� ������� ��� ���������.
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
                '������ ��� ���������� ������� ('
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
          '������ ��� �������� ������� ������� ��� ���������.'
        )
      , true
    );
  end checkTaskForProcess;



  -- ������� ����������� ������-���� �������.
  procedure waitEvent
  is

    -- ������� �����
    currentTime number;

    -- ����� �������� (� 100-x �������)
    waitTimeout number;

  --waitEvent
  begin

    -- ������������� ���������� � ���������
    logger.trace( 'start idle event');
    pkg_TaskHandler.setAction( Idle_Action);
    loop

      -- ���������� ������� ��������
      currentTime := pkg_TaskHandler.getTime();
      waitTimeout := greatest(
        checkTaskTimeout
          - pkg_TaskHandler.timeDiff( currentTime, lastTaskCheck)
      );

      -- �������� ����������� �������
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

      -- �������� ��������� � ������� �������
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



  -- ������������� ��������� ������� � ��������� ���� � ���������� task.
  -- ��������� commit.
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

    -- ��������� � ����������
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

    -- ��������� � �������
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
          '������ ��� ���������� ��������� ������� ('
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
          '������ ��� ��������� ���������� ���� ������� ('
          || ' taskTypeId=' || to_char( taskTypeId)
          || ').'
        )
      , true
    );
  end getTaskType;



  /*
    ��������� �������.
  */
  procedure runTask(
    execCommand varchar2
    , isProcessFile boolean
  )
  is

    -- ������� �������� ��������� ��������� ����� "��������� ������..."
    isSetFileProcessing boolean := false;

    -- ��� ��������������� �����
    fileName tp_file.file_name%type;

    -- ������ ��������������� �����
    fileData tp_file.file_data%type;



    procedure setTaskOperator
    is
    begin
      pkg_Operator.setCurrentUserId( operatorId => task.manage_operator_id);
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ��� ��������� ��������� ����� ����������� ������� ('
            || ' manage_operator_id=' || to_char( task.manage_operator_id)
            || ').'
          )
        , true
      );
    end setTaskOperator;



    /*
      ������������� ��������� ��������������� �����.
    */
    procedure setFileStatus(
      fileStatusCode varchar2
    )
    is

      -- ������� ��������� �����
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
          , '�� ��������� �������� ������ �����.'
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
            '������ ��� ��������� ��������� ����� ('
            || ' fileStatusCode="' || fileStatusCode || '"'
            || ').'
          )
        , true
      );
    end setFileStatus;



    /*
      �������� ���� ��� ���������.
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
            '������ ��� ��������� ����� ��� ���������.'
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
            '������ ���������� �������.'
          else
            '������ ���������� ������� �� ��������� �����'
            || ' "' || fileName || '" ('
            || ' ������ �����: '
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
        , '���������� ������� ��������� � �������:'
          || chr(10) || task.error_message
      );
    else
      logMessage(
        pkg_Logging.Info_LevelCode
        , '���������� ������� ��������� ('
          || ' resultCode="' || task.result_code || '"'
          || ', execResult=' || task.exec_result
          || ').'
      );
    end if;

    -- ��������������� �������� ���������
    pkg_Operator.setCurrentUserId( operatorId => handlerOperatorId);

    currentTaskId := null;
    currentStartNumber := null;
  end runTask;



  -- ��������� �������.
  procedure ExecTask
  is

    -- ��������� ���� �������
    taskType tp_task_type%rowtype;

    -- ������� ������ ��-�� ����������� ��������, � ������ ������� ��������
    -- �������� ���������� ������� � ������ ������
    isInvalidateError boolean;

  --ExecTask
  begin
    logger.trace( 'ExecTask: start');
    pkg_TaskHandler.setAction(
      action        => ExecTask_Action
      , actionInfo  => to_char( task.task_id)
    );
    getTaskType( taskType, task.task_type_id);

    -- ������������� ��������� ����������
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

    -- ��������� ������� �� ����������
    runTask(
      execCommand             => taskType.exec_command
      , isProcessFile         => taskType.file_name_pattern is not null
    );

    -- ��������� ��������� ����������
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
        , '������ ��-�� ����������� ��������,'
          || ' ��������� ������ ��������� ������� � ������ ������.'
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



  -- ���������� ��������� �������, ���������� �������� ���� ��������.
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



  -- ��������� �������.
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
        , '���������� ������ ��������� ������� ('
          || ' task_id=' || to_char( task.task_id)
          || ', task_status_code="' || task.task_status_code || '"'
          || ').'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� �������.'
        )
      , true
    );
  end processTask;



  --��������� ������� ���������� ������������.
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
          , '�������� ����������� ����������� ������� "' || command || '".'
        );
    end case;
  end processCommand;



  -- ������������ �������.
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
          , '�������� ����������� ������� ������ ����� ���������.'
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
  ���������� � ��� ���������, ����������� � �������� ������������ �������.

  ���������:
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������
  lineNumber                  - ����� ������ ��������������� �����, � �������
                                ��������� ��������� ( ��������� ������ �������
                                � 1, 0 ���� ��������� �� ��������� � ������
                                ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������� ������������� ��� ����������� �������� ���������� ��������
    �������, � ������ ������ ��� ���������� ������������ ������� �����
    ��������� ����������;
  - ������� ����������� � ���������� ����������;
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
      , '����������� ����������� �������.'
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
        '������ ��� ������ � ��� ��������� ('
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
