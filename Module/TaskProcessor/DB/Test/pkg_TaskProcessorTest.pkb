create or replace package body pkg_TaskProcessorTest is
/* package body: pkg_TaskProcessorTest::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_TaskProcessorBase.Module_Name
  , objectName  => 'pkg_TaskProcessorTest'
);



/* group: ������� */

/* proc: stopTask
  ������� ������� � ����������.

  ���������:
  moduleName                  - ��� ����������� ������
  processName                 - ��� ����������� ��������, ��������������� ����
                                ��� �������

  ���������:
  - ����������� � ���������� ����������;
*/
procedure stopTask(
  moduleName varchar2 := null
  , processName varchar2 := null
)
is

  pragma autonomous_transaction;

  cursor dataCur is
    select
      ts.*
    from
      v_tp_active_task ts
      inner join tp_task_type tt
        on tt.task_type_id = ts.task_type_id
    where
      ts.task_status_code = pkg_TaskProcessorBase.Queued_TaskStatusCode
      and nullif( moduleName, tt.module_name) is null
      and nullif( processName, tt.process_name) is null
    order by
      ts.task_id
  ;

begin
  for rec in dataCur loop
    pkg_TaskProcessor.stopTask(
      taskId => rec.task_id
    );
    commit;
  end loop;
  commit;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������ � ���������� ������� ('
        || ' moduleName="' || moduleName || '"'
        || ', processName="' || processName || '"'
        || ').'
      )
    , true
  );
end stopTask;

/* proc: waitForTask
  �������� ��������� �������.

  taskId                      - ������������ �������
  maxCount                    - �������� �������� � ���
                                ( �� ��������� 200)
*/
procedure waitForTask(
  taskId                      integer
, maxCount                    integer := null
)
is
  nCount integer;
  usedMaxCount integer := coalesce( maxCount, 200);
begin
  for i in 1..usedMaxCount loop
    dbms_lock.sleep( 1);
    select
      count(1)
    into
      nCount
    from
      tp_task
    where
      task_id = taskId
      and task_status_code = pkg_TaskProcessorBase.Idle_TaskStatusCode
    ;
    exit when nCount = 1;
  end loop;
  if nCount = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�������� �������� �������� ( ' || usedMaxCount
        || '���.). ��������� ����������'
        || ' ����������� TaskProcessor'
    );
  end if;
end waitForTask;

/* func: createProcessFileTask
  ������� ������� �� ��������� ����� ( ��� ���������� commit).

  ���������:
  moduleName                  - �������� ������, � �������� ��������� �������
  processName                 - �������� ��������, � �������� ��������� �������
  fileData                    - ��������� ������ �����
  fileName                    - ��� �����
                                (�� ��������� "�������� ����.csv")
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id �������.
*/
function createProcessFileTask(
  moduleName varchar2
  , processName varchar2
  , fileData clob
  , fileName varchar2 := null
  , operatorId integer := null
)
return integer
is

  taskId integer;

begin
  taskId := pkg_TaskProcessor.createTask(
    moduleName        => moduleName
    , processName     => processName
    , fileName        => coalesce( fileName, '�������� ����.csv')
    , mimeTypeCode    => 'application/vnd.ms-excel'
    , operatorId      =>
        coalesce( operatorId, pkg_Operator.getCurrentUserId())
  );
  update
    tp_file t
  set
    t.file_data = fileData
  where
    t.task_id = taskId
  ;
  pkg_TaskProcessor.setFileLoaded(
    taskId            => taskId
    , operatorId      =>
        coalesce( operatorId, pkg_Operator.getCurrentUserId())
  );
  return taskId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������� �� ��������� ������ �� �����.'
      )
    , true
  );
end createProcessFileTask;

/* proc: executeLoadFileTask
  ������ ������� �� �������� ����� � ������� ��� ����������.

  ���������:
  moduleName                  - �������� ������, � �������� ��������� �������
  processName                 - �������� ��������, � �������� ��������� �������
  fileData                    - ��������� ������ �����
*/
procedure executeLoadFileTask(
  moduleName varchar2
  , processName varchar2
  , fileData clob
)
is

  taskId integer;



  /*
    ������� ������� ( � ���������� ����������).
  */
  procedure createTask
  is

    pragma autonomous_transaction;

  begin
    taskId := createProcessFileTask(
      moduleName          => moduleName
      , processName       => processName
      , fileData          => fileData
    );
    commit;
  end createTask;

  /*
    ����� ���� �������.
  */
  procedure showLog
  is
    taskLogCur sys_refcursor;
    taskLog tp_task_log%rowtype;
    levelName varchar2(1000);
  begin
    taskLogCur := pkg_TaskProcessor.findTaskLog(
      taskId => taskId
    );
    loop
      fetch
        taskLogCur
      into
        taskLog.task_log_Id
        , taskLog.task_id
        , taskLog.start_number
        , taskLog.line_number
        , taskLog.level_code
        , levelName
        , taskLog.message_text
        , taskLog.date_ins
      ;
      exit when
        taskLogCur%notfound
      ;
      logger.trace(
        'task log: ' || to_char( taskLog.date_ins, 'hh24:mi:ss')
        || ' "' || taskLog.message_text || '"'
      );
    end loop;
    close
      taskLogCur
    ;
  end showLog;

-- executeLoadFileTask
begin
  createTask();
  waitForTask( taskId => taskId);
  showLog();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������������ ���������� �������'
      )
    , true
  );
end executeLoadFileTask;

/* proc: userApiTest
  ������������ API ��� ����������������� ����������.
*/
procedure userApiTest
is

  -- ��������� ���������� �������
  rc sys_refcursor;

  -- �������� ��� ������ API-�������
  operatorId integer := pkg_Operator.getCurrentUserId();

  -- "����������" ��������
  guestOperatorId integer := 5;



  /*
    ��������� ����� ������� � �������.
  */
  procedure checkCursor(
    functionName varchar2
    , expectedRowCount integer := null
  )
  is
  begin
    pkg_TestUtility.compareRowCount(
      rc
      , expectedRowCount => coalesce( expectedRowCount, 0)
      , failMessageText  =>
          functionName || ': ������������ ����� ������� � �������'
    );
  end checkCursor;



  /*
    ���� ������� %TaskType.
  */
  procedure testTaskTypeApi
  is

    cursor taskTypeCur is
      select
        a.*
      from
        (
        select
          tp.module_name
          , count(*) as task_type_count
          , count( tp.access_role_short_name) as access_role_count
        from
          tp_task_type tp
        group by
          tp.module_name
        order by
          access_role_count desc
        ) a
      where
        rownum <= 1
    ;

  begin
    for rec in taskTypeCur loop
      begin

        rc := pkg_TaskProcessor.getTaskType(
          moduleName        => rec.module_name
          , operatorId      => null
        );
        checkCursor(
          'getTaskType'
            || ' ( module_name="' || rec.module_name || '")'
          , rec.task_type_count
        );

        rc := pkg_TaskProcessor.getTaskType(
          moduleName        => rec.module_name
          , operatorId      => guestOperatorId
        );
        checkCursor(
          'getTaskType[ guestOperatorId]'
            || ' ( module_name="' || rec.module_name || '")'
          , rec.task_type_count - rec.access_role_count
        );

      exception when others then
        raise_application_error(
          pkg_Error.ErrorStackInfo
          , logger.errorStack(
              '������ ��� ������������ ������ ������ ('
              || ' module_name="' || rec.module_name || '"'
              || ').'
            )
          , true
        );
      end;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������������ ������� %TaskType.'
        )
      , true
    );
  end testTaskTypeApi;



-- userApiTest
begin
  pkg_TestUtility.beginTest(
    'user API'
  );

  testTaskTypeApi();

  pkg_TestUtility.endTest();
  rollback;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������������ API ��� ����������������� ����������.'
      )
    , true
  );
end userApiTest;

end pkg_TaskProcessorTest;
/
