create or replace package body pkg_TaskProcessor is
/* package body: pkg_TaskProcessor::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_TaskProcessorBase.Module_Name
  , objectName  => 'pkg_TaskProcessor'
);

/* ivar: moduleId
  Id ������ TaskProcessor.
*/
moduleId integer;



/* group: ������� */

/* func: getModuleId
  ���������� Id ������ TaskProcessor.

  �������:
  �������� module_id �� ������� mod_module (������ ModuleInfo).
*/
function getModuleId
return integer
is
begin
  if moduleId is null then
    moduleId := pkg_ModuleInfo.getModuleId(
      moduleName            => pkg_TaskProcessorBase.Module_Name
      , raiseExceptionFlag  => 1
    );
  end if;
  return moduleId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� Id ������ TaskProcessor.'
      )
    , true
  );
end getModuleId;

/* ifunc: checkAccess
  ��������� ����� ������� ��������� � � ������ ���������� ���� �����������
  ����������.

  ���������:
  operatorId                  - Id ���������, ��� ������� ����������� �����
                                ( ���� null, �� ������������ Id ��������
                                ������������������ ���������)
  taskTypeId                  - Id ���� �������, ��� ������� �������������
                                ��������

  �������:
  Id ���������, ��� �������� ���� ��������� ����� ( ����������� �������,
  �� ����� null)
*/
function checkAccess(
  operatorId integer
  , taskTypeId integer
)
return integer
is

  -- ������� ����������� Id ���������
  checkOperatorId integer := operatorId;



  /*
    ��������� ����������� ���� ������� ��� ���������.
  */
  function isTaskTypeAccess
  return boolean
  is

    -- ����, ������ ����� �� ��� �������
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

  -- �� ��������� ������������������ ��������
  if checkOperatorId is null then
    checkOperatorId := pkg_Operator.getCurrentUserId();
  end if;

  -- ������ ������ ��� ��������������
  if pkg_Operator.IsRole(
      operatorId => checkOperatorId
      , roleShortName => pkg_TaskProcessorBase.Administrator_RoleName
      ) = 0
    then
    if taskTypeId is null or not isTaskTypeAccess() then
      raise_application_error(
        pkg_Error.ProcessError
        , '����������� ����� ������� ('
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
        '������ ��� �������� ���� ������� ��������� ('
        || ' operatorId=' || operatorId
        || ', taskTypeId=' || taskTypeId
        || ').'
      )
    , true
  );
end checkAccess;



/* group: ���� ������� */

/* func: mergeTaskType
  ������� ��� ��������� ��� �������.

  ���������:
  moduleName                  - ��� ����������� ������
  processName                 - ��� ����������� ��������, ��������������� ����
                                ��� �������
  taskTypeNameEng             - �������� ���� ������� ( ���.)
  taskTypeNameRus             - �������� ���� ������� ( ���.)
  execCommand                 - �������, ���������� ��� ��������� ( ����������
                                PL/SQL �����, �������� � ��������������
                                ���������������� ����������)
  fileNamePattern             - ����� ����� ����� ( ��� like, ������������
                                ������ "\") � ������� ��� ��������� �������� (
                                ���� �������, �� ��� ���������� ������� �����
                                ��������� ���� � ���������� ������ �����
                                ���������, ����� ���� ��� ������� ��
                                ������������)
  accessRoleShortName         - �������� ���� �� ������ AccessOperator,
                                ����������� ��� ������� � �������� ����� ����
  taskKeepDay                 - ����� �������� ������� � ����, �� ���������
                                �������� �������������� �������������� �������
                                ������������� ��������� ( �� ���������
                                ������������)
  ignoreCheckFlag             - ������� ������������� �������� ������������
                                ������������ ��������
                                ( �� ��������� �� ������������)
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  �������:
  - ���� �������� ��������� ( 0 ��� ���������, 1 ������ ��������� ��� ���������)

  ���������:
  - ������ ��� ������� ������ ���� �������� �� ���������� ����������
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
  , ignoreCheckFlag boolean := null
  , operatorId integer := null
)
return integer
is
begin
  if coalesce( ignoreCheckFlag, false) then
    pkg_TaskProcessorHandler.checkExecCommandParsed(
      execCommand => execCommand
    , isProcessFile => fileNamePattern is not null
    );
  end if;
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
        '������ ��� ���������� ���� ������� ('
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
  ������� ������ ����� ����� ��� ���������� ������.

  ���������:
  moduleName                  - ������������ ������
  operatorId                  - Id ��������� ��� ���������� ����������� ���
                                ����� �����
                                ( �� ��������� ��� �����������)

  �������:
  task_type_id                - ������������� ���� ������
  process_name                - ������������ ����������� ��������
  task_type_name              - ������������ ���� ������

  ( ���������� �� task_type_name, task_type_id)

  ���������:
  - � ������ �������� Id ��������� � ��������� operatorId �� ������
    ����������� ���� �����, � ������� � ������� <tp_task_type> ��������� ����
    access_role_short_name � �������� � ���� ���� ���� ���������� ���������;
*/
function getTaskType(
  moduleName varchar2
  , operatorId integer := null
)
return sys_refcursor
is

  -- ������������ ������
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
          '������ ��� ��������� ������ ����� ����� ('
          || ' moduleName="' || moduleName || '"'
          || ', operatorId=' || operatorId
          || ').'
          )
      , true
    );

end getTaskType;

/* func: getTaskTypeId
  ���������� Id ���� ������� ��� ���������� ��������.

  ���������:
  moduleName                  - ��� ����������� ������
  processName                 - ��� ����������� ��������, ��������������� ����
                                ��� �������
  isNotFoundRaised            - ������������ �� ���������� � ������
                                ���������� ����������� ���� �������
                                ( 1 �� ( �� ���������), 0 ���)

  �������:
  Id ���� ������� ���� null ���� ������ �� ������� � �������� ���������
  isNotFoundRaised ����� 0.

  ���������:
  - ������� ������������� ��� ������������� � ���������� �������;
*/
function getTaskTypeId(
  moduleName varchar2
  , processName varchar2
  , isNotFoundRaised integer := null
)
return integer
is

  -- Id ���� �������
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
      , '�� ������ ��� �������.'
    );
  end if;
  return taskTypeId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� Id ���� ������� ('
        || ' moduleName="' || moduleName || '"'
        || ', processName="' || processName || '"'
        || ', isNotFoundRaised=' || isNotFoundRaised
        || ').'
      )
    , true
  );
end getTaskTypeId;



/* group: ������� */

/* iproc: lockTask
  ��������� � ���������� �������.

  ���������:
  rowData                     - ������ ������ ( �������)
  taskId                      - Id �������
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
        '������ ��� ���������� ������� ('
        || ' taskId=' || taskId
        || ').'
      )
    , true
  );
end lockTask;

/* iproc: checkTask
  ��������� �������� ����� ����������� �������� ��� ��������.

  ���������:
  taskId                      - Id �������
  operatorId                  - Id ���������, ������������ �������� ( ���� null,
                                �� ����������� � ������������ ������� ��������)
  taskStatusCode              - ��� ���������, � ������� ������ ����������
                                ������� ( �� ��������� ��� ��������)
*/
procedure checkTask(
  taskId integer
  , operatorId in out nocopy integer
  , taskStatusCode varchar2 := null
)
is

  -- ������� ������
  rec tp_task%rowtype;

begin

  -- �������� ������� ������
  lockTask( rec, taskId);

  -- �������� ���� �������
  operatorId := checkAccess( operatorId, rec.task_type_id);

  -- �������� ��������� �������
  if nullif( taskStatusCode, rec.task_status_code) is not null then
    raise_application_error(
      pkg_Error.ProcessError
      , '������� ��������� ������� �� ��������� ��������� �������� ('
        || ' task_status_code="' || rec.task_status_code || '"'
        || ').'
    );
  end if;
end checkTask;

/* ifunc: createTask( INTERNAL)
  ��������� �������.

  ���������:
  moduleName                  - ��� ����������� ������
  processName                 - ��� ����������� ��������
  startDate                   - ���� ������� ( �� ��������� �� ��������� ��
                                ������ ������ <startTask>)
  fileName                    - ��� ����� ��� ���������
  mimeTypeCode                - MIME-��� �����
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  �������:
  - Id ����������� ������
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

  -- Id ����������� ������
  taskId tp_task.task_id%type;

  -- ��������� ���� �������
  tpr tp_task_type%rowtype;

  -- Id ���������, ������������ ��������
  manageOperatorId integer := operatorId;




  /*
    ���������� ��� �������.
  */
  procedure getTaskType
  is
  begin
    select
      tt.*
    into tpr
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
          '������ ��� ����������� ���� �������.'
        )
      , true
    );
  end getTaskType;



  /*
    ��������� ������ � tp_task.
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
      tpr.task_type_id
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
          '������ ��� ���������� ������ ��� �������.'
        )
      , true
    );
  end addTask;



  /*
    ��������� ������ ��� �����.
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
          '������ ��� ���������� ������ ��� �����.'
        )
      , true
    );
  end addFile;



-- createTask
begin

  -- ����������� ���� �������
  getTaskType();

  -- �������� ���� �������
  manageOperatorId := checkAccess( operatorId, tpr.task_type_id);

  if tpr.file_name_pattern is not null then
    if fileName is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '��� ������� ���� ������� ���������� �������� ����� ��� ��������� ('
        || ' task_type_id=' || tpr.task_type_id
        || ').'
      );
    elsif fileName not like tpr.file_name_pattern escape '\' then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '��� ����� �� ������������� ������� ('
          || ' file_name_pattern="' || tpr.file_name_pattern || '"'
          || ').'
      );
    end if;
  elsif fileName is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��� ������� ���� ������� �� ��������� �������� ����� ('
        || ' task_type_id=' || tpr.task_type_id
        || ').'
    );
  end if;

  -- ���������� �������
  addTask();

  -- ���������� ������ ��� �����
  if tpr.file_name_pattern is not null then
    addFile();
  end if;

  logger.info(
    messageText             =>
        '������� ������� ���� "' || tpr.task_type_name_rus || '"'
        || ' [' || tpr.process_name || ']'
        || case when startDate is not null then
            ' � ����� ������� {'
            || to_char( startDate, 'dd.mm.yyyy hh24:mi:ss')  || '}'
          end
        || case when fileName is not null then
            ' ��� ��������� ����� "' || fileName || '"'
          end
        || ' (task_id=' || taskId || ').'
    , messageLabel          => pkg_TaskProcessorBase.Create_TaskMsgLabel
    , contextTypeShortName  => pkg_TaskProcessorBase.Task_CtxTpSName
    , contextValueId        => taskId
  );

  return taskId;
end createTask;

/* func: createTask
  ��������� �������.

  ���������:
  moduleName                  - ��� ����������� ������
  processName                 - ��� ����������� ��������
  startDate                   - ���� ������� ( �� ��������� �� ��������� ��
                                ������ ������ <startTask>)
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  �������:
  - Id ����������� ������

  ���������:
  - � ����������� ������� <tp_task_type> ������ ���� �������������� ��������
    ��������������� ��� ������� ( ������������ �� ����� ������ � ��������);
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
        '������ ��� ���������� ������� ('
        || ' moduleName="' || moduleName || '"'
        || ', processName="' || processName || '"'
        || ', startDate=' || to_char( startDate, 'dd.mm.yyyy hh24:mi:ss')
        || ').'
      )
    , true
  );
end createTask;

/* func: createTask( FILE)
  ��������� ������� ��� ��������� �����.

  ���������:
  moduleName                  - ��� ����������� ������
  processName                 - ��� ����������� ��������
  fileName                    - ��� ����� ��� ���������
  mimeTypeCode                - MIME-��� �����
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  �������:
  - Id ����������� ������

  ���������:
  - ����� ���������� ������� � ���� file_data ������� <tp_file> ( ��� ������
    �� ��������� task_id, ������ ������������� �������� ��������) ������
    ���� ��������� ������ �����, ����� ���� ������� ������� <setFileLoaded>;
  - � ����������� ������� <tp_task_type> ������ ���� �������������� ��������
    �������������� ��� ������� ( ������������ �� ����� ������ � ��������);
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

  -- �� ������� ����� ����� � ������� ���� ������������ ��� ������������ �������
  if fileName is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������� ��� �����.'
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
        '������ ��� ���������� ������� ��� ��������� ����� ('
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
  ������������� ��������������� ��������� ����� ����� ���������� ��������
  ������ � ������ ������� � ������� �� ����������.
  ������� ������ ���������� ����� ���������� �������� ������ ����� � ����
  file_data ������� <tp_file> ( ��� ���� ������� ������ ���� ��������������
  ������� �������� createTask( FILE)).

  ���������:
  taskId                      - Id �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)
*/
procedure setFileLoaded(
  taskId integer
  , operatorId integer := null
)
is



  /*
    ������������� ��������� �����.
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
        , '�� ������� ������ ��� �����.'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ��������� ��������� �����.'
        )
      , true
    );
  end setFileStatus;



-- setFileLoaded
begin

  -- ������ ������ �����, ����� ��������� ����� ������� � ������������� ������
  -- �� �������
  startTask(
    taskId        => taskId
    , operatorId  => operatorId
  );

  setFileStatus();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ��������� ����� ����� �������� ������ ('
        || ' taskId=' || taskId
        || ').'
      )
    , true
  );
end setFileLoaded;

/* proc: updateTaskParameter
  ���������� ��� ��������� ���������� ���������� �������.
  ��������� �������������� �������, �������� ����������� ��� ������� ��
  ���������� ����������.

  ���������:
  taskId                      - Id �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  ���������:
  - ������� ������ ���������� � ������� "�����������", ����� �������������
    ����������;
*/
procedure updateTaskParameter(
  taskId integer
  , operatorId integer := null
)
is

  -- Id ���������, ������������ ��������
  manageOperatorId integer := operatorId;

begin

  -- �������� ����� ����������� ��������
  checkTask(
    taskId              => taskId
    , operatorId        => manageOperatorId
    , taskStatusCode    => pkg_TaskProcessorBase.Idle_TaskStatusCode
  );

  -- ��������� ��������
  update
    tp_task t
  set
    t.manage_date = sysdate
    , t.manage_operator_id = manageOperatorId
  where
    t.task_id = taskId
  ;

  logger.info(
    messageText             =>
        '�������� ��������� �������'
        || ' (task_id=' || taskId || ').'
    , messageLabel          => pkg_TaskProcessorBase.Update_TaskMsgLabel
    , contextTypeShortName  => pkg_TaskProcessorBase.Task_CtxTpSName
    , contextValueId        => taskId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ���������� ������� ('
        || ' taskId=' || taskId
        || ').'
      )
    , true
  );
end updateTaskParameter;

/* proc: deleteTask
  ������� �������.

  ���������:
  taskId                      - Id �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  ���������:
  - ������� ������ ���������� � ������� "�����������", ����� �������������
    ����������;
*/
procedure deleteTask(
  taskId integer
  , operatorId integer := null
)
is

  -- Id ���������, ������������ ��������
  manageOperatorId integer := operatorId;

begin

  -- �������� ����� ����������� ��������
  checkTask(
    taskId              => taskId
    , operatorId        => manageOperatorId
    , taskStatusCode    => pkg_TaskProcessorBase.Idle_TaskStatusCode
  );

  -- ��������� ��������
  delete from
    tp_task t
  where
    t.task_id = taskId
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������� ('
        || ' taskId=' || taskId
        || ').'
      )
    , true
  );
end deleteTask;

/* func: findFile
  ����� ��������� ������.

  ���������:
  moduleName                  - �������� ������, � �������� ��������� �������
  processName                 - �������� ��������, � �������� ��������� �������
  taskId                      - Id �������
  fileName                    - ��� �����
                                ( ��������� �� like ��� ����� ��������)
  fromDate                    - ��������� ���� ���������� �����
                                ( � ��������� �� ���, ������������)
  toDate                      - �������� ���� ���������� �����
                                ( � ��������� �� ���, ������������)
  maxRowCount                 - ������������ ����� ������������ ������� �������
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� ( ������):
  task_id                     - Id �������
  task_type_id                - Id ���� �������
  task_type_name              - �������� ���� �������
  file_status_code            - ��� ��������� �����
  file_status_name            - �������� ��������� �����
  file_name                   - ��� �����
  extension                   - ���������� ����� ( ���������� �� ����� �����)
  mime_type_code              - MIME-��� �����
  file_loaded_date            - ���� �������� ������ �����
  task_start_date             - ���� ������� ��������� �����
  result_code                 - ��� ���������� ���������
  result_name                 - �������� ���������� ���������
  exec_result                 - �������� ��������� ���������
  error_message               - ��������� �� ������ ��� ���������
  file_date_ins               - ���� ���������� �����
  file_operator_id            - Id ���������, ����������� ����
  file_operator_name          - ��������, ���������� ����

  ���������:
  - ������������ ������ ������������� �� ���� task_id � �������� �������;
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

  -- ������������ ������
  rc sys_refcursor;

  -- ����������� ����������� ����� �������
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
        '������ ��� ������ ��������� ������ ('
        || ' moduleName="' || moduleName || '"'
        || ', processName="' || processName || '"'
        || ', taskId=' || taskId
        || ').'
      )
    , true
  );
end findFile;



/* group: ���������� ��������� */

/* proc: startTask
  ������ ������� � ������� �� ����������.

  ���������:
  taskId                      - Id �������
  startDate                   - ���� ������� ( �� ��������� ����������)
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  ���������:
  - ������� ������ ���������� � ������� "�����������", ����� �������������
    ����������;
*/
procedure startTask(
  taskId integer
  , startDate date := null
  , operatorId integer := null
)
is

  -- Id ���������, ������������ ��������
  manageOperatorId integer := operatorId;

  -- ���� ���������� �������
  nextStartDate tp_task.next_start_date%type;

begin

  -- �������� ����� ����������� ��������
  checkTask(
    taskId              => taskId
    , operatorId        => manageOperatorId
    , taskStatusCode    => pkg_TaskProcessorBase.Idle_TaskStatusCode
  );

  -- ��������� ��������
  update
    tp_task t
  set
    t.task_status_code = pkg_TaskProcessorBase.Queued_TaskStatusCode
    , t.next_start_date = coalesce( startDate, sysdate)
    , t.manage_date = sysdate
    , t.manage_operator_id = manageOperatorId
  where
    t.task_id = taskId
  returning
    next_start_date
  into
    nextStartDate
  ;

  logger.info(
    messageText             =>
        '������� ���������� � ������� �� ���������� � ����� ������� {'
        || to_char( nextStartDate, 'dd.mm.yyyy hh24:mi:ss')  || '}'
        || ' (task_id=' || taskId || ').'
    , messageLabel          => pkg_TaskProcessorBase.Start_TaskMsgLabel
    , contextTypeShortName  => pkg_TaskProcessorBase.Task_CtxTpSName
    , contextValueId        => taskId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ���������� ������� � ������� �� ���������� ('
        || ' taskId=' || taskId
        || ').'
      )
    , true
  );
end startTask;

/* proc: stopTask
  ������������� ���������� �������.

  ���������:
  taskId                      - Id �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)
  ���������:
  - ������� ������ ���������� � ������� "� �������", ����� �������������
    ����������;
*/
procedure stopTask(
  taskId integer
  , operatorId integer := null
)
is

  -- Id ���������, ������������ ��������
  manageOperatorId integer := operatorId;

begin

  -- �������� ����� ����������� ��������
  checkTask(
    taskId              => taskId
    , operatorId        => manageOperatorId
    , taskStatusCode    => pkg_TaskProcessorBase.Queued_TaskStatusCode
  );

  -- ��������� ��������
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

  logger.info(
    messageText             =>
        '������� ����� � ������� �� ����������'
        || ' (task_id=' || taskId || ').'
    , messageLabel          => pkg_TaskProcessorBase.Stop_TaskMsgLabel
    , contextTypeShortName  => pkg_TaskProcessorBase.Task_CtxTpSName
    , contextValueId        => taskId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ���������� ������� ('
        || ' taskId=' || taskId
        || ').'
      )
    , true
  );
end stopTask;



/* group: ��� ���������� ������� */

/* ifunc: findTaskLogOld
  ����� ���� ���������� ������� � ���������� ������� <tp_task_log> (���
  ������������ �������������).
*/
function findTaskLogOld(
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

  -- ������������ ������
  rc sys_refcursor;

  -- ����������� ����������� ����� �������
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
        '������ ��� ������ ���� ���������� �������. ('
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
end findTaskLogOld;

/* func: findTaskLog
  ����� ���� ���������� �������.

  ���������:
  taskLogId                   - Id ������ ����
                                (�� ��������� ��� �����������)
  taskId                      - Id �������
                                (�� ��������� ��� �����������)
  startNumber                 - ����� ������� ������� (������� � 1)
                                (�� ��������� ��� �����������)
  lineNumber                  - ����� ������ ��������������� ����� (������� 1
                                ��� 0 ��� ���������, �� ��������� �� �������
                                �����)
                                (�� ��������� ��� �����������)
  levelCode                   - ��� ������ ���������
                                (�� ��������� ��� �����������)
  messageText                 - ����� ���������
                                (����� �� like ��� ����� ��������)
                                (�� ��������� ��� �����������)
  startTaskLogId              - Id ������ ����, � ������� ����� ������ �������
                                (�� ��������� ��� �����������)
  maxRowCount                 - ������������ ����� ������������ ������� �������
                                (�� ��������� ��� �����������)
  operatorId                  - Id ���������, ������������ ��������
                                (�� ��������� �������)

  ������� ( ������):
  task_log_id                 - Id ������ ����
  task_id                     - Id �������
  start_number                - ����� ������� ������� ( ������� � 1)
  line_number                 - ����� ������ ��������������� �����
                                (������� 1 ��� 0 ��� ���������, �� ���������
                                �� ������� �����)
  level_code                  - ��� ������ ���������
  level_name                  - �������� ������ ���������
  message_text                - ����� ���������
  date_ins                    - ���� ���������� ������

  (���������� �� ���� task_log_id)

  ���������:
  - ����������� ������ ���� ������ �������� �� NULL �������� ���� �� ���
    ������ �� ���������� taskLogId ��� taskId;
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

  -- ������������ ������
  rc sys_refcursor;

  -- ����������� ����������� ����� �������
  dsql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
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
    (
    select
      d.*
      , d.log_id as task_log_id
      , case when
          d.context_type_id =
            (
            select
              ct.context_type_id
            from
              v_mod_module md
              inner join lg_context_type ct
                on ct.module_id = md.module_id
            where
              md.svn_root = ''' || pkg_TaskProcessorBase.Module_SvnRoot || '''
              and ct.context_type_short_name = ''' || Line_CtxTpName || '''
            )
        then
          d.context_value_id
        else
          0
        end
        as line_number
    from
      (
      select
        lg.log_id
        , o.task_id
        , o.start_number
        , lg.context_value_id
        , lg.context_type_id
        , lg.level_code
        , lg.message_text
        , lg.date_ins
      from
        v_tp_task_operation o
        inner join lg_log lg
          on lg.sessionid = o.sessionid
            and lg.log_id >= o.start_log_id
            and lg.log_id <= coalesce( o.finish_log_id, lg.log_id)
      where
        o.task_id = :taskId
        -- ������ ���� ����������
        and o.start_number is not null
        and nullif( :startNumber, o.start_number) is null
        and :taskLogId is null
      union all
      select
        lg.log_id
        , max( o.task_id)
          keep( dense_rank last order by o.start_log_id)
          as task_id
        , max( o.start_number)
          keep( dense_rank last order by o.start_log_id)
          as start_number
        , lg.context_value_id
        , lg.context_type_id
        , lg.level_code
        , lg.message_text
        , lg.date_ins
      from
        lg_log lg
        inner join lg_log lg0
          on lg0.sessionid = lg.sessionid
            and lg0.log_id <= lg.log_id
            and lg0.open_context_flag = 1
        inner join v_tp_task_operation o
          on o.task_context_type_id = lg0.context_type_id
            and o.task_id = lg0.context_value_id
            and o.start_number is not null
            and nullif( :taskId, o.task_id) is null
            and nullif( :startNumber, o.start_number) is null
      where
        lg.log_id = :taskLogId
      group by
        lg.log_id
        , lg.context_value_id
        , lg.context_type_id
        , lg.level_code
        , lg.message_text
        , lg.date_ins
      ) d
    ) t
    inner join lg_level lv
      on lv.level_code = t.level_code
  where
    $(condition)
  order by
    t.task_log_id
  ) a
where
  $(rownumCondition)
'
  );

  -- ���� ������� ���� �� ���������� ������� tp_task_log
  oldLogFlag integer;

begin
  if taskId is null and taskLogId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������ ���� ������ �������� �� NULL �������� ���� �� ��� ������ ��'
        || ' ���������� taskLogId ��� taskId.'
    );
  end if;
  select
    count(*) as old_log_flag
  into oldLogFlag
  from
    tp_task_log tl
  where
    rownum <= 1
    and (
      tl.task_id = taskId
        and nullif( startNumber, tl.start_number) is null
      or taskId is null
        and tl.task_log_id = taskLogId
    )
  ;
  if oldLogFlag = 0 then
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
      -- ���������, ������������ � ������ SQL
      taskId
      , startNumber
      , taskLogId
      , taskId
      , startNumber
      , taskLogId
      -- ��� ������� addCondition
      , taskLogId
      , taskId
      , startNumber
      , lineNumber
      , levelCode
      , messageText
      , startTaskLogId
      , maxRowCount
    ;
  else
    rc := findTaskLogOld(
      taskLogId           => taskLogId
      , taskId            => taskId
      , startNumber       => startNumber
      , lineNumber        => lineNumber
      , levelCode         => levelCode
      , messageText       => messageText
      , startTaskLogId    => startTaskLogId
      , maxRowCount       => maxRowCount
      , operatorId        => operatorId
    );
  end if;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ ���� ���������� �������. ('
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



/* group: ����������� */

/* func: getLevel
  ���������� ������ ������� ��������� ����.

  ������� ( ������):
  level_code                  - ��� ������ ���������
  level_name                  - �������� ������ ���������

  ���������:
  - ������������ ������ ������������� �� ���� level_code;
*/
function getLevel
return sys_refcursor
is

  -- ������������ ������
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
        '������ ��� �������� ������ ������� ��������� ����.'
      )
    , true
  );
end getLevel;

/* func: getResult
  ���������� ��������� ���������� ���������� �������.

  ������� ( ������):
  result_code             - ��� ���������� ����������
  result_name             - �������� ���������� ����������

  ���������:
  - ������������ ������ ������������� �� result_code;
*/
function getResult
return sys_refcursor
is

  -- ������������ ������
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
        '������ ��� ������� ��������� ����������� ���������� �������.'
      )
    , true
  );
end getResult;



/* group: ���������� ������� */

/* proc: logMessage
  ���������� �������, ������ ��� ������� ������������ ������� �����������
  ��������� �� ���� lg_logger_t (������ Logging), ��� ���� ��� �������� ������
  ��������������� ����� ������� ������������ �������� ����������
  <Line_CtxTpName>.
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , lineNumber integer := null
  , operatorId integer := null
)
is
begin
  logger.log(
    levelCode               => levelCode
    , messageText           => messageText
    , contextTypeShortName  =>
        case when nullif( lineNumber, 0) is not null then
          Line_CtxTpName
        end
    , contextValueId        => nullif( lineNumber, 0)
  );
end logMessage;

/* proc: logError
  ���������� ������� ���������� <logMessage>.
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
  ���������� ������� ���������� <logMessage>.
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
  ���������� ������� ���������� <logMessage>.
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
  ���������� ������� ���������� <logMessage>.
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
  ���������� ������� ���������� <logMessage>.
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

end pkg_TaskProcessor;
/
