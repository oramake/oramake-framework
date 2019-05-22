create or replace package body pkg_SchedulerTest is
/* package body: pkg_SchedulerTest::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Scheduler.Module_Name
  , objectName  => 'pkg_SchedulerTest'
);

/* iconst: Max_LoopCounter
  Максимальное число итераций цикла.
*/
Max_LoopCounter constant integer := 10000;

/* ivar: outputFlag
  Вывод в буфер dbms_output.
*/
outputFlag number(1,0) not null :=
  case when
    logger.isInfoEnabled()
  then
    1
  else
    0
  end;



/* group: Функции */


/* proc: setOutputFlag
  Установка флаг вывода в буфер dbms_output.

  Параметры:
  outputFlag                  - флаг вывода в буфер dbms_output.
*/
procedure setOutputFlag(
  outputFlag number
)
is
-- setOutputFlag
begin
  pkg_SchedulerTest.outputFlag := setOutputFlag.outputFlag;
end setOutputFlag;

/* iproc: outputMessage
  Выводит сообщение для информации.
*/
procedure outputMessage(
  messageText varchar2
)
is
begin
  if outputFlag = 1 then
    pkg_Common.outputMessage(
      messageText
    );
  else
    logger.trace( messageText);
  end if;
end outputMessage;

/* proc: showLastRunLog
  Выводит лог последнего выполнения батча на экран.

  Параметры:
  batchId                     - id батча
*/
procedure showLastRunLog(
  batchId integer
)
is

  cursor parentLogCur is
    select
      a.start_log_id
      , lg.date_ins
      , lg.operator_id
    from
      (
      select
        max( bo.start_log_id) as start_log_id
      from
        v_sch_batch_operation bo
      where
        bo.batch_id = batchId
        and bo.batch_operation_label = pkg_SchedulerMain.Exec_BatchMsgLabel
      ) a
      inner join lg_log lg
        on lg.log_id = a.start_log_id
  ;

  parentLog parentLogCur%rowtype;

  cursor logCur( startLogId integer) is
    select
      ' ' || to_char( lg.date_ins, 'hh24:mi:ss') || ' '
      || decode( lg.message_level
          , 1, ''
          , lpad( '  ', (lg.message_level - 1) * 2, ' ')
        )
        -- исключаем ошибку из-за строки длиной больше 4000 символов
        || substr( lg.message_text, 1, 3900 - (lg.message_level - 1) * 2)
        as message_line
    from
      (
      select
        lg.*
        , 1 + ( lg.context_level - ccl.open_context_level)
          + case when lg.open_context_flag in ( 1, -1) then 0 else 1 end
          as message_level
      from
        v_lg_context_change_log ccl
        inner join lg_log lg
          on lg.sessionid = ccl.sessionid
            and lg.log_id >= ccl.open_log_id
            and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
      where
        ccl.log_id = startLogId
      ) lg
    order by
      lg.log_id
  ;

  /*
    Получение родительской ветки.
  */
  procedure getParentLog
  is
  begin
    outputMessage( '*');
    open
      parentLogCur
    ;
    fetch
      parentLogCur
    into
      parentLog
    ;
    close parentLogCur;
    outputMessage(
      'root log_id: ' || to_char( parentLog.start_log_id)
      || ', dateBegin={' || to_char( parentLog.date_ins, 'dd.mm.yyyy hh24:mi:ss') || '}'
      || ', operator_id=' || to_char( parentLog.operator_id)
    );
  end getParentLog;

begin
  getParentLog();
  outputMessage( '>');
  for logMessage in logCur( parentLog.start_log_id) loop
    outputMessage(
      logMessage.message_line
    );
  end loop;
  outputMessage( '>');
end showLastRunLog;

/* func: isOfMask
  Проверка соответствия строки маскам.

  Параметры:
  testString                  - строка
  maskList                    - список масок
*/
function isOfMask(
  testString varchar2
  , maskList varchar2
)
return integer
is
  currentMaskList varchar2(1000);
  safeCycle integer := 0;
begin
  currentMaskList := upper( maskList || ',' );
  loop
    exit when
      currentMaskList is null
      or
        upper( testString )
        like substr( currentMaskList , 1, instr( currentMaskList, ',' ) - 1 )
        escape '\'
    ;
    currentMaskList := substr( currentMaskList, instr( currentMaskList, ',' ) + 1 );
    safeCycle := safeCycle + 1;
    if SafeCycle > 100 then
      raise_application_error(
        pkg_Error.ProcessError,
        'Произошло зацикливание в функции isOfMask'
      );
    end if;
  end loop;
  if
    upper( testString)
      like substr( currentMaskList , 1, instr( currentMaskList, ',' ) - 1)
    escape '\'
  then
    return 1;
  else
    return 0;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка проверки соответствия строки маскам ('
        || ' testString="' || testString || '"'
        || ', maskList="' || maskList || '"'
        || ')'
      )
    , true
  );
end isOfMask;

/* iproc: execBatchOperation
  Выполняет операцию с батчами.

  waitBatchCount              - количество батчей, которые не завершили выполнение
  retryBatchCount            - количество батчей, которые завершили выполнение
                                в статусе повторить попытку
  batchShortNameList          - список масок батчей через ","
  operationCode               - код операции ( см. <pkg_SchedulerTest::Константы);
  operationStartDate          - дата начала выполнения операции
*/
procedure execBatchOperation(
  waitBatchCount out integer
  , retryBatchCount out integer
  , batchShortNameList varchar2
  , operationCode varchar2
  , operationStartDate date
)
is
  pragma autonomous_transaction;

  operatorId integer := pkg_Operator.getCurrentUserId();

  nextDate date;

  -- Общее количество батчей
  batchCount integer;

  -- Количество обработанных батчей
  processedCount integer := 0;

  -- Курсор для получения списка батчей
  cursor batchCur is
    select
      batch_short_name
      , batch_id
      , activated_flag
      , last_start_date
      , sid
      , batch_result_id
    from
      v_sch_batch
    where
      pkg_SchedulerTest.isOfMask( batch_short_name, batchShortNameList) = 1
  ;

begin
  if operationCode in(
    WaitRun_OperCode
    , WaitSession_OperCode
    , WaitAbsentSession_OperCode
  )
  then
    waitBatchCount := 0;
    retryBatchCount := 0;
  else
    outputMessage( '*');
    outputMessage( '*');
  end if;
  batchCount := 0;
  for batch in batchCur loop
    if operationCode in (
      Activate_OperCode, Deactivate_OperCode, ShowLog_OperCode
    )
    then
      outputMessage(
        rpad(
          case
            operationCode
          when
            Activate_OperCode
          then
            'Activate batch: '
          when
            Deactivate_OperCode
          then
            'Deactivate batch: '
          when
            ShowLog_OperCode
          then
            'Show log: '
          end
          , 20
        )
        ||  rpad( batch.batch_short_name, 30)
        || ' ( batch_id =' || lpad( batch.batch_id, 5)
        || ')'
      );
    end if;
    case
      operationCode
    when
      Activate_OperCode
    then
      if batch.activated_flag = 0 then
        pkg_Scheduler.activateBatch(
          batchId => batch.batch_id
          , operatorId => operatorId
        );
        processedCount := processedCount + 1;
      end if;
    when
      Deactivate_OperCode
    then
      if batch.activated_flag = 1 then
        pkg_Scheduler.deactivateBatch(
          batchId => batch.batch_id
          , operatorId => operatorId
        );
        processedCount := processedCount + 1;
      end if;
    when
      Run_OperCode
    then
      nextDate := sysdate;
      pkg_Scheduler.setNextDate(
        batchId => batch.batch_id
        , operatorId => operatorId
        , nextDate => nextDate
      );
      outputMessage(
        rpad( batch.batch_short_name, 30)
        || ' ( batch_id =' || lpad( batch.batch_id, 3)
        || ')   - set date '
        || to_char( nextDate, 'dd.mm.yy hh24:mi:ss')
      );
    when
      ShowLog_OperCode
    then
      showLastRunLog(
        batchId => batch.batch_id
      );
    when
      WaitRun_OperCode
    then
      logger.trace(
        'batch: ' || batch.batch_short_name
        || ': last_start_date={' || to_char( batch.last_start_date, 'dd.mm.yyyy hh24:mi:ss') || '}'
        || ', operationStartDate={' || to_char( operationStartDate, 'dd.mm.yyyy hh24:mi:ss') || '}'
        || ', sid=' || to_char( batch.sid)
      );
      if
        batch.last_start_date < operationStartDate
        or batch.last_start_date is null
        or batch.sid is not null
      then
        waitBatchCount := waitBatchCount + 1;
      elsif  batch.batch_result_id = pkg_Scheduler.RetryAttempt_ResultId then
        retryBatchCount := retryBatchCount + 1;
      end if;
      logger.trace(
        'waitBatchCount=' || to_char( waitBatchCount)
      );
    when
      WaitSession_OperCode
    then
      if
        batch.sid is null
        and batch.last_start_date < operationStartDate
      then
        waitBatchCount := waitBatchCount + 1;
      end if;
    when
      WaitAbsentSession_OperCode
    then
      if
        batch.sid is not null
      then
        waitBatchCount := waitBatchCount + 1;
      end if;
    end case;
    batchCount := batchCount + 1;
  end loop;
  if batchCount = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'No batches found'
    );
  end if;
  commit;
  if operationCode in (
    Activate_OperCode, Deactivate_OperCode
  ) then
    outputMessage(
      '- done ( processed: ' || to_char( processedCount)
      || ', checked: ' || to_char( batchCount)
      || ')'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка выполнения операции над батчами ('
        || ' operationCode="' || operationCode || '"'
        || ')'
      )
    , true
  );
end execBatchOperation;

/* proc: execBatchOperation
  Выполняет операцию с батчами.

  batchShortNameList          - список масок батчей через ","
  operationCode               - код операции ( см. <pkg_SchedulerTest::Константы);
*/
procedure execBatchOperation(
  batchShortNameList varchar2
  , operationCode varchar2
)
is
  -- Количество батчей, для которых мы ожидаем завершение выполнения
  waitBatchCount integer;
  lastWaitBatchCount integer;
  retryBatchCount integer;

    -- Время завершения ожидания
  limitDate date := sysdate + 1 / 24 / 60;
  -- Дата начала операции
  operationStartDate date := sysdate;
begin
  if operationCode in
  (
    WaitAbsentSession_OperCode
    , WaitSession_OperCode
  ) then
    loop
      execBatchOperation(
        waitBatchCount => waitBatchCount
        , retryBatchCount => retryBatchCount
        , batchShortNameList => batchShortNameList
        , operationCode => operationCode
        , operationStartDate => operationStartDate
      );
      if lastWaitBatchCount <> waitBatchCount
        or lastWaitBatchCount is null
      then
        lastWaitBatchCount := waitBatchCount;
        outputMessage(
          to_char( sysdate, 'hh24:mi:ss')
          || ': Waiting for batches: left: ' || to_char( lastWaitBatchCount)
        );
      end if;
      exit when
        waitBatchCount = 0 or sysdate >= limitDate
      ;
      dbms_lock.sleep( 1);
    end loop;
    if waitBatchCount > 0 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Batches not started or not finished: ' || to_char( waitBatchCount)
      );
    end if;
  else
    execBatchOperation(
      waitBatchCount => waitBatchCount
      , retryBatchCount => retryBatchCount
      , batchShortNameList => batchShortNameList
      , operationCode => operationCode
      , operationStartDate => operationStartDate
    );
  end if;
  logger.trace(
    'waitBatchCount=' || to_char( waitBatchCount)
    || ', retryBatchCount=' || to_char( retryBatchCount)
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка выполнения операции над батчами ('
        || ' operationCode="' || operationCode || '"'
        || ')'
      )
    , true
  );
end execBatchOperation;

/* proc: testBatch
  Активирует батчи, запускает, ожидает завершения работы и деактивирует, затем
  показывает лог выполнения.

  Параметры:
  batchShortNameList          - список масок батчей через ","
  batchWaitSecond             - время ожидания работы батча в секундах ( по
                                истечению генерируется исключение,
                                по-умолчанию минута);
  raiseWhenRetryFlag          - генерация исключения в случае статуса выполнения
                                батча "Повторить попытку". По-умолчанию генерировать.
*/
procedure testBatch(
  batchShortNameList varchar2
  , batchWaitSecond number := null
  , raiseWhenRetryFlag number := null
)
is


    -- Время завершения ожидания
  limitDate date := sysdate
    + coalesce( batchWaitSecond, 60) / 24 / 60 / 60;

  -- Количество батчей, для которых мы ожидаем завершение выполнения
  waitBatchCount integer;
  lastWaitBatchCount integer;
  -- Количество батчей, которые завершились в статусе "Повторить попытку"
  retryBatchCount integer;

  -- Дата / время запуска батчей
  operationStartDate date;

-- testBatch
begin
  execBatchOperation(
    batchShortNameList => batchShortNameList
    , operationCode => Activate_OperCode
  );
  operationStartDate := sysdate;
  execBatchOperation(
    batchShortNameList => batchShortNameList
    , operationCode => Run_OperCode
  );
  outputMessage( '*');
  outputMessage( '*');
  loop
    execBatchOperation(
      waitBatchCount => waitBatchCount
      , retryBatchCount => retryBatchCount
      , batchShortNameList => batchShortNameList
      , operationCode => WaitRun_OperCode
      , operationStartDate => operationStartDate
    );
    if lastWaitBatchCount <> waitBatchCount
      or lastWaitBatchCount is null
    then
      lastWaitBatchCount := waitBatchCount;
      outputMessage(
        to_char( sysdate, 'hh24:mi:ss')
        || ': Waiting for batches: left: ' || to_char( lastWaitBatchCount)
      );
    end if;
    exit when
      waitBatchCount = 0 or sysdate >= limitDate
    ;
    dbms_lock.sleep( 1);
  end loop;
  execBatchOperation(
    batchShortNameList => batchShortNameList
    , operationCode => Deactivate_OperCode
  );
  if waitBatchCount > 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Batches not started or not finished: ' || to_char( waitBatchCount)
    );
  end if;
  execBatchOperation(
    batchShortNameList => batchShortNameList
    , operationCode => ShowLog_OperCode
  );
  if coalesce( raiseWhenRetryFlag, 1) = 1 and
     retryBatchCount > 0
  then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Some batches completed with status "Retry": ' || to_char( retryBatchCount)
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка тестирования батчей ('
        || ' batchShortNameList="' || batchShortNameList || '"'
        || ')'
      )
    , true
  );
end testBatch;

/* proc: testLoadBatch
  Тестирование загрузки батча.

  Параметры:
  jobWhat                     - plsql-код задания ( job)
  batchXmlText                - спефикация пакетного задания в виде xml
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений если не указаны
                                  параметры jobWhat и batchXmlText, иначе
                                  только 1 тест ( загрузка задания и батча))
*/
procedure testLoadBatch(
  jobWhat varchar2 := null
  , batchXmlText clob := null
  , testCaseNumber integer := null
)
is

  pragma autonomous_transaction;

  Batch_ShortName constant varchar2(50) := 'TestBatch';
  Batch_ShortName2 constant varchar2(50) := 'TestBatch_2';
  Check_String constant varchar2(50) := 'Hello world!';
  Option_Name constant varchar2(50) := 'Hello';

  Config_RetrialCount1 constant integer := 11;
  Config_RetrialCount2 constant integer := 17;

  -- Порядковый номер очередного тестового случая
  checkCaseNumber integer := 0;

  -- Модули для тестирования
  moduleName1 varchar2(100);
  moduleName2 varchar2(100);

  batch sch_batch%rowtype;



  /*
    Подготовка данных для теста.
  */
  procedure prepareData
  is

    cursor batchCur is
      select
        t.batch_id
      from
        sch_batch t
      where
        t.batch_short_name in (
          Batch_ShortName
          , Batch_ShortName2
        )
      order by
        t.batch_short_name
    ;

  begin
    moduleName1 := pkg_ModuleInfoTest.getTestModuleName( 'Module1');
    moduleName2 := pkg_ModuleInfoTest.getTestModuleName( 'Module2');
    for rec in batchCur loop
      pkg_SchedulerLoad.deleteBatch(
        batchId => rec.batch_id
      );
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при подгоовке данных для теста.'
        )
      , true
    );
  end prepareData;



  /*
    Получение данных батча.
  */
  procedure getBatch(
    batchShortName varchar2 := Batch_ShortName
  )
  is
  begin
    select
      *
    into
      batch
    from
      sch_batch
    where
      batch_short_name = batchShortName
    ;
  end getBatch;



  /*
    Загружает тестовый job.
  */
  procedure loadJob(
    cinfo varchar2
    , moduleName varchar2 := moduleName1
    , moduleSvnRoot varchar2 := null
    , moduleInitialSvnPath varchar2 := null
    , jobShortName varchar2
    , jobName varchar2 := null
    , jobWhat varchar2 := null
    , description varchar2 := null
    , publicFlag number := null
    , batchShortName varchar2 := null
    , skipCheckJob number := null
  )
  is

    jobInfo varchar2(200) :=
      ' ( job_short_name="' || jobShortName || '"'
      || ', batch_short_name="' || batchShortName || '"'
      || ')'
    ;

    moduleId integer;

    jbr sch_job%rowtype;

  begin
    pkg_SchedulerLoad.loadJob(
      moduleName                => moduleName
      , moduleSvnRoot           => moduleSvnRoot
      , moduleInitialSvnPath    => moduleInitialSvnPath
      , jobShortName            => jobShortName
      , jobName                 => coalesce( jobName, 'Тестовый job')
      , jobWhat                 => coalesce( jobWhat, 'null;')
      , description             => coalesce( description, 'Тестовый job')
      , publicFlag              => publicFlag
      , batchShortName          => batchShortName
      , skipCheckJob            => skipCheckJob
    );
    moduleId := pkg_ModuleInfo.getModuleId(
      moduleName          => moduleName
      , svnRoot           => moduleSvnRoot
      , initialSvnPath    => moduleInitialSvnPath
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'sch_job'
      , filterCondition       =>
          'module_id = ' || moduleId
          || ' and job_short_name = ''' || jobShortName || ''''
          || ' and batch_short_name'
            || case when batchShortName is not null  then
                ' = ''' || batchShortName || ''''
              else
                ' is null'
              end
      , expectedRowCount      => 1
      , failMessageText       =>
          cinfo || 'Задание не найдено'
          || jobInfo
    );
    if not pkg_TestUtility.isTestFailed() then
      select
        t.*
      into jbr
      from
        sch_job t
      where
        t.module_id = moduleId
        and t.job_short_name = jobShortName
        and (
          t.batch_short_name = batchShortName
          or coalesce( batchShortName, t.batch_short_name) is null
        )
      ;
      pkg_TestUtility.compareChar(
        actualString      => jbr.public_flag
        , expectedString  => coalesce( publicFlag, 0)
        , failMessageText =>
            cinfo || 'Некорректное значение public_flag'
            || jobInfo
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при загрузке тестового задания ('
          || ' cinfo="' || cinfo || '"'
          || ', jobShortName="' || jobShortName || '"'
          || ', batchShortName="' || batchShortName || '"'
          || ', publicFlag=' || publicFlag
          || ').'
        )
      , true
    );
  end loadJob;



  /*
    Загружает тестовый батч
  */
  procedure loadBatch(
    cinfo varchar2
    , moduleName varchar2 := moduleName1
    , batchShortName varchar2 := Batch_ShortName
    , setNewBatchFlag pls_integer := null
    , xmlText varchar2
    , updateScheduleFlag number := null
    , skipLoadOption number := null
    , updateOptionValue number := null
  )
  is
  begin
    pkg_SchedulerLoad.loadBatch(
      moduleName              => moduleName
      , moduleSvnRoot         => null
      , moduleInitialSvnPath  => null
      , batchShortName        => batchShortName
      , xmlText               => xmlText
      , updateScheduleFlag    => updateScheduleFlag
      , skipLoadOption        => skipLoadOption
      , updateOptionValue     => updateOptionValue
    );

    -- Если нужно корректируем date_ins, т.к. по нему определяется "новый"
    -- батч или нет, что влияет на обновление значений параметров
    if setNewBatchFlag is not null then
      update
        sch_batch t
      set
        t.date_ins =
          case when setNewBatchFlag = 1 then
            greatest( t.date_ins, sysdate - 23/24)
          else
            least( t.date_ins, sysdate - 1)
          end
      where
        t.batch_short_name = Batch_ShortName
      ;
    end if;

    getBatch( batchShortName => batchShortName);
    pkg_TestUtility.compareChar(
      actualString        => batch.module_id
      , expectedString    => pkg_ModuleInfo.getModuleId( moduleName)
      , failMessageText   =>
          cinfo || 'Некорректное значение module_id'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при загрузке тестового батча ('
          || ' cinfo="' || cinfo || '"'
          || ', moduleName="' || moduleName || '"'
          || ', batchShortName="' || batchShortName || '"'
          || ').'
        )
      , true
    );
  end loadBatch;




  /*
    Определяет необходимость проверки тестового случая.
  */
  function isCheckCase(
    caseInfo out varchar2
    , caseDescription varchar2
    , nextCaseUsedCount pls_integer := null
  )
  return boolean
  is
  begin
    checkCaseNumber := checkCaseNumber + 1;
    caseInfo :=
      'CASE ' || to_char( checkCaseNumber)
      || ' "' || caseDescription || '": '
    ;
    if pkg_TestUtility.isTestFailed()
          or testCaseNumber is not null
            and testCaseNumber
              not between checkCaseNumber
                and checkCaseNumber + coalesce( nextCaseUsedCount, 0)
        then
      return false;
    end if;
    logger.info( '*** ' || caseInfo);
    return true;
  end isCheckCase;



  /*
    Проверка загрузки батча.
  */
  procedure checkLoadBatch(
    nextCaseUsedCount integer
  )
  is

    Case_Name constant varchar2(100) :=
      'загрузка батча'
    ;

    cinfo varchar2(200);

  begin
    if not isCheckCase( cinfo, Case_Name, nextCaseUsedCount) then
      return;
    end if;
    loadJob(
      cinfo             => cinfo
      , batchShortName  => Batch_ShortName
      , jobShortName    => 'process'
      , jobWhat         => coalesce(
          jobWhat
          ,
'declare

  procedure compareChar(
    actualString varchar2
    , expectedString varchar2
    , failMessageText varchar2
  )
  is
  begin
    if coalesce(
            nullif( actualString, expectedString)
            , nullif( expectedString, actualString)
          ) is not null
        then
      raise_application_error(
        pkg_Error.ProcessError
        , failMessageText
          || '': "'' || actualString || ''"''
      );
    end if;
  end compareChar;

begin
  sch_batch_option_t( ''' || Batch_ShortName || ''').setString(
    ''' || Option_Name || '''
    , ''' || Check_String || '''
  );

  -- getContextDate
  compareChar(
    to_char(
      pkg_Scheduler.getContextDate( ''DateOpt'')
      , ''dd.mm.yyyy hh24:mi:ss''
    )
    , ''01.05.2001 18:59:09''
    , ''getContextDate: bad value for DateOpt''
  );

  -- getContextNumber
  compareChar(
    pkg_Scheduler.getContextNumber( ''CheckPointList'')
    , -1.05
    , ''getContextNumber: bad value for CheckPointList''
  );
  compareChar(
    pkg_Scheduler.getContextNumber( ''CheckPointList'', valueIndex => 3)
    , 8
    , ''getContextNumber[3]: bad value for CheckPointList[3]''
  );

  -- getContextString
  compareChar(
    pkg_Scheduler.getContextString( ''Simple'', riseException => 1)
    , null
    , ''getContextString: bad value for Simple''
  );

  -- getContextValueCount
  compareChar(
    pkg_Scheduler.getContextValueCount( ''CheckPointList'')
    , 3
    , ''getContextValueCount: bad value for CheckPointList''
  );
end;'
        )
    );
    loadBatch(
      cinfo             => cinfo
      , xmlText         => coalesce( batchXmlText,
to_clob(
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>Тестовый батч модуля Scheduler ( создан pkg_SchedulerTest.testLoadBatch)</name>
  <batch_config>
    <retry_count>' || to_char( Config_RetrialCount1) || '</retry_count>
    <retry_interval>30</retry_interval>
    <schedule>
      <name>every day at 03.26</name>
      <interval type="hh24">
        <value>03</value>
      </interval>
      <interval type="mi">
        <value>26</value>
      </interval>
    </schedule>
    <option type="string" short_name="' || Option_Name || '" name="Тестовая опция">
      <value>' || Check_String || '</value>
    </option>
    <option short_name="Simple" type="string" name="Мимальный параметр"/>
    <option short_name="DateOpt" type="date" name="Параметр типа дата" access_level="full" encryption="0" description="Параметр типа дата ( описание)">
      <value>01.05.2001 18:59:09</value>
      <value instance="Db1">05.05.2001</value>
      <value instance="Db2">05.05.2001 05:00:00</value>
    </option>
    <option short_name="DateList" type="date" access_level="value"
          name="Параметр со списком дат"
          description="Параметр со списком дат ( описание)"
        >
      <value_list instance="Db1">
        <item>01.05.2002 18:59:09</item>
        <item>02.05.2002</item>
        <item>03.05.2002 05:00:00</item>
      </value_list>
      <value_list instance="Db3" separator="|"/>
    </option>
    <option short_name="NumberOpt" type="number" name="Числовой параметр" access_level="read">
      <prod_value>81.5</prod_value>
      <test_value>.5</test_value>
    </option>
    <option short_name="NumberList" type="number" name="Параметр со списком чисел">
      <test_value_list/>
    </option>
    <option short_name="CheckPointList" type="number" name="Параметр со точек проверки">
      <prod_value_list>
        <item>80.98</item>
      </prod_value_list>
      <test_value_list>
        <item>-1.05</item>
        <item>0.05</item>
        <item>8</item>
      </test_value_list>
    </option>
    <option short_name="Password" type="string" name="Пароль" access_level="value" encryption="' || pkg_OptionCrypto.isCryptoAvailable() || '">
      <test_value instance="Db1">jdk15</test_value>
      <test_value instance="Db2">jdk16</test_value>
    </option>
    <option short_name="FieldList" type="string" name="Список полей">
      <prod_value_list separator=",">
        <item>ContractNumber</item>
        <item>LastName</item>
        <item>FirstName</item>
      </prod_value_list>
    </option>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
  <content id="2" job="process">
    <condition id="1">true</condition>
  </content>
  <content id="3" job="commit" module="Scheduler">
    <condition id="2">true</condition>
  </content>
  <content id="4" job="retry_batch" module="Scheduler">
    <condition id="3">error</condition>
    <condition id="3">skip</condition>
  </content>
</batch>'))
    );
    commit;
    pkg_SchedulerTest.testBatch( Batch_ShortName);
    if jobWhat is null then
      pkg_TestUtility.compareChar(
        expectedString => Check_String
        , actualString =>
            sch_batch_option_t( Batch_ShortName).getString( Option_Name)
        , failMessageText =>
            cinfo || 'compare option'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке: ' || Case_Name
        )
      , true
    );
  end checkLoadBatch;



  /*
    Проверка загрузки конфигурации
  */
  procedure checkLoadBatchConfig
  is

    Case_Name constant varchar2(100) :=
      'загрузка конфигурации'
    ;

    cinfo varchar2(200);

  begin
    if not isCheckCase( cinfo, Case_Name) then
      return;
    end if;
    getBatch();
    pkg_TestUtility.compareChar(
      expectedString => to_char( Config_RetrialCount1)
      , actualString => to_char( batch.retrial_count)
      , failMessageText =>
          cinfo || 'compare retrial count before config loading'
    );
    pkg_SchedulerLoad.loadBatchConfig(
      moduleName => moduleName1
      , xmlText =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch_config short_name="' || Batch_ShortName || '">
  <retry_count>' || to_char( Config_RetrialCount2) || '</retry_count>
  <retry_interval>30</retry_interval>
 </batch_config>
'
      , updateScheduleFlag => 1
    );
    getBatch();
    pkg_TestUtility.compareChar(
      expectedString => to_char( Config_RetrialCount2)
      , actualString => to_char( batch.retrial_count)
      , failMessageText =>
          cinfo || 'compare retrial count after config loading'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке: ' || Case_Name
        )
      , true
    );
  end checkLoadBatchConfig;



  /*
    Проверка изменения видимости задания.
  */
  procedure checkChangeJobVisibility
  is

    Case_Name constant varchar2(100) :=
      'изменение видимости задания'
    ;

    cinfo varchar2(200);

  begin
    if not isCheckCase( cinfo, Case_Name) then
      return;
    end if;
    loadJob(
      cinfo             => cinfo
      , jobShortName    => 'testMovedJob'
      , batchShortName  => Batch_ShortName
    );

    -- ... : батч -> модуль
    loadJob(
      cinfo             => cinfo
      , jobShortName    => 'testMovedJob'
      , batchShortName  => null
    );

    -- ... : модуль -> public
    loadJob(
      cinfo             => cinfo
      , jobShortName    => 'testMovedJob'
      , batchShortName  => null
      , publicFlag      => 1
    );

    -- ... : public -> батч
    loadJob(
      cinfo             => cinfo
      , jobShortName    => 'testMovedJob'
      , batchShortName  => Batch_ShortName
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке: ' || Case_Name
        )
      , true
    );
  end checkChangeJobVisibility;



  /*
    Проверка изменения модуля батча.
  */
  procedure checkChangeModule
  is

    Case_Name constant varchar2(100) := 'изменение модуля батча';

    -- Описание тестового случая
    cinfo varchar2(200);

  begin
    if not isCheckCase( cinfo, Case_Name) then
      return;
    end if;

    loadBatch(
      cinfo                 => cinfo
      , moduleName          => moduleName1
      , setNewBatchFlag     => 0
      , xmlText             =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>Test batch</name>
  <batch_config>
    <option short_name="NumOpt" type="number" name="Числовой параметр">
      <value>101</value>
    </option>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
</batch>'
    );

    sch_batch_option_t( Batch_ShortName).setNumber( 'NumOpt', 1049);
    loadBatch(
      cinfo                 => cinfo
      , moduleName          => moduleName2
      , xmlText             =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>Test batch</name>
  <batch_config>
    <option short_name="NumOpt" type="number" name="Числовой параметр">
      <value>102</value>
    </option>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
</batch>'
      , updateOptionValue   => null
    );
    pkg_TestUtility.compareChar(
      actualString      =>
          sch_batch_option_t( Batch_ShortName).getNumber( 'NumOpt')
      , expectedString  => to_char( 1049)
      , failMessageText =>
          cinfo || 'Не сохранено значение параметра'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке: ' || Case_Name
        )
      , true
    );
  end checkChangeModule;



  /*
    Проверка переименования батча.
  */
  procedure checkRenameBatch
  is

    Case_Name constant varchar2(100) := 'переименование батча';

    -- Описание тестового случая
    cinfo varchar2(200);

    batchId integer;

  begin
    if not isCheckCase( cinfo, Case_Name) then
      return;
    end if;

    loadBatch(
      cinfo                 => cinfo
      , xmlText             =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>Test batch</name>
  <batch_config>
    <option short_name="SaveDay" type="number" name="Срок хранения">
      <value>30</value>
    </option>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
</batch>'
      , updateOptionValue   => 1
    );
    sch_batch_option_t( Batch_ShortName).setNumber( 'SaveDay', 62);
    batchId := batch.batch_id;

    pkg_SchedulerLoad.renameBatch(
      batchShortName      => Batch_ShortName
      , newBatchShortName => Batch_ShortName2
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'sch_batch'
      , filterCondition       =>
          'batch_id = ' || batchId
          || ' and batch_short_name = ''' || Batch_ShortName2 || ''''
      , expectedRowCount      => 1
      , failMessageText       =>
          cinfo || 'Переименование не выполнено'
    );
    pkg_TestUtility.compareChar(
      actualString      =>
          sch_batch_option_t( Batch_ShortName2).getNumber( 'SaveDay')
      , expectedString  => to_char( 62)
      , failMessageText =>
          cinfo || 'Не сохранено значение параметра'
    );

    sch_batch_option_t( Batch_ShortName2).setNumber( 'SaveDay', 63);

    pkg_SchedulerLoad.renameBatch(
      batchId             => batchId
      , newBatchShortName => Batch_ShortName
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'sch_batch'
      , filterCondition       =>
          'batch_id = ' || batchId
          || ' and batch_short_name = ''' || Batch_ShortName || ''''
      , expectedRowCount      => 1
      , failMessageText       =>
          cinfo || 'Переименование по Id не выполнено'
    );
    pkg_TestUtility.compareChar(
      actualString      =>
          sch_batch_option_t( Batch_ShortName).getNumber( 'SaveDay')
      , expectedString  => to_char( 63)
      , failMessageText =>
          cinfo || 'Не сохранено значение параметра'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке: ' || Case_Name
        )
      , true
    );
  end checkRenameBatch;



-- testLoadBatch
begin
  pkg_TestUtility.beginTest( 'testLoadBatch');

  prepareData();

  checkLoadBatch( nextCaseUsedCount => 1);

  if jobWhat is null and batchXmlText is null then
    checkLoadBatchConfig();

    checkChangeJobVisibility();
    checkChangeModule();
    checkRenameBatch();
  end if;

  pkg_SchedulerLoad.deleteBatch( Batch_ShortName);
  pkg_TestUtility.endTest();
  commit;
end testLoadBatch;

/* proc: testNlsLanguage
  Проверка языка сообщения.

  Параметры:
  nlsLanguage                 - значение переменной NLS_LANGUAGE
*/
procedure testNlsLanguage(
  nlsLanguage varchar2
)
is
  Batch_ShortName constant varchar2(50) := 'TestBatch';
-- testNlsLanguage
begin
  pkg_SchedulerLoad.loadJob(
    moduleName => pkg_Scheduler.Module_Name
    , batchShortName => Batch_ShortName
    , jobShortName => 'process'
    , jobName => 'Тестовый job'
    , description => 'Тестовый job'
    , jobWhat =>
        'begin
           if 1/0 = 0 then
             null;
           end if;
        end;'
  );
  pkg_SchedulerLoad.loadBatch(
    moduleName => pkg_Scheduler.Module_Name
    , batchShortName => Batch_ShortName
    , xmlText =>
to_clob(
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>Test batch</name>
  <batch_config>
    <retry_count>1</retry_count>
    <retry_interval>30</retry_interval>
    <nls_language>' || nlsLanguage || '</nls_language>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
  <content id="2" job="process">
    <condition id="1">true</condition>
  </content>
  <content id="3" job="commit" module="Scheduler">
    <condition id="2">true</condition>
  </content>
  <content id="4" job="retry_batch" module="Scheduler">
    <condition id="3">error</condition>
    <condition id="3">skip</condition>
  </content>
</batch>')
  );
  commit;
  pkg_SchedulerTest.testBatch(
    Batch_ShortName
    , raiseWhenRetryFlag => 0
  );
  commit;
end testNlsLanguage;

/* proc: testWebApi
  Тест API для web-интерфейса.
*/
procedure testWebApi
is

  pragma autonomous_transaction;

  -- Id модуля для тестирования
  moduleId integer := pkg_SchedulerMain.getModuleId();

  -- Тестовый батч
  Batch_ShortName constant varchar2(50) := 'TestBatch_WebApi';
  Batch_Name constant varchar2(100) :=
    'Тестовый батч ( pkg_SchedulerTest.testWebApi)'
  ;
  batchId integer;

  -- Текущий оператор
  currentOperatorId integer;

  -- Id оператора, указываемый в API-функциях
  testOperatorId integer;



  /*
    Добавляет тестовых батч.
  */
  procedure addTestBatch
  is
  begin
    pkg_SchedulerLoad.loadBatch(
      moduleName => pkg_Scheduler.Module_Name
      , batchShortName => Batch_ShortName
      , xmlText =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>' || Batch_Name || '</name>
  <batch_config>
    <retrial_count>1</retrial_count>
    <retrial_interval>30</retrial_interval>
    <schedule>
      <name>every day at 03.26</name>
      <interval type="hh24">
        <value>03</value>
      </interval>
      <interval type="mi">
        <value>26</value>
      </interval>
    </schedule>
    <option type="string" short_name="TestOption" name="Тестовая опция">
      <value></value>
    </option>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
</batch>'
      );
    commit;

    select
      t.batch_id
    into batchId
    from
      sch_batch t
    where
      t.batch_short_name = Batch_ShortName
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при добавлении тестового батча.'
        )
      , true
    );
  end addTestBatch;



  /*
    Проверка работы функций для настроечных параметров.
  */
  procedure testOptionApi
  is

    optionId integer;
    valueId integer;

    rc sys_refcursor;

  begin
    pkg_TestUtility.beginTest( 'testWebApi: option API');

    -- Создание параметра
    optionId := pkg_Scheduler.createOption(
      batchId                 => batchId
      , optionShortName       => 'DataServerName'
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => null
      , encryptionFlag        => null
        -- должен быть 1 ( по умолчанию)
      , testProdSensitiveFlag => null
      , optionName            => 'Имя основного сервера'
      , optionDescription     => 'Имя основного сервера ( общее значение)'
      , dateValue             => null
      , numberValue           => null
      , stringValue           => 'UsedServer'
      , stringListSeparator   => null
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'option_id = ' || optionId
          || ' and object_short_name = ''' || Batch_ShortName || ''''
          || ' and object_type_short_name = '''
            || pkg_SchedulerMain.Batch_OptionObjTypeSName || ''''
          || ' and string_value = ''UsedServer'''
      , expectedRowCount      => 1
      , failMessageText       =>
          'createOption: Некорректные данные в v_opt_option_value'
    );

    -- Установка текущего значения
    pkg_Scheduler.setOptionValue(
      batchId                 => batchId
      , optionId              => optionId
      , dateValue             => null
      , numberValue           => null
      , stringValue           => 'UsedServer2'
      , valueIndex            => null
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'option_id = ' || optionId
          || ' and string_value = ''UsedServer2'''
      , expectedRowCount      => 1
      , failMessageText       =>
          'setOptionValue: Некорректные данные в v_opt_option_value'
    );

    -- Изменение параметра
    pkg_Scheduler.updateOption(
      batchId                 => batchId
      , optionId              => optionId
      , valueTypeCode         => pkg_OptionMain.String_ValueTypeCode
      , valueListFlag         => 0
      , encryptionFlag        => 0
      , testProdSensitiveFlag => 1
      , optionName            => 'Имя основного сервера (2)'
      , optionDescription     => ''
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'option_id = ' || optionId
          || ' and option_name = ''Имя основного сервера (2)'''
      , expectedRowCount      => 1
      , failMessageText       =>
          'updateOption: Некорректные данные в v_opt_option_value'
    );

    -- Поиск параметров
    rc := pkg_Scheduler.findOption(
      batchId                 => batchId
      , optionId              => null
      , maxRowCount           => 5
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 1 + 1
      , failMessageText       =>
          'findOption(batchId): Неожиданное число записей в курсоре'
    );

    rc := pkg_Scheduler.findOption(
      batchId                 => null
      , optionId              => optionId
      , maxRowCount           => 5
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 1
      , failMessageText       =>
          'findOption(optionId): Неожиданное число записей в курсоре'
    );

    -- Добавляем второе значение другого типа
    valueId := pkg_Scheduler.createValue(
      batchId                   => batchId
      , optionId                => optionId
      , prodValueFlag           => pkg_Common.isProduction()
      , instanceName            => pkg_Common.getInstanceName()
      , dateValue               => null
      , numberValue             => null
      , stringValue             => 'UsedServer3'
      , stringListSeparator     => null
      , operatorId              => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'option_id = ' || optionId
          || ' and value_id = ' || valueId
          || ' and string_value = ''UsedServer3'''
      , expectedRowCount      => 1
      , failMessageText       =>
          'createValue: Некорректные данные в v_opt_option_value'
    );

    -- Изменение значения
    pkg_Scheduler.updateValue(
      batchId                   => batchId
      , valueId                 => valueId
      , dateValue               => null
      , numberValue             => null
      , stringValue             => 'UsedServer4'
      , valueIndex              => null
      , operatorId              => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'value_id = ' || valueId
          || ' and string_value = ''UsedServer4'''
      , expectedRowCount      => 1
      , failMessageText       =>
          'updateValue: Некорректные данные в v_opt_option_value'
    );

    -- Поиск значения
    rc := pkg_Scheduler.findValue(
      batchId                 => batchId
      , valueId               => null
      , optionId              => optionId
      , maxRowCount           => 20
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 2
      , failMessageText       =>
          'findValue: Неожиданное число записей в курсоре'
    );

    -- Удаление значения
    pkg_Scheduler.deleteValue(
      batchId                 => batchId
      , valueId               => valueId
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'option_id = ' || optionId
          || ' and value_id = ' || valueId
      , expectedRowCount      => 0
      , failMessageText       =>
          'deleteValue: Некорректные данные в v_opt_option_value'
    );

    -- Удаление параметра
    pkg_Scheduler.deleteOption(
      batchId                 => batchId
      , optionId              => optionId
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      tableName               => 'v_opt_option_value'
      , filterCondition       =>
          'option_id = ' || optionId
      , expectedRowCount      => 0
      , failMessageText       =>
          'deleteOption: Некорректные данные в v_opt_option_value'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при тестировании функций для настроечных параметров.'
        )
      , true
    );
  end testOptionApi;



  /*
    Тест функций %ModuleRolePrivilege.
  */
  procedure testModuleRolePrivilegeApi
  is

    -- Роль для тестирования
    roleId integer;

    moduleRolePrivilegeId integer;

    rc sys_refcursor;

  begin
    select
      t.role_id
    into roleId
    from
      v_op_role t
    where
      t.role_short_name = 'AllBatchAdmin'
    ;

    moduleRolePrivilegeId := pkg_Scheduler.createModuleRolePrivilege(
      moduleId        => moduleId
      , roleId        => roleId
      , privilegeCode => pkg_Scheduler.Read_PrivilegeCode
      , operatorId    => testOperatorId
    );

    rc := pkg_Scheduler.findModuleRolePrivilege(
      moduleRolePrivilegeId   => moduleRolePrivilegeId
      , moduleId              => moduleId
      , privilegeCode         => pkg_Scheduler.Read_PrivilegeCode
      , roleId                => roleId
      , maxRowCount           => 5
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 1
      , failMessageText       =>
          'findModuleRolePrivilege: Неожиданное число записей в курсоре'
    );

    pkg_Scheduler.deleteModuleRolePrivilege(
      moduleRolePrivilegeId => moduleRolePrivilegeId
      , operatorId          => testOperatorId
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при тестировании функций %ModuleRolePrivilege.'
        )
      , true
    );
  end testModuleRolePrivilegeApi;



  /*
    Тест функций %Batch.
  */
  procedure testBatchApi
  is

    rc sys_refcursor;

  begin
    rc := pkg_Scheduler.findBatch(
      batchId                 => batchId
      , batchShortName        => Batch_ShortName
      , batchName             => Batch_Name
      , moduleId              => moduleId
      , retrialCount          => null
      , lastDateFrom          => null
      , lastDateTo            => null
      , rowCount              => 5
      , operatorId            => testOperatorId
    );
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => 1
      , failMessageText       =>
          'findBatch: Неожиданное число записей в курсоре'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при тестировании функций %Batch.'
        )
      , true
    );
  end testBatchApi;



  /*
    Тест функций справочников.
  */
  procedure testDictionaryFunction
  is

    rc sys_refcursor;

    nRow integer;

  begin
    rc := pkg_Scheduler.findModule();
    select
      count(*)
    into nRow
    from
      v_mod_module md
    where
      exists
        (
        select
          null
        from
          sch_batch bt
        where
          bt.module_id = md.module_id
        )
    ;
    pkg_TestUtility.compareRowCount(
      rc                      => rc
      , expectedRowCount      => nRow
      , failMessageText       =>
          'findModule: Неожиданное число записей в курсоре'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при тестировании функций справочников.'
        )
      , true
    );
  end testDictionaryFunction;



-- testWebApi
begin
  addTestBatch();

  -- Очищаем текущего оператора, чтобы эмулировать работу через
  -- web-интерфейс
  currentOperatorId := pkg_Operator.getCurrentUserId();
  pkg_Operator.logoff();
  testOperatorId := currentOperatorId;

  testOptionApi();

  pkg_TestUtility.beginTest( 'testWebApi: other API');
  testModuleRolePrivilegeApi();
  testBatchApi();
  testDictionaryFunction();
  pkg_TestUtility.endTest();

  -- Восстанавливаем регистрацию оператора
  pkg_Operator.setCurrentUserId( currentOperatorId);

  pkg_SchedulerLoad.deleteBatch( Batch_ShortName);
  commit;
exception when others then
  pkg_Operator.setCurrentUserId( currentOperatorId);
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при тестировании API для web-интерфейса.'
      )
    , true
  );
end testWebApi;

/* proc: testBatchOption
  Тест типа sch_batch_option_t.
*/
procedure testBatchOption
is

  pragma autonomous_transaction;

  -- Тестовый батч
  Batch_ShortName constant varchar2(50) := 'TestBatch_BatchOption';
  batchId integer;



  /*
    Добавляет тестовых батч.
  */
  procedure addTestBatch
  is
  begin
    pkg_SchedulerLoad.loadBatch(
      moduleName => pkg_Scheduler.Module_Name
      , batchShortName => Batch_ShortName
      , xmlText =>
'<?xml version="1.0" encoding="Windows-1251"?>
<batch short_name="' || Batch_ShortName || '">
  <name>Тестовый батч ( pkg_SchedulerTest.testBatchOption)</name>
  <batch_config>
    <option type="string" short_name="TestOption1" name="Тестовая опция 1">
      <value>Test1</value>
    </option>
    <option type="string" short_name="TestOption2" name="Тестовая опция 2">
      <value>Test2</value>
    </option>
  </batch_config>
  <content id="1" job="initialization" module="Scheduler"/>
</batch>'
      );
    commit;

    select
      t.batch_id
    into batchId
    from
      sch_batch t
    where
      t.batch_short_name = Batch_ShortName
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при добавлении тестового батча.'
        )
      , true
    );
  end addTestBatch;



  /*
    Выполняет тест.
  */
  procedure processTest
  is

    opt sch_batch_option_t;

  begin
    pkg_TestUtility.beginTest( 'testBatchOption: sch_batch_option_t');

    -- Параметры несуществующего батча ( объект должен создаваться)
    opt := sch_batch_option_t(
      batchShortName  => 'TestBatch_BatchOption_???'
      , moduleId      => pkg_SchedulerMain.getModuleId()
    );

    -- конструктор по batchShortName
    opt := sch_batch_option_t( Batch_ShortName);
    pkg_TestUtility.compareChar(
      expectedString => opt.getString( 'TestOption1')
      , actualString => 'Test1'
      , failMessageText => 'Некорректное значение параметра TestOption1'
    );

    -- конструктор по batchId
    opt := sch_batch_option_t( batchId);
    pkg_TestUtility.compareChar(
      expectedString => opt.getObjectShortName()
      , actualString => Batch_ShortName
      , failMessageText => 'Некорректное значение getObjectShortName()'
    );
    pkg_TestUtility.compareChar(
      expectedString => opt.getString( 'TestOption2')
      , actualString => 'Test2'
      , failMessageText => 'Некорректное значение параметра TestOption2'
    );

    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при выполнении теста.'
        )
      , true
    );
  end processTest;



-- testBatchOption
begin
  addTestBatch();
  processTest();
  pkg_SchedulerLoad.deleteBatch( Batch_ShortName);
  commit;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при тестировании типа sch_batch_option_t.'
      )
    , true
  );
end testBatchOption;

end pkg_SchedulerTest;
/
