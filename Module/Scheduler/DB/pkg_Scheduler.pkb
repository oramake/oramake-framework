create or replace package body pkg_Scheduler is
/* package body: pkg_Scheduler::body */



/* group: Константы */

/* const: Default_RunDate
  Дата запуска пакета, используемая по умолчанию при отсутствии расписания.
*/
Default_RunDate constant date := date '4000-01-01';

/* iconst: Default_NlsLanguage
  Значение NLS_LANGUAGE по-умолчанию.
*/
Default_NlsLanguage constant varchar2(40) := 'AMERICAN';



/* group: Типы */



/* group: Переменные пакетного задания */

/* itype: VariableNameT
  Тип для имени переменной.
*/
subtype VariableNameT is varchar2(100);

/* itype: ValueColT
  Значения переменной ( для переменной может быть задан список значений).
*/
type ValueColT is table of anydata;

/* itype: VariableT
  Переменная.
*/
type VariableT is record
(
  valueCol ValueColT
  , isConstant boolean
);

/* itype: VariableColT
  Массив переменных.
*/
type VariableColT is table of VariableT index by VariableNameT;



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_Scheduler'
);

/* ivar: gBatchLevel
  Уровень вложенности текущего выполняемого пакета (начиная с 1).
*/
gBatchLevel pls_integer;

/* ivar: gVariableCol
  Массив переменных.
*/
gVariableCol VariableColT;

/* ivar: gSendNotifyFlag
  Флаг автоматической рассылки уведомления об ошибках/предупреждениях при
  выполнении пакетов.
*/
gSendNotifyFlag integer := 1;



/* group: Функции */



/* group: Интерфейсные функции */

/* iproc: checkPrivilege
  Проверяет наличие прав у оператора.

  Параметры:
  operatorId                  - Id оператора
                                ( null для проверки текущего оператора)
  batchId                     - Id пакета
  privilegeCode               - код привилегии
  moduleId                    - Id модуля

  Замечание:
  - если указан moduleId, то проверяются права на все пакеты модуля
    ( batchId игнорируется);
*/
procedure checkPrivilege(
  operatorId integer
  , batchId integer
  , privilegeCode varchar2
  , moduleId integer := null
)
is

  -- Id оператора, для которого проверяются права
  checkOperatorId integer;

  -- Результат проверки
  isOk integer;

-- checkPrivilege
begin
  checkOperatorId := coalesce( operatorId, pkg_Operator.getCurrentUserId());
  if moduleId is not null then
    select
      1 as is_ok
    into isOk
    from
      dual
    where
      exists
        (
        select
          null
        from
          v_sch_role_privilege rp
          inner join v_op_operator_role opr
            on opr.role_id = rp.role_id
        where
          rp.module_id = moduleId
          and rp.privilege_code = privilegeCode
          and opr.operator_id = checkOperatorId
        )
    ;
  else
    select
      1 as is_ok
    into isOk
    from
      dual
    where
      exists
        (
        select
          null
        from
          v_sch_role_privilege rp
          inner join v_op_operator_role opr
            on opr.role_id = rp.role_id
        where
          rp.batch_id = batchId
          and rp.privilege_code = privilegeCode
          and opr.operator_id = checkOperatorId
        )
    ;
  end if;
exception when NO_DATA_FOUND then
  raise_application_error(
    pkg_Error.RigthIsMissed
    , 'У оператора отсутствуют необходимые привилегии на работу с '
      || case when moduleId is not null then
          'пакетами модуля'
         else
          'пакетом'
        end
      || ' ('
      || ' operator_id=' || operatorId
      || case when nullif( checkOperatorId, operatorId) is not null then
          ', checkOperatorId=' || checkOperatorId
        end
      || case when moduleId is not null then
          ', module_id=' || moduleId
        else
          ', batch_id=' || batchId
        end
      || ', privilege_code="' || privilegeCode || '"'
      || ').'
  );
end checkPrivilege;



/* group: Пакетные задания */

/* func: getOracleJobName
  Получение имени задания dbms_scheduler.

  Параметры:
  batchId                     - id батча
*/
function getOracleJobName(
  batchId integer
)
return varchar2
is
-- getOracleJobName
begin
  return 'SCHEDULER_' || to_char(batchId);
end getOracleJobName;

/* proc: updateBatch
  Изменяет пакет.

  Параметры:
  batchId                     - Id пакета
  batchName                   - название пакета
  retrialCount                - число перезапусков
  retrialTimeout              - интервал между перезапусками
  operatorId                  - Id оператора
*/
procedure updateBatch(
  batchId integer
  , batchName varchar2
  , retrialCount integer
  , retrialTimeout interval day to second
  , operatorId integer
)
is

  cursor curBatch( batchId integer) is
    select
      b.*
    from
      sch_batch b
    where
      b.batch_id = batchId
    for update nowait
  ;

  -- Флаг наличия записи
  isFound boolean := false;

-- updateBatch
begin
  for rec in curBatch( batchId) loop
    isFound := true;

    checkPrivilege( operatorId, batchId, Write_PrivilegeCode);

    if coalesce( rec.batch_name_rus <> batchName
            , coalesce( rec.batch_name_rus, batchName) is not null)
        or coalesce( rec.retrial_count <> retrialCount
            , coalesce( rec.retrial_count, retrialCount) is not null)
        or coalesce( rec.retrial_timeout <> retrialTimeout
            , coalesce( rec.retrial_timeout, retrialTimeout) is not null)
        then

      update
        sch_batch b
      set
        b.batch_name_rus = batchName
        , b.retrial_count = retrialCount
        , b.retrial_timeout = retrialTimeout
      where current of curBatch;
    end if;
  end loop;

  -- Проверка на отсутствие записи
  if not isFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Пакет не найден.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При изменении пакета возникла ошибка ('
      || ' batch_id=' || to_char( batchId)
      || ').'
    , true
  );
end updateBatch;

/* proc: activateBatch
  Ставит пакет заданий на выполнение в соответствии с расписанием (либо
  пересчитывает дату запуска и пытается восстановить работоспособность уже
  установленного на выполнение пакета).  Очищает номер повторной попытки (если
  он был установлен).

  Параметры:
  batchId                     - Id задания
  operatorId                  - Id оператора
*/
procedure activateBatch(
  batchId integer
  , operatorId integer
)
is
  -- Изменяемый пакет
  cursor curBatch( batchId integer) is
    select
      b.batch_id
      , b.batch_short_name
      , b.batch_name_rus
      , b.oracle_job_id
      , b.retrial_number
      , (
        select
          b.batch_id
        from
          user_scheduler_jobs j
        where
          -- getOracleJobName
          j.job_name = 'SCHEDULER_' || to_char(b.batch_id)
        )
        as current_job_id
      , (
        select
          j.next_run_date
        from
          user_scheduler_jobs j
        where
          -- getOracleJobName
          j.job_name = 'SCHEDULER_' || to_char(b.batch_id)
        )
        as next_date
      , b.nls_territory
      , b.nls_language
    from
      sch_batch b
    where
      b.batch_id = batchId
    for update of b.oracle_job_id nowait
  ;

  rec curBatch%rowtype;

  -- Имя пакета, выводимое в лог
  batchLogName varchar2(500);
  info varchar2(4000);
  -- Информационное сообщение Новая дата запуска пакета
  newDate date;

  -- Сохранённые NLS-параметры сессии
  sessionNlsLanguage varchar2(40);
  sessionNlsTerritory varchar2(40);

  -- имя job для dbms_scheduler
  oracleJobName varchar(1000);

  /*
    Сохранение параметров NLS сессии.
  */
  procedure saveNlsParameter
  is
  begin
    select
      value
    into
      sessionNlsLanguage
    from
      nls_session_parameters
    where
      parameter = 'NLS_LANGUAGE'
    ;
    select
      value
    into
      sessionNlsTerritory
    from
      nls_session_parameters
    where
      parameter = 'NLS_TERRITORY'
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Ошибка сохранение NLS-параметров сессии'
      , true
    );
  end saveNlsParameter;

  /*
    Установка NLS-параметров для батча.
  */
  procedure setBatchNlsParameter
  is
    usedNlsLanguage varchar2(40) := coalesce( rec.nls_language, Default_NlsLanguage);
  begin
    if sessionNlsLanguage <> usedNlsLanguage then
      execute immediate
        'alter session set nls_language=''' || usedNlsLanguage || '''';
    end if;
    -- Поле должно быть задано, чтобы менять параметр сессии
    if sessionNlsTerritory <> rec.nls_territory then
      execute immediate
        'alter session set nls_territory=''' || rec.nls_territory || '''';
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Ошибка установки NLS-параметров'
      , true
    );
  end setBatchNlsParameter;

  /*
    Восстановление NLS параметров сессии.
  */
  procedure restoreNlsParameters
  is
  begin
    if sessionNlsLanguage <> coalesce( rec.nls_language, Default_NlsLanguage) then
      execute immediate
        'alter session set nls_language=''' || sessionNlsLanguage || ''''
      ;
    end if;
    if sessionNlsTerritory <> rec.nls_territory then
      execute immediate
        'alter session set nls_territory=''' || sessionNlsTerritory || ''''
      ;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Ошибка восстановления NLS-параметров'
      , true
    );
  end restoreNlsParameters;

--ActivateBatch
begin
  saveNlsParameter();
  savepoint pkg_Scheduler_ActivateBatch;
  -- Проверяем права доступа
  checkPrivilege(operatorId, batchId, Exec_PrivilegeCode);
  pkg_Operator.setCurrentUserId( operatorId => operatorId);
  open curBatch( batchId);
  fetch curBatch into rec;
  -- Точное сообщение при отсутствии пакета
  if curBatch%NOTFOUND then
    raise_application_error(
      pkg_Error.BatchNotFound
      , 'Пакет не найден.'
    );
  end if;
  setBatchNlsParameter();
  batchLogName :=
    '"' || rec.batch_name_rus || '" [' || rec.batch_short_name || ']';
  -- Опеределяем дату запуска
  newDate := calcNextDate(batchId);
  -- Ошибка, если расписание не задано
  if newDate is null then
    raise_application_error(
      pkg_Error.ScheduleNotSet
      , 'Не задано расписание запуска пакета.'
    );
  end if;
  oracleJobName := getOracleJobName(batchId => rec.batch_id);
  -- Добавляем новое задание Oracle
  if rec.current_job_id is null then
    logger.trace('create_job: ' || oracleJobName);
    dbms_scheduler.create_job(
      job_name => oracleJobName
    , job_type => 'PLSQL_BLOCK'
    , auto_drop => false
    , job_action =>
'pkg_Scheduler.execBatch(' || to_char(batchId)
|| ' /* batch: ' || rec.batch_short_name || ' */, next_date);'
--    , start_date => newDate
    , enabled => true
    , comments => 'Scheduler: ' || rec.batch_short_name
    , repeat_interval => 'sysdate + 1000000'
    );
    dbms_scheduler.set_attribute(
      name => oracleJobName
    , attribute => 'RESTARTABLE'
    , value => true
    );
    dbms_scheduler.set_attribute(
      name => oracleJobName
    , attribute => 'STOP_ON_WINDOW_CLOSE'
    , value => false
    );
    dbms_scheduler.set_attribute_null(
      name => oracleJobName
    , attribute => 'MAX_FAILURES'
    );
    dbms_scheduler.set_attribute_null(
      name => oracleJobName
    , attribute => 'MAX_RUNS'
    );
    logger.trace('job created: ' || oracleJobName);
    rec.current_job_id := rec.batch_id;
    -- Связываем пакет с заданием Oracle
    update
      sch_batch
    set
      oracle_job_id = rec.current_job_id
    where current of curBatch
    ;
    rec.oracle_job_id := rec.current_job_id;
    info := 'Активирован пакет ' || batchLogName
      || ' ( batch_id=' || rec.batch_id
      || ', дата запуска '
      || to_char( newDate, 'dd.mm.yyyy hh24:mi:ss') || ').'
      ;
  -- Устанавливаем новую дату запуска
  elsif newDate != rec.next_date then
    dbms_scheduler.disable(name => oracleJobName);
    dbms_scheduler.set_attribute(
      name => oracleJobName
    , attribute => 'START_DATE'
    , value => newDate
    );
    dbms_scheduler.enable(name => oracleJobName);
    info := 'Дата запуска пакета ' || batchLogName
      || ' изменена на '
        || to_char( newDate, 'dd.mm.yyyy hh24:mi:ss') || '.'
      ;
  end if;
  -- Очищаем номер попытки, если он был
  if rec.retrial_number is not null then
    update
      sch_batch
    set
      retrial_number = null
    where current of curBatch
    ;
    info :=
      case when info is null
        then
          'Сброшен номер повторной попытки для пакета ' || batchLogName || '.'
        else
          info || ' и сброшен номер повторной попытки.'
      end
    ;
  end if;
  -- Пишем информационное сообщение
  if info is not null then
    logger.info(
      messageText             => info
      , messageLabel          => pkg_SchedulerMain.Activate_BatchMsgLabel
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => batchId
    );
  end if;
  close curBatch;
  restoreNlsParameters();
exception when others then
  if curBatch%ISOPEN then
    close curBatch;
  end if;
  -- Обеспечиваем неделимость операций
  rollback to pkg_Scheduler_ActivateBatch;
  restoreNlsParameters();
  raise_application_error(              --Дополняем информацию об ошибке
    pkg_Error.ErrorInfo
    , 'Ошибка при активации пакета '
      || coalesce( batchLogName, '( batch_id=' || batchId || ')')
      || '.'
    , true
  );
end activateBatch;

/* proc: deactivateBatch
  Прекращает периодическое выполнение пакета заданий

  Параметры:
  batchId                     - Id задания
  operatorId                  - Id оператора
*/
procedure deactivateBatch(
  batchId integer
  , operatorId integer
)
is
  -- Изменяемый пакет
  cursor curBatch( batchId integer) is
    select
      b.batch_id
      , b.batch_short_name
      , b.batch_name_rus
      , b.oracle_job_id
      , (
        select
          b.batch_id
        from
          user_scheduler_jobs j
        where
          -- getOracleJobName
          j.job_name = 'SCHEDULER_' || to_char(b.batch_id)
        )
        as current_job_id
    from
      sch_batch b
    where
      b.batch_id = batchId
    for update of b.oracle_job_id nowait
  ;

  rec curBatch%rowtype;

  cursor curHandler(batchId integer) is
select
  ss.sid
  , ss.serial#
  , ss.audsid as sessionid
from
  user_scheduler_running_jobs jr
  inner join v$session ss
    on jr.session_id = ss.sid
where
  -- getOracleJobName
  jr.job_name = 'SCHEDULER_' || to_char(batchId)
  and exists
    (
    select
      null
    from
      v$db_pipes p
    where
      (
      p.name like
        '%.COMMANDPIPE\_' || to_char( ss.sid) || '\_' || to_char( ss.serial#)
        escape '\'
      or
      p.name like
        '%.COMMANDPIPE\_' || to_char( ss.sid) || to_char( ss.serial#)
        escape '\'
      )
    )
  ;

  hdr curHandler%rowtype;
  -- Имя пакета, выводимое в лог
  batchLogName varchar2(500);
  info varchar2(4000);

  -- имя job для dbms_scheduler
  oracleJobName varchar(1000);

  /*
    Остановка обработчика, если батч является обработчиком.
  */
  procedure checkStopHandler
  is
  begin
    open curHandler(batchId);
    fetch curHandler into hdr;
    close curHandler;
    if hdr.sid is not null then
      pkg_Scheduler.stopHandler(
        batchId     => batchId
      , sid         => hdr.sid
      , serial#     => hdr.serial#
      , operatorId  => operatorId
      , sessionid   => hdr.sessionid
      );
    end if;
  end checkStopHandler;

--DeactivateBatch
begin
  savepoint pkg_Scheduler_DeactivateBatch;
  -- Проверяем права доступа
  checkPrivilege( operatorId, batchId, Exec_PrivilegeCode);
  pkg_Operator.setCurrentUserId( operatorId => operatorId);
  open curBatch( batchId);
  fetch curBatch into rec;
  -- Точное сообщение при отсутствии пакета
  if curBatch%NOTFOUND then
    raise_application_error(
      pkg_Error.BatchNotFound
      , 'Пакет не найден.'
    );
  end if;
  batchLogName :=
    '"' || rec.batch_name_rus || '" [' || rec.batch_short_name || ']';
  oracleJobName := getOracleJobName(batchId => rec.batch_id);
  checkStopHandler();
  -- Удаляем задание Oracle
  if rec.current_job_id is not null then
    logger.trace('drop job: ' || oracleJobName);
    dbms_scheduler.drop_job(
      job_name => oracleJobName
    , defer    => true
    );
  end if;
  -- Отвязываем пакет от задания Oracle
  if rec.oracle_job_id is not null then
    update
      sch_batch
    set
      oracle_job_id = null
      , retrial_number = null
    where current of curBatch
    ;
  end if;
  -- Пишем информационное сообщение
  if rec.oracle_job_id is not null then
    logger.info(
      messageText             =>
          'Деактивирован пакет ' || batchLogName
          || ' ('
            || ' oracle_job_id=' || rec.oracle_job_id
            || case when rec.current_job_id is null then
              ', на момент деактивации отсутствовало назначенное пакету задание'
              end
            || case when hdr.sid is not null then
                ', выполнена остановка обработчика'
                || ' sid=' || to_char(hdr.sid)
                || ' serial#=' || to_char(hdr.serial#)
                || ' sessionid=' || to_char(hdr.sessionid)
              end
          || ').'
      , messageLabel          => pkg_SchedulerMain.Deactivate_BatchMsgLabel
      , messageValue          => hdr.sessionid
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => batchId
    );
  end if;
  close curBatch;
exception when others then
  if curBatch%ISOPEN then
    close curBatch;
  end if;
  -- Обеспечиваем неделимость операций
  rollback to pkg_Scheduler_DeactivateBatch;
  raise_application_error(              --Дополняем информацию об ошибке
    pkg_Error.ErrorInfo
    , 'Ошибка при деактивации пакета '
      || coalesce( batchLogName, '( batch_id=' || batchId || ')')
      || '.'
    , true
  );
end deactivateBatch;

/* proc: setNextDate
  Устанавливает дату следующего запуска активированного пакета.

  batchId                     - Id пакета
  operatorId                  - Id оператора
  nextDate                    - дата следующего запуска
                                ( по умолчанию немедленно)
*/
procedure setNextDate(
  batchId integer
  , operatorId integer
  , nextDate date := sysdate
)
is

  -- Данные пакетного задания
  bth sch_batch%rowtype;

  -- Имя пакета, выводимое в лог
  batchLogName varchar2(500);

  -- имя job для dbms_scheduler
  oracleJobName varchar(1000);

begin
  savepoint pkg_Scheduler_SetNextDate;

  -- Проверяем права доступа
  checkPrivilege( operatorId, batchId, Exec_PrivilegeCode);
  pkg_Operator.setCurrentUserId( operatorId => operatorId);
  pkg_SchedulerMain.getBatch( bth, batchId);
  batchLogName :=
    '"' || bth.batch_name_rus || '" [' || bth.batch_short_name || ']'
  ;
  oracleJobName := getOracleJobName(batchId => batchId);
  if bth.oracle_job_id is not null then
    -- Устанавливаем дату запуска
    dbms_scheduler.disable(name => oracleJobName);
    dbms_scheduler.set_attribute(
      name      => oracleJobName
    , attribute => 'START_DATE'
    , value     => nextDate
    );
    dbms_scheduler.enable(name => oracleJobName);
    -- Пишем информационное сообщение
    logger.info(
      messageText             =>
          'Дата запуска пакета '
          || batchLogName
          || ' изменена на '
          || to_char( nextDate, 'dd.mm.yyyy hh24:mi:ss')
          || '.'
      , messageLabel          => pkg_SchedulerMain.SetNextDate_BatchMsgLabel
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => batchId
    );
  else
    raise_application_error(
      pkg_Error.ProcessError
      , 'Пакет не был активирован.'
    );
  end if;
exception when others then
  rollback to pkg_Scheduler_SetNextDate;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при установке даты следующего запуска пакета'
        || case when batchLogName is not null then
            ' ' || batchLogName
          end
        || ' ('
        || ' batch_id=' || batchId
        || ', nextDate=' || to_char( nextDate, 'dd.mm.yyyy hh24:mi:ss')
        || ').'
      )
    , true
  );
end setNextDate;

/* proc: abortBatch
  Прерывает выполнение пакета заданий.

  Параметры:
  batchId                     - Id задания
  operatorId                  - Id оператора

  Замечание:
  - в случае успешного выполнения внутри процедуры выполняется commit.
*/
procedure abortBatch(
  batchId integer
  , operatorId integer
)
is
  -- Изменяемый пакет
  cursor curBatch( batchId integer) is
   select
      b.batch_short_name
      , b.batch_name_rus
      , ss.sessionid
      , ss.sid
      , ss.serial#
    from
      sch_batch b
    left join
      (
      select /*+ordered*/
        jr.job_name
        , ss.audsid as sessionid
        , ss.sid
        , ss.serial#
      from
        user_scheduler_running_jobs jr
        inner join v$session ss
          on jr.session_id = ss.sid
      ) ss
    on
      -- getOracleJobName
      ss.job_name = 'SCHEDULER_' || to_char(b.batch_id)
    where
      b.batch_id = batchId
    for update of b.batch_short_name nowait
  ;

  rec curBatch%rowtype;

  -- Имя пакета, выводимое в лог
  batchLogName varchar2(500);
  info varchar2(4000);

  -- Признак начала выполнения операции
  isStarted boolean := false;

--AbortBatch
begin
  -- Проверяем права доступа
  checkPrivilege( operatorId, batchId, Exec_PrivilegeCode);
  pkg_Operator.setCurrentUserId( operatorId => operatorId);
  open curBatch( batchId);
  fetch curBatch into rec;
  if curBatch%NOTFOUND then
    raise_application_error(
      pkg_Error.BatchNotFound
      , 'Пакет не найден.'
    );
  end if;
  batchLogName :=
    '"' || rec.batch_name_rus || '" [' || rec.batch_short_name || ']';
  if rec.sid is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Пакет в данный момент не выполняется ( сессия не найдена).'
    );
  end if;
  logger.info(
    messageText             =>
        'Начало прерывания выполнение пакета ' || batchLogName
        || ', сессия sid=' || rec.sid || ', serial#=' || rec.serial# || '.'
    , messageLabel          => pkg_SchedulerMain.Abort_BatchMsgLabel
    , messageValue          => rec.sid
    , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
    , contextValueId        => batchId
    , openContextFlag       => 1
  );
  isStarted := true;
  execute immediate
    'alter system kill session '''
      || rec.sid || ',' || rec.serial#
      || ''' immediate'
  ;
  deactivateBatch(batchId, operatorId);
  activateBatch(batchId, operatorId);
  commit;
  close curBatch;
  logger.info(
    messageText             => 'Выполнение сессии прервано.'
    , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
    , contextValueId        => batchId
    , openContextFlag       => 0
  );
exception when others then
  if curBatch%ISOPEN then
    close curBatch;
  end if;
  info := 'Ошибка при прерывании выполнения пакета '
    || coalesce( batchLogName, 'batch_id=' || batchId )
    || case when rec.sid is not null then
      ', сессия sid=' || rec.sid || ', serial#=' || rec.serial#
      end
    || '.'
  ;
  if isStarted then
    logger.error(
      messageText             =>
          info || chr(10) || logger.getErrorStack( isStackPreserved => 1)
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => batchId
      , openContextFlag       => 0
    );
  end if;
  raise_application_error(              --Дополняем информацию об ошибке
    pkg_Error.ErrorInfo
    , info
    , true
  );
end abortBatch;

/* func: findBatch
  Поиск пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
  batchShortName              - короткое название
  batchName                   - название
  moduleId                    - Id модуля, к которому относится пакетно задание
  retrialCount                - число повторов
  lastDateFrom                - дата последнего запуска с
  lastDateTo                  - дата последнего запуска до
  rowCount                    - максимальное число возвращаемых записей
  operatorId                  - Id оператора, выполняющего операцию ( по
                                умолчанию текущий)

  Возврат ( курсор):
  batch_id                    - Id пакетного задания
  batch_short_name            - короткое название
  batch_name                  - название
  module_id                   - Id модуля
  module_name                 - название модуля
  retrial_count               - число повторов
  retrial_timeout             - интервал между повторами
  oracle_job_id               - Id назначенного задания (устаревший параметр)
  retrial_number              - номер повторного выполнения
  date_ins                    - дата добавления пакетного задания
  operator_id                 - Id оператора, добавившего пакетное задание
  operator_name               - имя оператора, добавившего пакетное задание
                                ( анг.)
  job                         - Id реально существующего задания (устаревшний
                                параметр, ревен batch_id, если задание
                                запущено)
  last_date                   - дата последнего запуска
  this_date                   - дата текущего запуска
  next_date                   - дата следующего запуска
  total_time                  - суммарное время выполнения (устаревшее поле)
  failures                    - число последних последовательных ошибок при
                                запуске через dbms_scheduler
  is_job_broken               - признак отключенного задания (устаревшее поле)
  root_log_id                 - Id корневого лога последнего выполнения
  last_start_date             - дата последнего запуска из лога
  last_log_date               - дата последней записи в логе
  batch_result_id             - Id результата выполнения пакетного задания
  result_name                 - название результата
  error_job_count             - число подзадач, завершившихся ошибкой при
                                последнем выполении
  error_count                 - число ошибок при последнем выполении
  warning_count               - число предупреждений при последнем выполении
  duration_second             - длительность последнего выполнения ( в секундах)
  sid                         - sid сессии, в которой выполняется пакетное
                                задание
  serial                      - serial# сессии, в которой выполняется пакетное
                                задание

  Замечания:
  - показываются только пакетные задания, доступные указанному оператору по
    чтению;
  - значение параметров batchShortName, batchName используется для поиска по
    шаблону ( like) без учета регистра по соответствующим полям;
  - если критериям поиска удовлетворяет больше записей, чем указанное
    максимальное число возвращаемых записей, то записи для возврата отбираются
    случайным образом ( без определенного порядка);
  - поисковые параметры со значением null не влияют на результат поиска;
*/
function findBatch(
  batchId integer := null
  , batchShortName varchar2 := null
  , batchName varchar2 := null
  , moduleId integer := null
  , retrialCount integer := null
  , lastDateFrom date := null
  , lastDateTo date := null
  , rowCount integer := null
  , operatorId integer := null
)
return sys_refcursor
is
  -- Возвращаемый курсор
  rc sys_refcursor;
  -- SQL-запрос
  dSql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
  select
    batch_id
    , batch_short_name
    , batch_name_rus as batch_name
    , vb.module_id
    , md.module_name
    , vb.retrial_count
    , to_char( vb.retrial_timeout) as retrial_timeout
    , vb.oracle_job_id
    , vb.retrial_number
    , vb.date_ins
    , vb.operator_id
    , op.operator_name
    , vb.job
    , vb.last_date
    , vb.this_date
    , vb.next_date
    , cast(null as integer) as vb.total_time
    , vb.failures
    , cast(null as integer) as is_job_broken
    , vb.root_log_id
    , vb.last_start_date
    , vb.last_log_date
    , vb.batch_result_id
    , sr.result_name_rus as result_name
    , vb.error_job_count
    , vb.error_count
    , vb.warning_count
    , vb.duration_second
    , vb.sid
    , vb.serial# as serial
  from
    v_sch_operator_batch vb
    inner join v_mod_module md
      on md.module_id = vb.module_id
    left outer join op_operator op
      on vb.operator_id = op.operator_id
    left outer join sch_result sr
      on vb.batch_result_id = sr.result_id
  where
    vb.read_operator_id = :readOperatorId
  ) a
where
  $(condition)
')
  ;


--FindBatch
begin
  -- Формирование параметров запроса
  dSql.addCondition( 'a.batch_id =', batchId is null);
  dSql.addCondition(
    'upper( a.batch_short_name) like', batchShortName is null
    , 'batchShortName'
  );
  dSql.addCondition(
    'upper( a.batch_name) like', batchName is null
    , 'batchName'
  );
  dSql.addCondition( 'a.module_id =', moduleId is null);
  dSql.addCondition( 'a.retrial_count =', retrialCount is null);
  dSql.addCondition( 'a.last_date >=', lastDateFrom is null, 'lastDateFrom');
  dSql.addCondition( 'a.last_date <=', lastDateTo is null, 'lastDateTo');
  dSql.addCondition( 'rownum <=', rowCount is null, 'rowCount');
  dSql.useCondition( 'condition');
  -- Открытие курсора
  open rc for
    dSql.getSqlText()
  using
    coalesce( operatorId, pkg_Operator.GetCurrentUserId)
    , batchId
    , upper( batchShortName)
    , upper( batchName)
    , moduleId
    , retrialCount
    , lastDateFrom
    , lastDateTo
    , rowCount
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при поиске пакетного задания.'
    , true
  );
end findBatch;



/* group: Расписание запуска */

/* func: createSchedule
  Создает расписание.

  Параметры:
  batchId                     - Id пакета
  scheduleName                - название расписания
  operatorId                  - Id оператора
*/
function createSchedule(
  batchId integer
  , scheduleName varchar2
  , operatorId integer
)
return integer
is
  scheduleId sch_schedule.schedule_id%type;

-- createSchedule
begin
  checkPrivilege( operatorId, batchId, Write_PrivilegeCode);
  insert into
    sch_schedule
  (
    batch_id
    , schedule_name_rus
    , schedule_name_eng
    , operator_id
  )
  values
  (
     batchId
     , scheduleName
     , 'NA'
     , operatorId
  )
  returning schedule_id into scheduleId;
  return scheduleId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При создании расписания для пакета возникла ошибка ('
      || ' batch_id=' || to_char( batchId)
      || ', scheduleName="' || scheduleName || '"'
      || ').'
    , true
  );
end createSchedule;

/* proc: updateSchedule
  Изменяет расписание.

  Параметры:
  scheduleId                  - Id расписания
  scheduleName                - название расписания
  operatorId                  - Id оператора
*/
procedure updateSchedule(
  scheduleId integer
  , scheduleName varchar2
  , operatorId integer
)
is

  cursor curSchedule( scheduleId integer) is
    select
      t.schedule_id
      , t.batch_id
    from
      sch_schedule t
    where
      t.schedule_id = scheduleId
    for update nowait
  ;

  -- Флаг наличия записи
  isFound boolean := false;

--UpdateSchedule
begin
  for rec in curSchedule( scheduleId) loop
    isFound := true;
    checkPrivilege( operatorId, rec.batch_id, Write_PrivilegeCode);
    update
      sch_schedule t
    set
      t.schedule_name_rus = scheduleName
    where current of curSchedule;
  end loop;
  -- Проверка на отсутствие записи
  if not isFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Расписание не найдено.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При изменении расписания возникла ошибка ('
      || ' schedule_id=' || to_char( scheduleId)
      || ').'
    , true
  );
end updateSchedule;

/* proc: deleteSchedule
  Удаляет расписание.

  Параметры:
  scheduleId                  - Id расписания
  operatorId                  - Id оператора
*/
procedure deleteSchedule(
  scheduleId integer
  , operatorId integer
)
is

  cursor curSchedule( scheduleId integer) is
    select
      t.schedule_id
      , t.batch_id
    from
      sch_schedule t
    where
      t.schedule_id = scheduleId
    for update nowait
  ;

  -- Флаг наличия записи
  isFound boolean := false;

--DeleteSchedule
begin
  for rec in curSchedule( scheduleId) loop
    isFound := true;
    checkPrivilege( operatorId, rec.batch_id, Write_PrivilegeCode);
    delete from
      sch_schedule t
    where current of curSchedule;
  end loop;
  -- Проверка на отсутствие записи
  if not isFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Расписание не найдено.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При удалении расписания возникла ошибка ('
      || ' schedule_id=' || to_char( scheduleId)
      || ').'
    , true
  );
end deleteSchedule;

/* func: findSchedule

  Параметры:
    scheduleId                - Уникальный идентификатор
    batchId                    - Идентификатор батча
    maxRowCount                - Количество записей
    operatorId                - Идентификатор текущего пользователя

  Возврат (курсор):
    schedule_id                - Уникальный идентификатор
    batch_id                  - Идентификатор батча
    schedule_name              - Наименование
    date_ins                  - Дата создания
    operator_id                - Идентификатор оператора
    operator_name              - Оператор
*/
function findSchedule
(
    scheduleId  integer := null
  , batchId     integer := null
  , maxRowCount integer := null
  , operatorId  integer := null
) return sys_refcursor
is
  -- возвращаемый курсор
  resultSet sys_refcursor;
  -- строка с запросом
  dSql dyn_dynamic_sql_t := dyn_dynamic_sql_t ( '
    select
        s.schedule_id
      , s.batch_id
      , s.schedule_name_rus as schedule_name
      , s.date_ins
      , s.operator_id
      , op.operator_name
    from sch_schedule s
    inner join op_operator op
      on op.operator_id = s.operator_id
    where $(condition)
  ');
begin

  -- формирование параметров запроса
  dSql.addCondition( 's.schedule_id =', scheduleId is null);
  dSql.addCondition( 's.batch_id =', batchId is null);
  dSql.addCondition( 'rownum <=', maxRowCount is null, 'maxRowCount');
  dSql.useCondition( 'condition');

  open resultSet for dSql.getSqlText()
  using
      scheduleId
    , batchId
    , maxRowCount;

  return resultSet;

end findSchedule;



/* group: Интервалы расписания запуска */

/* func: createInterval
  Создает интервал.

  Параметры:
  scheduleId                  - Id расписания
  intervalTypeCode            - код типа интервала
  minValue                    - минимальное значение
  maxValue                    - максимальное значение
  step                        - шаг ( по умолчанию 1)
  operatorId                  - Id оператора ( по умолчанию текущий)
*/
function createInterval(
  scheduleId integer
  , intervalTypeCode varchar2
  , minValue integer
  , maxValue integer
  , step integer := null
  , operatorId integer := null
)
return integer
is

  intervalId sch_interval.interval_id%type;

  batchId sch_batch.batch_id%type;

--CreateInterval
begin
  -- Получаем Id пакета для проверки прав
  select
    sc.batch_id
  into batchId
  from
    sch_schedule sc
  where
    sc.schedule_id = scheduleId
  ;
  checkPrivilege( operatorId, batchId, Write_PrivilegeCode);
  insert into
    sch_interval
  (
    schedule_id
    , interval_type_code
    , min_value
    , max_value
    , step
    , operator_id
  )
  values
  (
     scheduleId
     , intervalTypeCode
     , minValue
     , maxValue
     , step
     , operatorId
  )
  returning interval_id into intervalId;
  return intervalId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При создании интервала для расписания возникла ошибка ('
      || ' schedule_id=' || to_char( scheduleId)
      || ', intervalTypeCode="' || intervalTypeCode || '"'
      || ', ' || to_char( minValue)
        || '-' || to_char( maxValue)
        || '/' || to_char( step)
      || ').'
    , true
  );
end createInterval;

/* proc: updateInterval
  Изменяет интервал.

  Параметры:
  intervalId                  - Id интервала
  intervalTypeCode            - код типа интервала
  minValue                    - минимальное значение
  maxValue                    - максимальное значение
  step                        - шаг
  operatorId                  - Id оператора
*/
procedure updateInterval(
  intervalId integer
  , intervalTypeCode varchar2
  , minValue integer
  , maxValue integer
  , step integer
  , operatorId integer
)
is

  cursor curInterval( intervalId integer) is
    select
      t.interval_id
      , sc.batch_id
    from
      sch_interval t
      inner join sch_schedule sc
        on sc.schedule_id = t.schedule_id
    where
      t.interval_id = intervalId
    for update of t.interval_id nowait
  ;

  -- Флаг наличия записи
  isFound boolean := false;

--UpdateInterval
begin
  for rec in curInterval( intervalId) loop
    isFound := true;
    checkPrivilege( operatorId, rec.batch_id, Write_PrivilegeCode);
    update
      sch_interval t
    set
      t.interval_type_code = intervalTypeCode
      , t.min_value = minValue
      , t.max_value = maxValue
      , t.step = updateInterval.step
    where current of curInterval;
  end loop;
  -- Проверка на отсутствие записи
  if not isFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Интервал не найден.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При изменении интервала возникла ошибка ('
      || ' interval_id=' || to_char( intervalId)
      || ').'
    , true
  );
end updateInterval;

/* proc: deleteInterval
  Удаляет интервал.

  Параметры:
  intervalId                  - Id интервала
  operatorId                  - Id оператора
*/
procedure deleteInterval(
  intervalId integer
  , operatorId integer
)
is

  cursor curInterval( intervalId integer) is
    select
      t.interval_id
      , sc.batch_id
    from
      sch_interval t
      inner join sch_schedule sc
        on sc.schedule_id = t.schedule_id
    where
      t.interval_id = intervalId
    for update of t.interval_id nowait
  ;

  -- Флаг наличия записи
  isFound boolean := false;

--DeleteInterval
begin
  for rec in curInterval( intervalId) loop
    isFound := true;
    checkPrivilege( operatorId, rec.batch_id, Write_PrivilegeCode);
    delete from
      sch_interval t
    where current of curInterval;
  end loop;
  -- Проверка на отсутствие записи
  if not isFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Интервал не найден.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При удалении интервала возникла ошибка ('
      || ' interval_id=' || to_char( intervalId)
      || ').'
    , true
  );
end DeleteInterval;

/* func: findInterval

  Параметры:
    scheduleId                - Уникальный идентификатор
    batchId                    - Идентификатор батча
    maxRowCount                - Количество записей
    operatorId                - Идентификатор текущего пользователя

  Возврат (курсор):
    interval_id               - Уникальный идентификатор
    schedule_id               - Идентификатор расписания
    interval_type_code        - Код типа интервала
    interval_type_name        - Наименование типа интервала
    min_value                 - Нижняя граница
    max_value                 - Верхняя граница
    step                      - Шаг интервала
    date_ins                  - Дата создания
    operator_id               - Идентификатор оператора
    operator_name             - Оператор
*/
function findInterval
(
    intervalId  integer := null
  , scheduleId  integer := null
  , maxRowCount integer := null
  , operatorId  integer := null
) return sys_refcursor
is
  -- возвращаемый курсор
  resultSet sys_refcursor;
  -- Объект динамического запроса
  dSql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
    select
        i.interval_id
      , i.schedule_id
      , i.interval_type_code
      , it.interval_type_name_rus as interval_type_name
      , i.min_value
      , i.max_value
      , i.step
      , i.date_ins
      , i.operator_id
      , op.operator_name
    from sch_interval i
    inner join sch_interval_type it
      on it.interval_type_code = i.interval_type_code
    inner join op_operator op
      on op.operator_id = i.operator_id
    where $(condition)
  ');
begin

  -- формирование параметров запроса
  dSql.addCondition( 'i.interval_id =', intervalId is null);
  dSql.addCondition( 'i.schedule_id =', scheduleId is null);
  dSql.addCondition( 'rownum <=', maxRowCount is null, 'maxRowCount');
  dSql.useCondition( 'condition');

  open resultSet for dSql.getSqlText()
  using
      intervalId
    , scheduleId
    , maxRowCount;

  return resultSet;

end findInterval;



/* group: Логи */

/* func: findRootLog

  Параметры:
    logId                  - Уникальный идентификатор
    batchId                - Идентификатор батча
    maxRowCount            - Количество записей
    operatorId             - Идентификатор текущего пользователя

  Возврат (курсор):
    log_id                  - Уникальный идентификатор
    batch_id                - Идентификатор батча
    message_type_code       - Код типа сообщения
    message_type_name       - Наименование типа сообщения
    message_text            - Текст сообщения
    date_ins                - Дата создания
    operator_id             - Идентификатор оператора
    operator_name           - Оператор
*/
function findRootLog
(
    logId        integer := null
  , batchId      integer := null
  , maxRowCount  integer := null
  , operatorId  integer := null
) return sys_refcursor
is
  -- возвращаемый курсор
  resultSet sys_refcursor;
  -- Объект динамического запроса
  dSql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
select
  a.*
from
  (
  select
      l.log_id
    , l.batch_id
    , l.message_type_code
    , m.message_type_name_rus as message_type_name
    , l.message_text
    , l.date_ins
    , l.operator_id
    , op.operator_name
  from v_sch_batch_root_log l
  inner join sch_message_type m
    on m.message_type_code = l.message_type_code
  left join op_operator op
    on op.operator_id = l.operator_id
  where $(condition)
  order by
    1 desc
  ) a
where
  $(rownumCondition)
  ');
begin

  -- формирование параметров запроса
  dSql.addCondition( 'l.log_id =', logId is null);
  dSql.addCondition( 'l.batch_id =', batchId is null);
  dSql.useCondition( 'condition');
  dSql.addCondition(
    'rownum <= :maxRowCount', maxRowCount is null
  );
  dSql.useCondition( 'rownumCondition');

  open resultSet for dSql.getSqlText()
  using
      logId
    , batchId
    , maxRowCount;

  return resultSet;

end findRootLog;

/* func: getDetailedLog

  Параметры:
    parentLogId            - Идентификатор родительского лога
    operatorId             - Идентификатор текущего пользователя

  Возврат (курсор):
    log_id                  - Уникальный идентификатор
    parent_log_id           - Идентификатор родительского лога
    message_type_code       - Код типа сообщения
    message_type_name       - Наименование типа сообщения
    message_text            - Текст сообщения
    message_value           - Значение сообщения
    log_level               - Уровень иерархии
    date_ins                - Дата создания
    operator_id             - Идентификатор оператора
    operator_name           - Оператор
*/
function getDetailedLog
(
    parentLogId integer
  , operatorId  integer
) return sys_refcursor
is

  -- возвращаемый курсор
  resultSet sys_refcursor;

  -- Флаг лога с использованием контекста модуля Logging
  isContextLog integer;

begin
  select
    count(*)
  into isContextLog
  from
    lg_log lg
  where
    lg.log_id = parentLogId
    and lg.context_type_id is not null
  ;
  if isContextLog = 1 then

  open resultSet for
    select
        lg.log_id
      , nullif( parentLogId, lg.log_id) as parent_log_id
      , m.message_type_code
      , m.message_type_name_rus as message_type_name
      , coalesce( lg.message_value, lg.context_value_id) as message_value
      , lg.message_text
      , 1 + ( lg.context_level - ccl.open_context_level)
        + case when lg.open_context_flag in ( 1, -1) then 0 else 1 end
        as log_level
      , lg.date_ins
      , lg.operator_id
      , op.operator_name
    from
      v_lg_context_change_log ccl
      inner join lg_log lg
        on lg.sessionid = ccl.sessionid
          and lg.log_id >= ccl.open_log_id
          and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
      left join op_operator op
        on op.operator_id = lg.operator_id
      left join lg_context_type ct
        on ct.context_type_id = lg.context_type_id
      left join sch_message_type m
        on m.message_type_code =
          case ct.context_type_short_name
            when pkg_SchedulerMain.Batch_CtxTpSName then
              case when lg.open_context_flag != 0 then
                Bstart_MessageTypeCode
              else
                Bfinish_MessageTypeCode
              end
            when pkg_SchedulerMain.Job_CtxTpSName then
              case when lg.open_context_flag != 0 then
                Jstart_MessageTypeCode
              else
                Jfinish_MessageTypeCode
              end
            else
              case lg.level_code
                when pkg_Logging.Fatal_LevelCode then
                  Error_MessageTypeCode
                when pkg_Logging.Error_LevelCode then
                  Error_MessageTypeCode
                when pkg_Logging.Warn_LevelCode then
                  Warning_MessageTypeCode
                when pkg_Logging.Info_LevelCode then
                  Info_MessageTypeCode
                else
                  Debug_MessageTypeCode
              end
          end
    where
      ccl.log_id = parentLogId
    order by
      1
  ;

  else

  open resultSet for
  select
      l.log_id
    , l.parent_log_id
    , l.message_type_code
    , m.message_type_name_rus as message_type_name
    , l.message_value
    , l.message_text
    , l.log_level
    , l.date_ins
    , l.operator_id
    , op.operator_name
  from
  (
    select
        l.log_id
      , l.parent_log_id
      , l.message_type_code
      , l.message_value
      , l.message_text
      , level as log_level
      , l.date_ins
      , l.operator_id
    from sch_log l
    start with l.log_id = parentLogId
    connect by prior l.log_id = l.parent_log_id
    order siblings by l.date_ins, l.log_id
  ) l
  inner join sch_message_type m
    on m.message_type_code = l.message_type_code
  left join op_operator op
    on op.operator_id = l.operator_id;

  end if;

  return resultSet;

end getDetailedLog;



/* group: Параметры пакетных заданий */

/* func: createOption
  Создает параметр пакетного задания и задает для него используемое в текущей
  БД значение.

  Параметры:
  batchId                     - Id пакетного задания
  optionShortName             - короткое название параметра
  valueTypeCode               - код типа значения параметра
  valueListFlag               - флаг задания для параметра списка значений
                                указанного типа ( 1 да, 0 нет ( по умолчанию))
  encryptionFlag              - флаг хранения значений параметра в
                                зашифрованном виде
                                ( 1 да, 0 нет ( по умолчанию))
  testProdSensitiveFlag       - флаг указания для значения параметра типа базы
                                данных ( тестовая или промышленная), для
                                которого оно предназначено
                                ( 1 да ( по умолчанию), 0 нет)
  optionName                  - название параметра
  optionDescription           - описание параметра
                                ( по умолчанию отсутствует)
  dateValue                   - значение типа дата
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение
                                ( по умолчанию отсутствует)
  stringListSeparator         - символ, используемый в качестве разделителя в
                                строке со списком строковых значений
                                ( по умолчанию используется ";")
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id параметра.

  Замечания:
  - в случае, если используется список значений, указанное в параметрах
    функции значение сохраняется как первое значение списка;
*/
function createOption(
  batchId integer
  , optionShortName varchar2
  , valueTypeCode varchar2
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , optionName varchar2
  , optionDescription varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , operatorId integer := null
)
return integer
is

  -- Данные пакетного задания
  bth sch_batch%rowtype;

begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  pkg_SchedulerMain.getBatch( bth, batchId);
  return
    pkg_Option.createOption(
      moduleId                  => bth.module_id
      , objectShortName         => bth.batch_short_name
      , objectTypeId            =>
          opt_option_list_t(
              moduleSvnRoot => pkg_SchedulerMain.Module_SvnRoot
            )
            .getObjectTypeId(
              objectTypeShortName => pkg_SchedulerMain.Batch_OptionObjTypeSName
            )
      , optionShortName         => optionShortName
      , valueTypeCode           => valueTypeCode
      , valueListFlag           => valueListFlag
      , encryptionFlag          => encryptionFlag
      , testProdSensitiveFlag   => coalesce( testProdSensitiveFlag, 1)
      , optionName              => optionName
      , optionDescription       => optionDescription
      , dateValue               => dateValue
      , numberValue             => numberValue
      , stringValue             => stringValue
      , stringListSeparator     => stringListSeparator
      , checkRoleFlag           => 0
      , operatorId              => operatorId
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании параметра батча ('
        || ' batchId=' || batchId
        || ', optionShortName="' || optionShortName || '"'
        || ').'
      )
    , true
  );
end createOption;

/* proc: updateOption
  Изменяет параметр пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
  optionId                    - Id параметра
  valueTypeCode               - код типа значения параметра
  valueListFlag               - флаг задания для параметра списка значений
                                указанного типа ( 1 да, 0 нет)
  encryptionFlag              - флаг хранения значений параметра в
                                зашифрованном виде ( 1 да, 0 нет)
  testProdSensitiveFlag       - флаг указания для значения параметра типа базы
                                данных ( тестовая или промышленная), для
                                которого оно предназначено
                                ( 1 да, 0 нет)
  optionName                  - название параметра
  optionDescription           - описание параметра
  operatorId                  - Id оператора ( по умолчанию текущий)

  Замечания:
  - значения, которые не соответствуют новым данным настроечного параметра,
    удаляются;
  - в промышленных БД при изменении знечения testProdSensitiveFlag текущее
    значение параметра сохраняется ( при этом вместо общего значения создается
    значение для промышленной БД или наоборот);
*/
procedure updateOption(
  batchId integer
  , optionId integer
  , valueTypeCode varchar2
  , valueListFlag integer
  , encryptionFlag integer
  , testProdSensitiveFlag integer
  , optionName varchar2
  , optionDescription varchar2
  , operatorId integer := null
)
is
begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  pkg_Option.updateOption(
    optionId                    => optionId
    , valueTypeCode             => valueTypeCode
    , valueListFlag             => valueListFlag
    , encryptionFlag            => encryptionFlag
    , testProdSensitiveFlag     => testProdSensitiveFlag
    , optionName                => optionName
    , optionDescription         => optionDescription
    , checkRoleFlag             => 0
    , operatorId                => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при изменении параметра батча ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end updateOption;

/* proc: setOptionValue
  Задает используемое в текущей БД значение параметра пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
  optionId                    - Id параметра
  dateValue                   - значение типа дата
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение
                                ( по умолчанию отсутствует)
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, 1 можно также указывать при
                                изменении значения параметра, не использующего
                                список значений, 0 для добавления значения в
                                начало списка, -1 для добавления значения в
                                конец списка, если индекс больше числа значений
                                в списке, то добавляются промежуточные
                                null-значения, null в случае установки всего
                                значения ( при этом в случае списка значений
                                получается список из одного указанного
                                значения))
                                ( по умолчанию null)
  operatorId                  - Id оператора ( по умолчанию текущий)
*/
procedure setOptionValue(
  batchId integer
  , optionId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is
begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  pkg_Option.setOptionValue(
    optionId                    => optionId
    , dateValue                 => dateValue
    , numberValue               => numberValue
    , stringValue               => stringValue
    , valueIndex                => valueIndex
    , checkRoleFlag             => 0
    , operatorId                => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при задании используемого значения параметра батча ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end setOptionValue;

/* proc: deleteOption
  Удаляет настроечный параметр.

  Параметры:
  batchId                     - Id пакетного задания
  optionId                    - Id параметра
  operatorId                  - Id оператора ( по умолчанию текущий)
*/
procedure deleteOption(
  batchId integer
  , optionId integer
  , operatorId integer := null
)
is
begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  pkg_Option.deleteOption(
    optionId            => optionId
    , checkRoleFlag     => 0
    , operatorId        => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении параметра батча ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end deleteOption;

/* func: findOption
  Поиск настроечных параметров пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
  optionId                    - Id параметра
                                ( по умолчанию без ограничений)
  maxRowCount                 - максимальное число возвращаемых поиском записей
                                ( по умолчанию без ограничений)
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат ( курсор):
  option_id                   - Id параметра
  value_id                    - Id используемого значения
  option_short_name           - Короткое название параметра
  value_type_code             - Код типа значения параметра
  value_type_name             - Название типа значения параметра
  date_value                  - Значение параметра типа дата
  number_value                - Числовое значение параметра
  string_value                - Строковое значение параметра либо список
                                значений с разделителем, указанным в поле
                                list_separator ( если оно задано)
  list_separator              - символ, используемый в качестве разделителя в
                                списке значений
  value_list_flag             - Флаг задания для параметра списка значений
  encryption_flag             - Флаг хранения значений параметра в
                                зашифрованном виде
  test_prod_sensitive_flag    - Флаг указания для значения параметра типа базы
                                данных ( тестовая или промышленная), для
                                которого оно предназначено
  access_level_code           - Код уровня доступа через интерфейс
  access_level_name           - Описание уровня доступа через интерфейс
  option_name                 - Название параметра
  option_description          - Описание параметра

  Замечания:
  - в возвращаемом курсоре также присутствуют другие недокументированные выше
    поля, которые не должны использоваться в интерфейсе;
*/
function findOption(
  batchId integer
  , optionId integer := null
  , maxRowCount integer := null
  , operatorId integer := null
)
return sys_refcursor
is

  -- Данные пакетного задания
  bth sch_batch%rowtype;

begin
  pkg_SchedulerMain.getBatch( bth, batchId);
  return
    pkg_Option.findOption(
      optionId                  => optionId
      , moduleId                => bth.module_id
      , objectShortName         => bth.batch_short_name
      , objectTypeId            =>
          opt_option_list_t(
              moduleSvnRoot => pkg_SchedulerMain.Module_SvnRoot
            )
            .getObjectTypeId(
              objectTypeShortName => pkg_SchedulerMain.Batch_OptionObjTypeSName
            )
      , maxRowCount             => maxRowCount
      , checkRoleFlag           => 0
      , operatorId              => operatorId
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при поиске настроечных параметров батча ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end findOption;



/* group: Значения параметра пакетного задания */

/* func: createValue
  Создает значение параметра.

  Параметры:
  batchId                     - Id пакетного задания
  optionId                    - Id параметра
  prodValueFlag               - флаг использования значения только в
                                промышленных ( либо тестовых) БД
                                ( 1 только в промышленных БД, 0 только в
                                  тестовых БД, null без ограничений)
  instanceName                - имя экземпляра БД, в которой может
                                использоваться значение
                                ( null без ограничений ( по умолчанию))
  dateValue                   - значение типа дата
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение
                                ( по умолчанию отсутствует)
  stringListSeparator         - символ, используемый в качестве разделителя в
                                строке со списком строковых значений
                                ( по умолчанию используется ";")
  operatorId                  - Id оператора ( по умолчанию текущий)

  Возврат:
  Id значения параметра.

  Замечания:
  - в случае, если используется список значений, указанное в параметрах
    функции значение сохраняется как первое значение списка;
*/
function createValue(
  batchId integer
  , optionId integer
  , prodValueFlag integer
  , instanceName varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , operatorId integer := null
)
return integer
is
begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  return
    pkg_Option.createValue(
      optionId                  => optionId
      , prodValueFlag           => prodValueFlag
      , instanceName            => instanceName
      , dateValue               => dateValue
      , numberValue             => numberValue
      , stringValue             => stringValue
      , stringListSeparator     => stringListSeparator
      , checkRoleFlag           => 0
      , operatorId              => operatorId
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при создании значения параметра батча ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end createValue;

/* proc: updateValue
  Изменяет значение параметра пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
  valueId                     - Id значения
  dateValue                   - значение типа дата
                                ( по умолчанию отсутствует)
  numberValue                 - числовое значение
                                ( по умолчанию отсутствует)
  stringValue                 - строковое значение
                                ( по умолчанию отсутствует)
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, 1 можно также указывать при
                                изменении значения параметра, не использующего
                                список значений, 0 для добавления значения в
                                начало списка, -1 для добавления значения в
                                конец списка, если индекс больше числа значений
                                в списке, то добавляются промежуточные
                                null-значения, null в случае установки всего
                                значения ( при этом в случае списка значений
                                получается список из одного указанного
                                значения))
                                ( по умолчанию null)
  operatorId                  - Id оператора ( по умолчанию текущий)
*/
procedure updateValue(
  batchId integer
  , valueId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
is
begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  pkg_Option.updateValue(
    valueId                     => valueId
    , dateValue                 => dateValue
    , numberValue               => numberValue
    , stringValue               => stringValue
    , valueIndex                => valueIndex
    , checkRoleFlag             => 0
    , operatorId                => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при изменении значения параметра батча ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end updateValue;

/* proc: deleteValue
  Удаляет значение параметра пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
  valueId                     - Id значения параметра
  operatorId                  - Id оператора ( по умолчанию текущий)
*/
procedure deleteValue(
  batchId integer
  , valueId integer
  , operatorId integer := null
)
is
begin
  checkPrivilege( operatorId, batchId, WriteOption_PrivilegeCode);
  pkg_Option.deleteValue(
    valueId                     => valueId
    , checkRoleFlag             => 0
    , operatorId                => operatorId
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении значения ('
        || ' valueId=' || valueId
        || ').'
      )
    , true
  );
end deleteValue;

/* func: findValue
  Поиск значений параметра пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
  valueId                     - Id значения
  optionId                    - Id параметра
  maxRowCount                 - максимальное число возвращаемых поиском записей
  checkRoleFlag               - проверять наличие у оператора прав для
                                выполнения операции
                                ( 1 да ( по умолчанию), 0 нет)
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат ( курсор):
  value_id                    - Id значения
  option_id                   - Id параметра
  used_value_flag             - Флаг текущего используемого в БД значения
                                ( 1 да, иначе null)
  prod_value_flag             - Флаг использования значения только в
                                промышленных ( либо тестовых) БД ( 1 только в
                                промышленных БД, 0 только в тестовых БД, null
                                без ограничений)
  instance_name               - Имя экземпляра БД, в которой может
                                использоваться значение ( в верхнем регистре,
                                null без ограничений)
  value_type_code             - Код типа значения параметра
  value_type_name             - Название типа значения параметра
  list_separator              - символ, используемый в качестве разделителя в
                                списке значений
  encryption_flag             - Флаг хранения значений параметра в
                                зашифрованном виде
  date_value                  - Значение параметра типа дата
  number_value                - Числовое значение параметра
  string_value                - Строковое значение параметра либо список
                                значений с разделителем, указанным в поле
                                list_separator ( если оно задано)

  Замечания:
  - обязательно должно быть указано значение valueId или optionId;
*/
function findValue(
  batchId integer
  , valueId integer := null
  , optionId integer := null
  , maxRowCount integer := null
  , operatorId integer := null
)
return sys_refcursor
is
begin
  return
    pkg_Option.findValue(
      valueId                   => valueId
      , optionId                => optionId
      , maxRowCount             => maxRowCount
      , checkRoleFlag           => 0
      , operatorId              => operatorId
    )
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при поиске значений параметров батча ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end findValue;



/* group: Права ролей на пакетные задания */

/* func: createBatchRole
  Выдает роли привилегию на пакет.

  Параметры:
  batchId                     - Id пакета
  privilegeCode               - код привилегии
  roleId                      - Id роли
  operatorId                  - Id оператора
*/
function createBatchRole(
  batchId integer
  , privilegeCode varchar2
  , roleId integer
  , operatorId integer
)
return integer
is

  batchRoleId sch_batch_role.batch_role_id%type;

--CreateBatchRole
begin
  checkPrivilege( operatorId, batchId, Admin_PrivilegeCode);
  insert into
    sch_batch_role
  (
    batch_id
    , privilege_code
    , role_id
    , operator_id
  )
  values
  (
     batchId
     , privilegeCode
     , roleId
     , operatorId
  )
  returning batch_role_id into batchRoleId;
  return batchRoleId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При выдаче привилегии для роли на пакет возникла ошибка ('
      || ' batch_id=' || to_char( batchId)
      || ', privilege_code="' || privilegeCode || '"'
      || ', role_id=' || to_char( roleId)
      || ').'
    , true
  );
end createBatchRole;

/* proc: deleteBatchRole
  Отбирает у роли привилегию на пакет.

  Параметры:
  batchRoleId                 - Id удаляемой записи
  operatorId                  - Id оператора
*/
procedure deleteBatchRole(
  batchRoleId integer
  , operatorId integer
)
is
  cursor curBatchRole( batchRoleId integer) is
    select
      t.batch_role_id
      , t.batch_id
    from
      sch_batch_role t
    where
      t.batch_role_id = batchRoleId
    for update of t.batch_role_id nowait
  ;

  -- Флаг наличия записи
  isFound boolean := false;

--DeleteBatchRole
begin
  for rec in curBatchRole( batchRoleId) loop
    isFound := true;
    checkPrivilege( operatorId, rec.batch_id, Admin_PrivilegeCode);
    delete from
      sch_batch_role t
    where current of curBatchRole;
  end loop;
  -- Проверка на отсутствие записи
  if not isFound then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Запись не найдена.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'При удалении у роли привилегии на пакет возникла ошибка ('
      || ' batch_role_id=' || to_char( batchRoleId)
      || ').'
    , true
  );
end deleteBatchRole;

/* func: findBatchRole

  Параметры:
    batchRoleId                 - Уникальный идентификатор
    batchId                     - Идентификатор батча
    maxRowCount                 - Количество записей
    operatorId                  - Идентификатор текущего пользователя

  Возврат (курсор):
    batch_role_id               - Уникальный идентификатор
    batch_id                    - Идентификатор батча
    privilege_code              - Код привилегии
    role_id                     - Идентификатор роли
    role_short_name             - Краткое наименование роли
    privilege_name              - Наименование привилегии
    role_name                   - Наименование роли
    date_ins                    - Дата создания
    operator_id                 - Идентификатор оператора
    operator_name               - Оператор
*/
function findBatchRole
(
    batchRoleId integer := null
  , batchId     integer := null
  , maxRowCount  integer := null
  , operatorId  integer := null
) return sys_refcursor
is
  -- возвращаемый курсор
  resultSet sys_refcursor;
  -- Объект динамического запроса
  dSql dyn_dynamic_sql_t := dyn_dynamic_sql_t( '
    select
        b.batch_role_id
      , b.batch_id
      , b.privilege_code
      , b.role_id
      , r.short_name as role_short_name
      , p.privilege_name
      , r.role_name
      , b.date_ins
      , b.operator_id
      , op.operator_name
    from sch_batch_role b
    inner join sch_privilege p
      on p.privilege_code = b.privilege_code
    inner join v_op_role r
      on r.role_id = b.role_id
    inner join op_operator op
      on op.operator_id = b.operator_id
    where $(condition)
  ');
begin

  -- формирование параметров запроса
  dSql.addCondition( 'b.batch_role_id =', batchRoleId is null);
  dSql.addCondition( 'b.batch_id =', batchId is null);
  dSql.addCondition( 'rownum <=', maxRowCount is null, 'maxRowCount');
  dSql.useCondition( 'condition');

  open resultSet for dSql.getSqlText()
  using
      batchRoleId
    , batchId
    , maxRowCount;

  return resultSet;

end findBatchRole;



/* group: Права ролей на пакетные задания модулей */

/* func: createModuleRolePrivilege
  Выдает роли привилегию на любые пакетные задания модуля.

  Параметры:
  moduleId                    - Id модуля
  roleId                      - Id роли
  privilegeCode               - код привилегии
  operatorId                  - Id оператора

  Возврат:
  Id созданной записи.
*/
function createModuleRolePrivilege(
  moduleId integer
  , roleId integer
  , privilegeCode varchar2
  , operatorId integer
)
return integer
is

  moduleRolePrivilegeId sch_module_role_privilege.module_role_privilege_id%type;

begin
  checkPrivilege( operatorId, null, Admin_PrivilegeCode, moduleId);
  insert into
    sch_module_role_privilege
  (
    module_id
    , role_id
    , privilege_code
    , operator_id
  )
  values
  (
     moduleId
     , roleId
     , privilegeCode
     , operatorId
  )
  returning module_role_privilege_id into moduleRolePrivilegeId;
  return moduleRolePrivilegeId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при выдаче привилегии на пакетные задания модуля ('
        || ' moduleId=' || moduleId
        || ', roleId=' || roleId
        || ', privilegeCode="' || privilegeCode || '"'
        || ').'
      )
    , true
  );
end createModuleRolePrivilege;

/* proc: deleteModuleRolePrivilege
  Отбирает у роли привилегию на тип пакетов.

  Параметры:
  moduleRolePrivilegeId       - Id записи c выдачей привилегии
  operatorId                  - Id оператора
*/
procedure deleteModuleRolePrivilege(
  moduleRolePrivilegeId integer
  , operatorId integer
)
is

  -- Данные существующей записи
  rec sch_module_role_privilege%rowtype;

begin
  select
    t.*
  into rec
  from
    sch_module_role_privilege t
  where
    t.module_role_privilege_id = moduleRolePrivilegeId
  for update nowait;
  checkPrivilege( operatorId, null, Admin_PrivilegeCode, rec.module_id);
  delete from
    sch_module_role_privilege t
  where
    t.module_role_privilege_id = rec.module_role_privilege_id
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при удалении привилегии на пакетные задания модуля ('
        || ' moduleRolePrivilegeId=' || moduleRolePrivilegeId
        || ').'
      )
    , true
  );
end deleteModuleRolePrivilege;

/* func: findModuleRolePrivilege
  Поиск выданных ролям привилегий на любые пакетные задания модуля.

  Параметры:
  moduleRolePrivilegeId       - Id записи c выдачей привилегии
                                ( по умолчанию без ограничений)
  moduleId                    - Id модуля
                                ( по умолчанию без ограничений)
  roleId                      - Id роли
                                ( по умолчанию без ограничений)
  privilegeCode               - код привилегии
                                ( по умолчанию без ограничений)
  maxRowCount                 - максимальное число возвращаемых записей
                                ( по умолчанию без ограничений)
  operatorId                  - Id оператора, выполняющего операцию
                                ( по умолчанию текущий)

  Возврат (курсор):
  module_role_privilege_id    - Id записи c выдачей привилегии
  module_id                   - Id модуля
  module_name                 - название модуля
  role_id                     - Id роли
  role_short_name             - краткое название роли
  role_name                   - название роли
  privilege_code              - код привилегии
  privilege_name              - название привилегии
  date_ins                    - дата добавления записи
  operator_id                 - Id оператора, добавившего запись
  operator_name               - оператор, добавивший запись

  Замечания:
  - возвращаемые записи отсортированы по module_name, role_short_name,
    privilege_code;
*/
function findModuleRolePrivilege(
  moduleRolePrivilegeId integer := null
  , moduleId integer := null
  , privilegeCode varchar2 := null
  , roleId integer := null
  , maxRowCount  integer := null
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
    t.module_role_privilege_id
    , t.module_id
    , md.module_name
    , t.privilege_code
    , t.role_id
    , r.role_short_name
    , p.privilege_name
    , r.role_name
    , t.date_ins
    , t.operator_id
    , op.operator_name
  from
    sch_module_role_privilege t
    inner join
      (
      select
        rp.module_id
      from
        v_sch_role_privilege rp
        inner join v_op_operator_role opr
          on opr.role_id = rp.role_id
      where
        rp.privilege_code = ''' || Read_PrivilegeCode || '''
        and rp.module_id is not null
        and opr.operator_id = :operatorId
      group by
        rp.module_id
      ) mp
      on mp.module_id = t.module_id
    inner join v_mod_module md
      on md.module_id = t.module_id
    inner join sch_privilege p
      on p.privilege_code = t.privilege_code
    inner join v_op_role r
      on r.role_id = t.role_id
    inner join op_operator op
      on op.operator_id = t.operator_id
  where
    $(condition)
  order by
    md.module_name
    , role_short_name
    , t.privilege_code
  ) a
where
  $(rownumCondition)
'
  );

-- findModuleRolePrivilege
begin

  -- формирование параметров запроса
  dsql.addCondition(
    't.module_role_privilege_id =', moduleRolePrivilegeId is null
  );
  dsql.addCondition( 't.module_id =', moduleId is null);
  dsql.addCondition( 't.privilege_code =', privilegeCode is null);
  dsql.addCondition( 't.role_id =', roleId is null);
  dsql.useCondition( 'condition');
  dsql.addCondition(
    'rownum <= :maxRowCount', maxRowCount is null
  );
  dsql.useCondition( 'rownumCondition');

  open rc for
    dsql.getSqlText()
  using
    coalesce( operatorId, pkg_Operator.getCurrentUserId())
    , moduleRolePrivilegeId
    , moduleId
    , privilegeCode
    , roleId
    , maxRowCount
  ;

  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при поиске прав на пакетные задания модулей.'
      )
    , true
  );
end findModuleRolePrivilege;



/* group: Справочники */

/* func: findModule
  Возвращает программные модули, у которых есть пакетные задания.

  Возврат ( курсор):
  module_id                   - Id модуля
  module_name                 - Название модуля
  ( сортировка по module_name, module_id)
*/
function findModule
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

begin
  open rc for
    select
      t.module_id
      , t.module_name
    from
      v_mod_module t
    where
      t.module_id in
        (
        select
          bt.module_id
        from
          sch_batch bt
        )
    order by
      t.module_name
      , t.module_id
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при возврате программных модулей.'
      )
    , true
  );
end findModule;

/* func: getIntervalType
  Функция выбирает все данные из таблицы sch_interval_type без дополнительных условий.

  Возврат (курсор):
    interval_type_code          -  Уникальный идентификатор
    interval_type_name          -  Наименование
*/
function getIntervalType
return sys_refcursor
is
  -- возвращаемый курсор
  resultSet sys_refcursor;
begin

  open resultSet for
  select
      interval_type_code
    , interval_type_name_rus as interval_type_name
  from sch_interval_type;

  return resultSet;

end getIntervalType;

/* func: getPrivilege
  Возвращает привилегии на работу с пакетными заданиями.

  Возврат ( курсор):
  privilege_code              - код типа привилегии
  privilege_name              - название типа привилегии

  ( сортировка по privilege_name)
*/
function getPrivilege
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

begin
  open rc for
    select
      t.privilege_code
      , t.privilege_name
    from
      sch_privilege t
    order by
      t.privilege_name
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при выборке привилегий на работу с пакетными заданиями.'
      )
    , true
  );
end getPrivilege;

/* func: getRole
  Возвращает список ролей.

  Параметры:
  searchStr                   - строка-образец для поиска ( шаблон для поиска
                                по короткому названию, названию или описанию
                                роли без учета регистра)

  Возврат ( курсор):
  role_id                     - Id роли
  role_name                   - название роли

  Замечания:
  - возвращаемые записи отсортированы по role_name;
*/
function getRole(
  searchStr varchar2 := null
)
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

begin
  open rc for
    select
      t.role_id
      , t.role_name
    from
      v_op_role t
    where
      searchStr is null
      or upper( t.role_short_name) like upper( searchStr)
      or upper( t.role_name) like upper( searchStr)
      or upper( t.role_name_en) like upper( searchStr)
      or upper( t.description) like upper( searchStr)
    order by
      role_name
  ;
  return rc;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении списка ролей.'
      )
    , true
  );
end getRole;

/* func: getValueType
  Возвращает типы значений параметров пакетных заданий.

  Возврат ( курсор):
  value_type_code             - код типа значения параметра
  value_type_name             - название типа значения параметра
*/
function getValueType
return sys_refcursor
is

  -- Возвращаемый курсор
  rc sys_refcursor;

begin
  return pkg_Option.getValueType();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при выборке типов значений параметров батчей.'
      )
    , true
  );
end getValueType;



/* group: Функции управления пакетными заданиями */



/* group: Выполнение батчей */

/* func: calcNextDate
  Вычисляет дату следующего запуска пакета заданий.

  Параметры:
  batchId              - Id пакета
  startDate            - начальная дата (начиная с которой выполняется расчет)
*/
function calcNextDate(
  batchId integer
  , startDate date := sysdate
)
return date
is
  -- Расписание запуска
  cursor curInterval( batchId integer) is
    select
      sd.schedule_id
      , decode( iv.interval_type_code
          , Month_IntervalTypeCode, 5
          , Dayofmonth_IntervalTypeCode, 4
          , Dayofweek_IntervalTypeCode, 4
          , Hour_IntervalTypeCode, 3
          , Minute_IntervalTypeCode, 2
          , null
        )
        as interval_level
      , iv.interval_type_code
      , iv.min_value
      , iv.max_value
      , iv.step
    from
      sch_schedule sd
      left outer join sch_interval iv
        on iv.schedule_id = sd.schedule_id
    where
      sd.batch_id = batchId
    order by
      1
      , 2 desc
      , case when iv.interval_type_code = Dayofweek_IntervalTypeCode
          then 0 else 1
        end
      , 4
  ;

  subtype TInterval is curInterval%rowtype;
  type TColInterval is table of TInterval;
  colInterval TColInterval := TColInterval();

  -- Возвращаемое значение
  nextDate date := null;

  -- Индекс первого интервала расписания
  iBeginInterval integer;
  -- Индекс следующего за последним интервала расписания
  iEndInterval integer;
  -- Рассчитанная дата по расписанию
  scheduleDate date;



  function CalcIntervalValue(
      iv TInterval
      , minValue integer
      , maxValue integer
      , minDay date
    )
    return integer
    is
  --Возвращает наименьшее значение, соответствующее указанному интервалу
  --и принадлежащее указанному интервалу значений.
  --
  --Параметры:
  --iv                        - интервал
  --minValue                  - минимально допустимое значение
  --maxValue                  - максимально допустимое значение
  --minDay                    - день, соответствующий минимальному значению
  --
  --Замечание:
  --для интервалов типа "день недели" и "день месяца" значения
  --minValue/maxValue представляют собой дни месяца и дополнительно передается
  --дата для минимального дня месяца ( minDay), а функция возравращает день
  --месяца.

    -- Возвращаемое значение
    n integer := null;
    -- Диапазон значений по интервалу
    n1 integer := iv.min_value;
    n2 integer := iv.max_value;
    -- Временная переменная
    k integer;

  --CalcIntervalValue
  begin
    if n1 <= n2 then
      -- Уточняем максимальное значение
      if iv.step > 1 then
        n2 := n2 - mod( n2 - n1, iv.step);
      end if;
      -- Транслируем границы интервала "дни недели" в дни месяца
      if iv.interval_type_code = Dayofweek_IntervalTypeCode then
        k := to_number( to_char( minDay, 'd'));
        k := minValue +
          case when k <= n2 then
            n1 - k
          else
            n1 + 7 - k
          end
        ;
        n2 := least(
                k + ( n2 - n1)
                , to_number( to_char( last_day( minDay), 'dd'))
              )
        ;
        n1 := k;
      -- Случай "последний день месяца"
      elsif iv.interval_type_code = Dayofmonth_IntervalTypeCode
          and iv.min_value = -1
          then
        n1 := to_number( to_char( last_day( minDay), 'dd'));
        n2 := n1;
      end if;
      -- Определяем минимальное значение
      n := n1;
      if n < minValue then
        n :=
          case when iv.step > 1 then
            n1 + ceil( ( minValue - n1) / iv.step) * iv.step
          else
            minValue
          end
        ;
      end if;
      -- Проверяем по максимальному
      if n > n2 or n > maxValue then
        n := null;
      end if;
    end if;
    return n;
  end CalcIntervalValue;



  procedure CalcScheduleDate( iBeginInterval integer, iEndInterval integer) is
  --Пытается рассчитать ближайшую дату по расписанию.
  --
  --Параметры:
  --iBeginInterval            - индекс первого интервала расписания
  --iEndInterval              - индекс следующего за последним интервала
  --                            расписания

    -- Значение, разбитое на разряды (от секунд до лет)
    type TColValue is varray( 6) of integer;
    -- Начальное значение
    colStartValue constant TColValue :=
      TColValue(
        to_number( to_char( startDate, 'ss'))
        , to_number( to_char( startDate, 'mi'))
        , to_number( to_char( startDate, 'hh24'))
        , to_number( to_char( startDate, 'dd'))
        , to_number( to_char( startDate, 'mm'))
        , to_number( to_char( startDate, 'yyyy'))
      )
    ;
    -- Минимальные значения
    colMinValue constant TColValue :=
      TColValue(
         0,  0,  0,  1,  1
          , colStartValue( 6)
      )
    ;
   -- Максимальные значения: дата всегда считается с 00 секунд последний день
   -- зависит от месяца должен входить високосный год
    colMaxValue constant TColValue :=
      TColValue(
        0, 59, 23, null, 12
          , colStartValue( 6) + ( 4 - mod( colStartValue(6), 4))
      )
    ;
    -- Расчетное значение
    colValue TColValue := colStartValue;
    -- Расчет от минимальных значений
    isFromMinValue boolean := false;



    function CalcValue( maxLevel integer, iBeginInterval integer)
      return boolean
      is
    --Пытается рассчитать значение вплоть до указанного уровня ( разряда) и
    --возвращает успешность расчета.
    --
    --Параметры:
    --maxLevel                - уровень, вплоть до которого надо считать
    --iBeginInterval          - индекс первого просматриваемого интервала

      -- Признак успешности расчета
      isCalc boolean := false;
      -- Индекс текущего интервала
      i integer;
      -- Минимальное подходящее значение по интервалам
      minValue integer;
      -- Максимальное допустимое значение
      maxValue integer :=
        case when maxLevel = 4 then
          to_number( to_char(
            last_day(
              to_date(
                to_char( colValue( 6), '0999')
                || to_char( colValue( 5), '09')
                || '01'
                , 'YYYYMMDD'
              )
            )
          , 'dd'))
        else
          colMaxValue( maxLevel)
        end
      ;

    --CalcValue
    begin
      -- Сбрасываем начальное значение
      if isFromMinValue then
        colValue( maxLevel) := colMinValue( maxLevel);
      end if;
      -- Перебираем все возможные значения
      loop
        exit when colValue( maxLevel) > maxValue;
        -- Предполагаем, что нашли
        isCalc := true;
        -- Проверяем по заданным интервалам
        i := iBeginInterval;
        loop
          exit when i is null or i >= iEndInterval;
          if colInterval( i).interval_level = maxLevel then
            -- Найден первый интервал
            if isCalc then
              isCalc := false;
              minValue := null;
            end if;
            -- Выход, т.к. дальше большие значения
            exit when
              colInterval( i).min_value > minValue
              and colInterval( i).interval_type_code
                <> Dayofweek_IntervalTypeCode
            ;
            -- Определяем минимальное подходящее значение по интервалу
            minValue := coalesce(
              CalcIntervalValue(
                colInterval( i)
                , colValue( maxLevel)
                , coalesce( minValue, maxValue)
                , case
                    when
                      colInterval( i).interval_type_code in (
                          Dayofweek_IntervalTypeCode
                          , Dayofmonth_IntervalTypeCode
                        )
                    then
                      to_date(
                        to_char( colValue( 6), '0999')
                        || to_char( colValue( 5), '09')
                        || to_char( colValue( 4), '09')
                      , 'yyyymmdd')
                  end
              )
              , minValue
            );
            -- Выход, если нашли подходящий интервал
            if minValue = colValue( maxLevel) then
              isCalc := true;
              exit;
            end if;
          elsif colInterval( i).interval_level < maxLevel then
            -- Выход, если нет нужных интервалов
            exit;
          end if;
          -- Переходим к следующему интервалу
          i := colInterval.next( i);
        end loop;
        -- Учитывем проверку по интервалам
        if not isCalc then
          isFromMinValue := true;
          if minValue is not null then
            -- Перепрыгиваем на минимально возможное значение
            colValue( maxLevel) := minValue;
          else
            -- Выход, т.к. нет допустимых значений
            exit;
          end if;
        end if;
        -- Рассчитываем меньшие разряды
        if maxLevel > 1 then
          isCalc := CalcValue( maxLevel - 1, i);
        end if;
        -- Выход, если успешный расчет
        exit when isCalc;
        -- Переходим на следующее значение
        colValue( maxLevel) := colValue( maxLevel) + 1;
      end loop;
      -- Дальше считаем с минимальных значений
      if not isCalc and not isFromMinValue then
        isFromMinValue := true;
      end if;
      return isCalc;
    end CalcValue;



  --CalcScheduleDate
  begin
    scheduleDate :=
      case
        when colInterval( iBeginInterval).interval_type_code is null then
          startDate
        when CalcValue( 6, iBeginInterval) then
          to_date(
            to_char( colValue( 6), '0999')
            || to_char( colValue( 5), '09')
            || to_char( colValue( 4), '09')
            || to_char( colValue( 3), '09')
            || to_char( colValue( 2), '09')
            || to_char( colValue( 1), '09')
            , 'yyyymmddhh24miss'
          )
        else
          null
      end
    ;
  end CalcScheduleDate;


--CalcNextDate
begin
  -- Згружаем расписания по пакету
  open curInterval( batchId);
  fetch curInterval bulk collect into colInterval;
  close curInterval;
  iEndInterval := colInterval.first;
  loop
    exit when iEndInterval is null;
    -- Сохраняем Id расписания
    iBeginInterval := iEndInterval;
    -- Находим начало следующего расписания
    loop
      iEndInterval := colInterval.next( iEndInterval);
      exit when
        iEndInterval is null
        or colInterval( iEndInterval).schedule_id
          <> colInterval( iBeginInterval).schedule_id;
    end loop;

    -- Рассчитываем дату по расписанию
    CalcScheduleDate( iBeginInterval, iEndInterval);
    -- Берем минимальную дату по расписаниям
    if scheduleDate is not null
        and ( nextDate is null or scheduleDate < nextDate)
        then
      nextDate := scheduleDate;
      -- Выход, если это лучший вариант
      if nextDate = startDate then
        exit;
      end if;
    end if;
  end loop;
  return coalesce( nextDate, Default_RunDate);
exception when others then
  raise_application_error(
    pkg_Error.ErrorInfo
    , 'Ошибка при расчете даты следующего запуска пакета ('
      || ' batch_id=' || to_char( batchId)
      || ', startDate=' || to_char( startDate, 'yyyy-mm-dd hh24:mi:ss')
      || ').'
    , true
  );
end calcNextDate;

/* proc: stopHandler
  Останавливает сессию обработчика с помощью отправки команды остановки.

  Параметры:
  batchId                     - Id пакета
  sid                         - sid сессии
  serial#                     - serial# сессии
  operatorId                  - Id оператора
  sessionid                   - audsid сессии
                                (для логирования, указывать необязательно)
*/
procedure stopHandler(
  batchId integer
  , sid number
  , serial# number
  , operatorId integer
  , sessionid number := null
)
is
  cursor curPipe( pSid integer, pSerial integer) is
select
  ss.audsid as sessionid
  , p.name as pipe_name
from
  v$session ss
  left join v$db_pipes p
    on p.name like
      '%.COMMANDPIPE\_' || to_char( ss.sid) || '\_' || to_char( ss.serial#)
      escape '\'
where
  ss.sid = pSid
  and ss.serial# = pSerial
  ;

  ppr curPipe%rowtype;

  -- Результат операции с каналом
  pipeStatus number := null;
  -- Флаг наличия сессии
  isFound boolean := false;

--StopHandler
begin
  if operatorId is not null then
    pkg_Operator.setCurrentUserId( operatorId => operatorId);
  end if;
  logger.info(
    messageText             =>
        'Начало отправки команды остановки обработчика ('
        || ' batch_id=' || to_char( batchId)
        || ', sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ').'
    , messageLabel          => pkg_SchedulerMain.StopHandler_BatchMsgLabel
    , messageValue          => sessionid
    , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
    , contextValueId        => batchId
    , openContextFlag       => 1
  );
  open curPipe( sid, serial#);
  fetch curPipe into ppr;
  close curPipe;
  if ppr.pipe_name is not null then
    -- Посылаем сообщение
    dbms_pipe.pack_message( 'stop');
    pipeStatus := dbms_pipe.send_message(
      pipename  => ppr.pipe_name
      , timeout => 0
    );
    logger.log(
      levelCode               =>
          case when pipeStatus = 0 then
            lg_logger_t.getInfoLevelCode()
          else
            lg_logger_t.getWarnLevelCode()
          end
      , messageText           =>
          case when pipeStatus = 0 then
            'Команда остановки успешно отправлена'
          else
            'Ошибка при отправке команды остановки'
          end
          || ' ('
          || ' pipe="' || ppr.pipe_name || '"'
          || case when pipeStatus > 0 then
            ', status=' || pipeStatus
            end
          || ').'
      , messageValue          => ppr.sessionid
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => batchId
      , openContextFlag       => 0
    );
  else
    logger.info(
      messageText             =>
          case when ppr.sessionid is null then
              'Не найдена сессия'
            else
              'Не найден канал'
            end
          || ' для отправки команды остановки.'
      , messageValue          => ppr.sessionid
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => batchId
      , openContextFlag       => 0
    );
  end if;
exception when others then
  logger.error(
    messageText             =>
        'Ошибка при отправке команды остановки обработчика.'
        || chr( 10)
        || logger.getErrorStack()
    , messageValue          => ppr.sessionid
    , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
    , contextValueId        => batchId
    , openContextFlag       => 0
  );
end stopHandler;

/* iproc: execBatch
  Выполняет указанный пакет заданий

  Параметры:
  batchId                     - id задания
  oracleJobId                 - id задания Oracle (для определения batch_id)
  nextDate                    - дата следующего запуска
  resultId                    - id результата выполнения пакета

  Замечание:
  - 2-й и 3-й параметр используются только если первый параметр не задан (is
    null)
*/
procedure execBatch(
  batchId integer := null
  , oracleJobId number := null
  , nextDate in out date
  , resultId out integer
)
is

  -- Логин для выполнения через dbms_scheduler
  cServerLoginName constant varchar2(20) := 'ServerSezam';
  isOperatorLogonDone boolean := false; --Признак того, что был выполнен логон
  -- Доступно ли получение стека с помощью Logging
  isLoggingStackAvailable boolean := false;

  lIsJob boolean := batchId is null;    --Флаг периодического выполнения (job)
  lBatchId sch_batch.batch_id%type;     --Id исполняемого пакета
  lStartDate date := sysdate;           --Дата начала выполнения пакета
  lStartLogId integer;                  --Id лога о запуске пакета

  -- Уровень выполняемого пакета (с 1)
  batchLevel pls_integer := nvl( gBatchLevel, 0) + 1;
  -- Id результата выполнения пакета
  batchResultId sch_result.result_id%type := True_ResultId;
  -- Текст сообщения о выполнении пакета
  batchResultMessage varchar2(4000) :=
    'Выполнение пакета успешно завершено ( положительный результат).';



  -- Параметры исполняемого пакета
  batchNameRus sch_batch.batch_name_rus%type;
  batchShortName sch_batch.batch_short_name%type;
  batchRetrialCount sch_batch.retrial_count%type;
  batchRetrialTimeout sch_batch.retrial_timeout%type;
  batchRetrialNumber sch_batch.retrial_number%type;

  batchScheduleDate date;               --Дата запуска по расписанию



  -- Выборка параметров заданий
  cursor curContent( pBatchId number) is
    select
      bc.batch_content_id
      , j.job_id
      , j.job_name
      , j.job_what
      , cursor (
          select
            cn.condition_id
            , cn.check_batch_content_id
            , cn.result_id
          from
            sch_condition cn
          where
            cn.batch_content_id = bc.batch_content_id
          order by
            cn.check_batch_content_id
            , cn.result_id
            , cn.condition_id
        ) as condition
    from
      sch_batch_content bc
      , sch_job j
    where
      bc.date_del is null
      and bc.job_id = j.job_id
      and j.date_del is null
      and bc.batch_id = pBatchId
    order by
      bc.order_by
      , bc.batch_content_id
  ;

  type TCondition is record             --Условие на выполнение задания
  (
    conditionId sch_condition.condition_id%type
    , contentId sch_condition.check_batch_content_id%type
    , resultId sch_result.result_id%type
  );

  type TcolCondition is table of TCondition;

  type TContent is record               --Параметры задания
  (
    contentId sch_batch_content.batch_content_id%type
    , jobId sch_job.job_id%type
    , jobName sch_job.job_name%type
    , jobWhat sch_job.job_what%type
    , colCondition TcolCondition := TcolCondition()
  );

  type TcolContent is table of TContent;
  -- Все задания пакета
  colContent TcolContent := TcolContent();



  -- Результат выполнения заданий
  type TcolResult is table of sch_result.result_id%type
    index by binary_integer;

  colResult TcolResult;



  procedure CheckLogin is
  --Проверяет наличие регистрации у оператора
  begin
    begin
      -- Игнорируем возвращаемое значение
      if pkg_Operator.GetCurrentUserId is not null then null; end if;
    exception when others then
      -- Пытаемся зарегистрироваться, если пакет выполняется как джоб
      if SQLCODE = pkg_Error.OperatorNotRegister and lIsJob then
        -- Игнорируем возвращаемое значение
        if pkg_Operator.Login( cServerLoginName) is not null then null; end if;
        isOperatorLogonDone := true;
      else
        raise;
      end if;
    end;
  exception when others then            --Добавляем информацию об ошибке
    raise_application_error(
      pkg_Error.ErrorInfo
      , 'Для выполнения пакета необходимо зарегистрироваться.'
      , true
    );
  end CheckLogin;

  procedure CheckLoggingAvailable
  is
  -- Проверка доступности модуля Logging
  -- для получения сообщения об ошибке
  begin
    begin
      execute immediate
        'begin if false then pkg_Logging.ClearErrorStack(); end if;end;';
      isLoggingStackAvailable := true;
    exception when others then
      isLoggingStackAvailable := false;
    end;
  end CheckLoggingAvailable;

  function getJobScheduleDate return date is
  --Возвращает дату старта по расписанию текущего исполняемого задания

    vDate date;                         --возвращаемая дата

  begin
    select
      j.next_date
    into vDate
    from
      user_jobs j
    where
      j.job = sys_context( 'USERENV', 'FG_JOB_Id')
    ;
    return vDate;
  exception when no_data_found then
    return null;
  end getJobScheduleDate;



  procedure findBatch is
  --Определяем исполняемый пакет

    lOracleJobId sch_batch.oracle_job_id%type;

  begin
    if lIsJob then
      -- Устанавливаем режим поиска пакета в зависимости от типа запуска
      lOracleJobId := oracleJobId;
      lBatchId := null;
      batchScheduleDate := getJobScheduleDate;
    else
      lOracleJobId := null;
      lBatchId := batchId;
    end if;
    select                              --Определяем пакет для выполнения
      bt.batch_id
      , bt.batch_name_rus
      , bt.batch_short_name
      , bt.retrial_count
      , bt.retrial_timeout
      , bt.retrial_number
    into lBatchId, batchNameRus, batchShortName
      , batchRetrialCount, batchRetrialTimeout, batchRetrialNumber
    from
      sch_batch bt
    where
      bt.date_del is null
      and
        (
        bt.batch_id = lBatchId
        or bt.oracle_job_id = lOracleJobId
        )
    ;
    -- Логгируем начало выполнения пакета
    logger.info(
      messageText             =>
        'Начало'
          || case when lIsJob and batchRetrialNumber is not null
              then ' повторного (N' || batchRetrialNumber || ')'
              end
          || ' выполнения пакета "' || batchNameRus
          || '" [' || batchShortName || ']'
          || case when lIsJob
              then ' (oracle_job_id=' || lOracleJobId || ')'
              end
          || '.'
      , messageLabel          => pkg_SchedulerMain.Exec_BatchMsgLabel
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => coalesce( lBatchId, batchId)
      , openContextFlag       => 1
    );
    lStartLogId := lg_logger_t.getOpenContextLogId();
  exception when no_data_found then     --Точное сообщение при отсутствии пакета
    raise_application_error(
      pkg_Error.BatchNotFound
      , 'Не найден пакет для выполнения.'
    );
  end findBatch;



  procedure LoadData is
  --Загружаем данные пакета

    pragma autonomous_transaction;      --Используем автономную транзакцию

    -- Переменная для выборки курсора
    type TcurCondition is ref cursor return TCondition;
    curCondition TcurCondition;


    rc TContent;                        --Промежуточные записи для fetch
    cn TCondition;

  begin
    set transaction read only;          --Обеспечиваем согласованное чтение
    findBatch;                          --Определяем исполняемый пакет
    open curContent( lBatchId);         --Выборка заданий
    loop
      fetch curContent into             --Выбираем данные в промежуточную запись
        rc.contentId
        , rc.jobId
        , rc.jobName
        , rc.jobWhat
        , curCondition
      ;
      exit when curContent%notFound;
      -- Выбираем условия выполнения
      rc.colCondition := TcolCondition();
      loop
        fetch curCondition into cn;
        exit when curCondition%notfound;
        rc.colCondition.extend;
        rc.colCondition( rc.colCondition.last) := cn;
      end loop;
      colContent.extend;                --Сохраняем параметры задания
      colContent( colContent.last) := rc;
    end loop;
    close curContent;
    commit;                             --Завершаем автономную транзакцию
  end LoadData;



  function CheckCondition( iJob in binary_integer)
    return boolean is
  --Проверяет, что условия запуска для указанного задания выполняются
  --Параметры:
  --iJob                      - порядковый номер задания в коллекции colContent

    -- Текущий индекс в коллекции условий
    i binary_integer := colContent( iJob).colCondition.first;
    -- Запись с проверяемым условием одного задания Id проверяемого задания
    cn TCondition;
    contentId sch_batch_content.batch_content_id%type;
    resultId sch_result.result_id%type; --Результат выполнения задания
    isOk boolean := true;               --Результат проверки задания

  begin
    loop
      exit when i is null;
      -- Получаем текущее условие
      cn := colContent( iJob).colCondition( i);
      if cn.contentId = contentId then
        null;
      else                              --Если проверяется новое задание
        -- Прекращаем проверку, если по последнему заданию она не прошла
        if contentId is not null and not isOk then
          exit;
        end if;
        contentId := cn.contentId;      --Начинаем новую проверку
        isOk := false;
        if colResult.exists( contentId) then
          resultId := colResult( contentId);
        else                            --Сообщаем о некорректности в условиях
          logger.warn(
            'Условие относится к заданию, которое выполняется позже.'
            , messageValue    => cn.conditionId
          );
          exit;                         --Прекращаем некорректную проверку
        end if;
      end if;
      if not isOk then                  --Проверяем условие, если это нужно
        isOk := cn.resultId = resultId;
      end if;
      -- Переходим к следующему условию
      i := colContent( iJob).colCondition.next( i);
    end loop;
    return isOk;
  end CheckCondition;



  procedure ExecJob(
    jobWhat in sch_job.job_what%type
    , jobResultId out sch_result.result_id%type
    , jobResultMessage out varchar2
    , restartBatchFlag out integer
    , retryBatchFlag out integer
    ) is
  --Выполняет PL/SQL блок и устанавливает результат выполнения
  --
  --Параметры:
  --jobWhat                   - текст исполняемого PL/SQL
  --jobResultId               - Id результата выполнения
  --jobResultMessage          - текст сообщения о результате выполнения
  --restartBatchFlag          - флаг немедленного перезапуска пакета
  --retryBatchFlag            - флаг необходимости перезапуска пакета
  --
  --Замечание:
  --внутри задания доступны локальные переменные:
  --
  --batchShortName            - короткое имя выполняемого пакета
  --
  --кроме того можно устанавливать значения локальных переменных:
  --
  --jobResultId               - Id результата выполнения задания
  --jobResultMessage          - текст сообщения о результате выполнения задания
  --restartBatchFlag          - флаг немедленного перезапуска пакета
  --retryBatchFlag            - флаг повторного выполнения пакета
  --
  --которые будут использованы если задание завершится без выброса исключения,

    -- Выставляем начальные значения результатов выполнения
    lJobResultId sch_result.result_id%type := True_ResultId;
    lJobResultMessage varchar2(4000) := null;
    -- Флаги перезапуска и повторного запуска
    lIsRestartBatch integer := 0;
    lIsRetryBatch integer := 0;

    lErrorCode number;                  --Код ошибки задания
    -- Текст сообщения об ошибке задания
    lErrorMessage varchar2( 32767);
    -- Текст sql для запуска задания
    sqlText varchar2( 32767) := replace(replace(
'declare
  /* batch: ' || batchShortName || ' */
  batchShortName sch_batch.batch_short_name%type:= :batchShortName;
  jobResultId sch_result.result_id%type := :lJobResult;
  jobResultMessage varchar2(4000) := :lJobResultMessage;
  restartBatchFlag integer := :lIsRestartBatch;
  retryBatchFlag integer := :lIsRetryBatch;
begin
  ' || jobWhat || '
  :lJobResult := jobResultId;
  :lJobResultMessage := jobResultMessage;
  :lIsRestartBatch := restartBatchFlag;
  :lIsRetryBatch := retryBatchFlag;
  -- Сброс возможной необработанной ошибки
  $(clearError);
exception when others then
  :errorCode := sqlcode; :errorMessage := $(getError);
end;'
    -- Замена макропеременных
    , '$(getError)'
    , case when isLoggingStackAvailable then
        -- Ограничение связанной переменной
        'substr( pkg_Logging.GetErrorStack(), 1, 32000)'
      else
        'sqlerrm'
      end
    )
    , '$(clearError)'
    , case when isLoggingStackAvailable then
        'pkg_Logging.ClearErrorStack()'
      else
        'null'
      end
    );

    procedure LogJobError
    is
    -- Логирование ошибки job, в случае если
    -- выполнение возвратило исключение
      Split_Message_Length constant integer := 4000-10;
    begin
      if length( lErrorMessage) < 4000 then
        logger.error(
          messageText           => lErrorMessage
          , messageValue        => lErrorCode
        );
                                       -- Режем сообщение, если оно
                                       -- слишком длинное
      elsif lErrorMessage is not null then
        for idx in
          1..ceil( length( lErrorMessage) / Split_Message_Length)
        loop
          logger.error(
            messageText           => rpad( '#' || to_char( idx), 3) || ':'
                                     ||
                                     substr( lErrorMessage
                                       , ( idx-1) * Split_Message_Length + 1
                                       , Split_Message_Length
                                     )
            , messageValue        => lErrorCode
          );
        end loop;
      else
        logger.error(
          messageText           => 'Сообщение об ошибке неизвестно'
          , messageValue        => lErrorCode
        );
      end if;
    end LogJobError;

  begin
    begin
      execute immediate                -- Выполняем задание
        sqlText
      using
        in batchShortName
        , in out lJobResultId, in out lJobResultMessage
        , in out lIsRestartBatch, in out lIsRetryBatch
        , out lErrorCode, out lErrorMessage;

                                       -- Фиксируем ошибку выполнения задания
      if lErrorCode is not null then
        lJobResultId := Error_ResultId;
      end if;
    exception when others then         -- Фиксируем ошибку запуска задания
      lJobResultId := Runerror_ResultId;
      lErrorCode := sqlcode;
      lErrorMessage := sqlerrm;
    end;
    if lErrorCode is not null then     -- Логгируем ошибку
      LogJobError;
    end if;
                                       -- Игнориуем флаг повтора при
                                       -- установленном флаге перезапуска
    if lIsRestartBatch = 1
        and lIsRetryBatch = 1 then
      lIsRetryBatch := 0;
      logger.warn(
        'Установка флага повторного запуска пакета была проигнорирована'
        || ' в связи с установкой флага немедленного перезапуска.'
      );

    end if;
    -- Устанавливаем сообщение по результату
    if lJobResultMessage is null and lJobResultId is not null then
      lJobResultMessage :=
        case
          when lJobResultId = True_ResultId then
            'Задание выполнено ( положительный результат).'
          when lJobResultId = False_ResultId then
            'Задание выполнено ( отрицательный результат).'
          when lJobResultId = Error_ResultId then
            'Задание выполнено с ошибкой.'
          when lJobResultId = Runerror_ResultId then
            'Задание не выполнялось из-за ошибки.'
          when lJobResultId = Retryattempt_ResultId then
            'Задание выполнено с результатом "Повторить попытку".'
        end
      ;
    end if;
    jobResultId := lJobResultId;        --Возвращаем результат выполнения
    jobResultMessage := lJobResultMessage;
    restartBatchFlag := lIsRestartBatch;
    retryBatchFlag := lIsRetryBatch;
  end ExecJob;



  procedure Exec is
  --Последовательно выполняет задания пакета
    -- Результат выполнения задания
    lJobResultId sch_result.result_id%type;
    -- Текст сообщения о выполнении задания
    lJobResultMessage varchar2(4000);

    restartBatchFlag integer;           --Флаг немедленного перезапуска пакета
    retryBatchFlag integer;             --Флаг повторного выполнения пакета
    i pls_integer := colContent.first;  --Счетчик цикла

  begin
    loop
      exit when i is null;
      -- Логгируем запуск задания
      logger.info(
        messageText             =>
            'Начало выполнения задания "' || colContent( i).jobName ||'".'
        , contextTypeShortName  => pkg_SchedulerMain.Job_CtxTpSName
        , contextValueId        => colContent( i).jobId
        , openContextFlag       => 1
      );
      -- Сообщаем о недоступности получения стека через модуль Logging
      if not isLoggingStackAvailable then
        logger.info(
          'Получение стека с помощью модуля Logging не доступно'
        );
      end if;
      if CheckCondition( i) then
        ExecJob( colContent( i).jobWhat, lJobResultId, lJobResultMessage
               , restartBatchFlag, retryBatchFlag);
      else
        lJobResultId := Skip_ResultId;
        lJobResultMessage := 'Задание было пропущено по условию.';
      end if;
      -- Логгируем завершение задания
      logger.info(
        messageText             => lJobResultMessage
        , messageValue          => lJobResultId
        , contextTypeShortName  => pkg_SchedulerMain.Job_CtxTpSName
        , contextValueId        => colContent( i).jobId
        , openContextFlag       => 0
      );
      -- Сохраняем результат выполнения
      colResult( colContent( i).contentId) := lJobResultId;

      if restartBatchFlag = 1 then
        -- Сообщаем о перезапуске пакета.
        logger.info(
          'Выполнение заданий начато сначала в связи с установкой флага'
          || ' немедленного перезапуска пакета.'
        );
        i := colContent.first;          --Заново начинаем с первого задания.
      elsif retryBatchFlag = 1 then
        -- Сообщаем о прекращении обработки.
        logger.info(
          'Выполнение заданий прекращено в связи с установкой флага'
          || ' повторного выполнения пакета.'
        );
        -- Устанавливаем результат выполнения пакета.
        batchResultId := Retryattempt_ResultId;
        batchResultMessage :=
          'Выполнение пакета завершено со статусом "Повторить попытку".';
        exit;                           --Прекращаем выполнение заданий.
      elsif lJobResultId = Runerror_ResultId then
        -- Сообщаем о прекращении обработки.
        logger.info(
          'Выполнение пакета прервано в связи с ошибкой при запуске задания.'
        );
        -- Устанавливаем результат выполнения пакета.
        batchResultId := Error_ResultId;
        batchResultMessage :=
          'Выполнение пакета завершено с ошибкой.';
        exit;                           --Прекращаем выполнение заданий.
      else
        i := colContent.next( i);       --Получаем следующий индекс
      end if;
    end loop;
  exception when others then            --Уточняем место возникновения ошибки
    raise_application_error(
      pkg_Error.ExecJobInterrupted
      , 'Выполнение заданий было прервано из-за ошибки.'
      , true
    );
  end Exec;



  function LogError return boolean is
  --Пишет сообщение о текущей ошибке в лог
  --Возвращает результат выполнения (успех/не успех), не вызывает исключений
  begin
    if lStartLogId is null then
      -- Логгируем начало выполнения пакета если это еще не сделано
      logger.info(
        messageText             =>
          'Начало выполнении процедуры pkg_Scheduler.execBatch'
          || case
              when lIsJob then '( oracleJobId => '|| oracleJobId ||').'
              else '( batchId => ' || batchId ||').'
            end
        , messageLabel          => pkg_SchedulerMain.Exec_BatchMsgLabel
        , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
        , contextValueId        => coalesce( lBatchId, batchId)
        , openContextFlag       => 1
      );
      lStartLogId := lg_logger_t.getOpenContextLogId();
    end if;
    -- Логгируем ошибку
    logger.error(
      messageText             => SQLERRM
      , messageValue          => SQLCODE
    );
    return true;
  exception when others then
    return false;
  end LogError;



  procedure UpdateRetrialNumber(
    retrialNumber in sch_batch.retrial_number%type) is
  --Сохраняет номер следуюего повторного запуска задания в таблице
  --
  --Параметры:
  --retrialNumber             - новое значение поля retrial_number
    pragma autonomous_transaction;      --Используем автономную транзакцию

    cursor curBatch( batchId integer, oracleJobId integer) is
      select
        b.batch_id
        , b.retrial_number
      from
        sch_batch b
      where
        b.batch_id = batchId
        and b.oracle_job_id = oracleJobId
      for update of b.retrial_number nowait
    ;

  --UpdateRetrialNumber
  begin
    for rec in curBatch( lBatchId, oracleJobId) loop
      update
        sch_batch b
      set
        retrial_number = retrialNumber
      where current of curBatch;
    end loop;
    commit;
  exception when others then            --Дополняем сообщение об ошибке
    rollback;
    raise_application_error(
      pkg_Error.ErrorInfo
      , 'Не удалось изменить значение поля sch_batch.retrial_number.'
      , true
    );
  end UpdateRetrialNumber;



  procedure setNextDate is
  --Устанавливает дату следующего автоматического запуска пакета

    -- Минимально возможная дата следующего запуска
    vMinDate constant date := lStartDate + 1/24/60/60;

    -- Возможено ли повторное выполнение
    isAllowRetrial boolean := nvl( batchRetrialNumber, 0) < batchRetrialCount;

    -- Номер повтора
    vRetrialNumber sch_batch.retrial_number%type := null;
    vRetrialDate date;                  --Дата повторного выполнения

    vDate date;                         --Дата следующего запуска

  begin
    -- Дата следующего запуска по расписанию
    begin
      vDate := calcNextDate( lBatchId, vMinDate);
    exception when others then
      if not LogError then
        raise;
      end if;
      logger.warn(
        'Не удалось определить дату запуска пакета по расписанию.'
      );
      -- Устанавливаем ошибочный статус
      batchResultId := Error_ResultId;
      batchResultMessage :=
        'При завершении выполнения пакета возникли ошибки.';
    end;
    -- Пытаемся поставить пакет на повторное выполнение, если не выполнен
    -- успешно
    if isAllowRetrial and batchResultId not in ( True_ResultId, False_ResultId)
        then
      vRetrialNumber := nvl( batchRetrialNumber, 0) + 1;
      -- Определяем дату повторного выполнения
      vRetrialDate := greatest(
        nvl( batchScheduleDate, lStartDate)
          + coalesce( batchRetrialTimeout, interval '0' second)
        , sysdate + 1 / 24 / 60 / 60    --Ограничиваем снизу следующей секундой
        );
      -- Не используем дату повтора, если она больше или равна дате очередного
      -- запуска, отличной от минимальной
      if vRetrialDate >= vDate and vDate > vMinDate then
        vRetrialNumber := null;
      else
        vDate := vRetrialDate;
      end if;
    end if;
    -- Сохраняем номер повторного запуска
    if nvl( vRetrialNumber, 0) != nvl( batchRetrialNumber, 0) then
      begin
        UpdateRetrialNumber( vRetrialNumber);
      exception when others then        --Игнориуем ошибку, если удалось ее
        if not LogError then            --залоггировать
          raise;
        end if;
      end;
    end if;
    -- Максимальная дата запуска (чтобы job не исчез и не выполнялся)
    if vDate is null then
      vDate := to_date( '01.01.4000', 'dd.mm.yyyy');
    elsif vDate < sysdate then          --Ограничиваем дату снизу текущей датой
      vDate := sysdate;
    end if;
    nextDate := vDate;                  --Присваиваем рассчитанную дату

    -- Логгируем дату следующего запуска
    logger.info(
      messageText           =>
        'Дата '
        || case when vRetrialNumber is null
            then 'следующего'
            else 'повторного (N' || vRetrialNumber || ')'
            end
        || ' запуска пакета установлена в '
        || to_char( nextDate, 'dd.mm.yyyy hh24:mi:ss') || '.'
    );
  exception when others then            --Дополняем информацию об ошибке
    raise_application_error(
      pkg_Error.ErrorInfo
      , 'Во время определения даты следующего запуска пакета произошла ошибка.'
      , true
    );
  end setNextDate;



  procedure FinishBatch is
  --Завершение выполнения пакета
  begin
    if lIsJob then                      --Устанавливаем дату следующего запуска
      begin                             --Откат незафиксированных транзакций
        rollback;
      exception when others then
        if not LogError then
          raise;
        end if;
        logger.warn( 'Во время выполнения отката (rollback) произошла ошибка.');
      end;
      setNextDate;
    end if;
    logger.info(
      messageText             => batchResultMessage
      , messageValue          => batchResultId
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , contextValueId        => coalesce( lBatchId, batchId)
      , openContextFlag       => 0
    );
    if isOperatorLogonDone is null then --Выполнить Logoff, был выполнен Logon
      begin
        pkg_Operator.Logoff;
      exception when others then        --Игнорируем любые ошибки
        null;
      end;
    end if;
  end FinishBatch;



  procedure SendNotify( errorMessage in varchar2 := null) is
  --Отсылает нотификацию по e-mail, если это необходимо.
  --
  --Параметры:
  --errorMessage              - сообщение об ошибке (если вызвана из обработчика
  --                            исключений)

    -- Максимальный размер текста сообщения
    maxMessageLength constant pls_integer := 32767;

    subject varchar2( 1024);            --Тема сообщения
    message varchar2( 32767);           --Текст сообщения

    nError pls_integer := 0;            --Число ошибок
    nWarning pls_integer := 0;          --Число предупреждений



    procedure AddMessageText( text in varchar2, isPrefix boolean := false) is
    --Добавляет текст к сообщению не допуская переполнения
    begin
      message :=                        --Обрезаем текст по максимальной длине
        case when isPrefix then
          text
          || substr( message, 1, maxMessageLength - nvl( length( text), 0))
        else
          message
          || substr( text, 1, maxMessageLength - nvl( length( message), 0))
        end
      ;
    end;



    procedure AddHeaderInfo is
    --Добавляет в сообщение информацию о пакете

      -- Разделитель перед значением
      valueSpace varchar2(10) := ':' || chr(10) || '  ';

      header varchar2( 8000);           --Текст заголовка сообщения

      -- Длительность выполнения пакета
      duration interval day to second :=
        numtodsinterval( sysdate - lStartDate, 'day');

    begin
      -- Тема сообщения
      subject :=
        coalesce( batchShortName,
          case
            when batchId is not null then 'batchId=' || batchId
            when oracleJobId is not null then 'oracleJobId=' || oracleJobId
          end
        )
        || ': ' ||
        case when nError > 0 or errorMessage is not null
          then 'Ошибка'
          else 'Предупреждение'
        end
      ;
      -- Текст сообщения
      header :=
        'Пакет'
          || valueSpace
          || coalesce( batchNameRus,
            case when batchId is not null then
              'batch_id=' || batchId
            end
            || case when batchId is not null and oracleJobId is not null then
              ', '
            end
            || case when oracleJobId is not null then
              'oracle_job_id=' || oracleJobId
            end
            )
          || '.'                        -- . чтобы Outlook не сливал строки
          || chr(10)
        || case when batchRetrialNumber is not null then
          'Номер повторного выполнения'
          || valueSpace
          || to_char( batchRetrialNumber)
          || chr(10)
          end
        || 'Дата запуска'
          || valueSpace
          || to_char( lStartDate, 'dd.mm.yyyy hh24:mi:ss')
          || chr(10)
        || 'Длительность выполнения'
          || valueSpace
          || trim( to_char(
                extract( day from duration) * 24
                + extract( HOUR from duration)
              , '9900'))
            || ':' || to_char( extract( MINUTE from duration), 'fm00')
            || ':' || to_char( extract( second from duration), 'fm00')
          || chr(10)
        || 'Результат выполнения'
          || valueSpace
          || batchResultMessage
          || chr(10)
        || 'Id корневого лога'
          || valueSpace
          || to_char( lStartLogId)
          || chr(10)
        || 'Дата следующего запуска'
          || valueSpace
          || to_char( nextDate, 'dd.mm.yyyy hh24:mi:ss')
          || chr(10)
      ;
      -- Добавляем информацию о кол-ве ошибок
      if nError > 0 or nWarning > 0 then
        header := header
          || chr(10)
          || case when nError > 0 then
            'Ошибок - ' || to_char( nError)
            end
          || case when nWarning > 0 then
              case when nError > 0
                then ', предупреждений - '
                else 'Предупреждений - '
              end
              || to_char( nWarning)
            end
          || '.' || chr(10)
        ;
      end if;
      AddMessageText( header, true);
    end AddHeaderInfo;



    procedure AddDetailInfo is
    --Добавляет в сообщение информацию по каждой ошибке/предупреждению.

      -- Список ошибок и предупреждений
      cursor curDetail is
        select
          lg.log_id
          , case lg.level_code
              when pkg_Logging.Warn_LevelCode then
                Warning_MessageTypeCode
              else
                Error_MessageTypeCode
            end
            as message_type_code
          , lg.message_text
          , (
            select
              max( jb.job_name)
                keep( dense_rank last order by js.log_id)
            from
              lg_log js
              inner join lg_context_type jct
                on jct.context_type_id = js.context_type_id
                  and jct.context_type_short_name
                    = pkg_SchedulerMain.Job_CtxTpSName
              inner join sch_job jb
                on jb.job_id = js.context_value_id
            where
              js.sessionid = lg.sessionid
              and js.log_id between lStartLogId + 1 and lg.log_id - 1
              and js.open_context_flag = 1
            )
            as job_name
        from
          v_lg_context_change_log ccl
          inner join lg_log lg
            on lg.sessionid = ccl.sessionid
              and lg.log_id >= ccl.open_log_id
              and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
          left join lg_context_type ct
            on ct.context_type_id = lg.context_type_id
        where
          ccl.log_id = lStartLogId
          and lg.level_code in
            (
              pkg_Logging.Fatal_LevelCode
              , pkg_Logging.Error_LevelCode
              , pkg_Logging.Warn_LevelCode
            )
        order by
          lg.log_id
      ;

      nDetail pls_integer := 0;         --Число ошибок и предупреждений

    begin
      for rec in curDetail loop
        nDetail := nDetail + 1;         --Увеличиваем счетчики
        if rec.message_type_code = Error_MessageTypeCode then
          nError := nError + 1;
        else
          nWarning := nWarning + 1;
        end if;
        AddMessageText(                 --Пишем детальное описание
          chr(10) || to_char( nDetail) || '. '
          || case when rec.message_type_code = Error_MessageTypeCode
              then 'Ошибка'
              else 'Предупреждение'
            end
            || ' (log_id=' || to_char( rec.log_id) || ')'
            || chr( 10)
          || case when rec.job_name is not null then
              chr(10) || 'Задание:' || chr(10) || '  '
              || rec.job_name || chr(10)
            end
          || chr( 10)
          || 'Сообщение:'
            || chr(10)
          || rec.message_text
            || chr(10)
        );
      end loop;
      if nDetail > 0 then               --Добавляем заголовок
        AddMessageText( chr(10) || 'Детальная информация:' || chr(10), true);
      end if;
    end AddDetailInfo;



  --SendNotify
  begin
    -- Отсылать для автоматически выполняемых пакетов верхнего уровня при
    -- наличии флага
    if gSendNotifyFlag = 1 and lIsJob and gBatchLevel = 1
        then
      AddDetailInfo;
      if errorMessage is not null then
        nError := nError + 1;
        AddMessageText(
          chr(10)
          || '!!! Ошибка при выполнении пакета:' || chr(10) || errorMessage
        );
      end if;
      if message is not null then
        AddHeaderInfo;
        pkg_Common.SendMail(
          mailSender => pkg_Common.GetMailAddressSource( 'scheduler')
          , mailRecipient => pkg_Common.GetMailAddressDestination
          , subject => subject
          , message => message
        );
      end if;
    end if;
  exception when others then            --Логгируем и игнорируем исключения
    if LogError then
      null;
    end if;
  end SendNotify;



--ExecBatch
begin
  gBatchLevel := batchLevel;            --Меняем глобальный уровень выполнения
  begin
    CheckLogin;                         --Проверка регистрации оператора
    CheckLoggingAvailable;              --Проверка доступности модуля Logging
    LoadData;                           --Загружаем данные пакета
    Exec;                               --Выполняем задания
  exception when others then
    batchResultId := Error_ResultId;
    batchResultMessage := 'Выполнение пакета завершено с ошибкой.';
    -- Выбрасываем текущее исключение, если не удалось логгировать ошибку
    if not LogError then
      raise;
    end if;
  end;
  begin
    FinishBatch;                        --Завершаем работу
    SendNotify;                         --Отсылаем нотификацию
  exception when others then            --Дополняем информацию об ошибке
    raise_application_error(
      pkg_Error.ErrorInfo
      , 'Не удалось корректно завершить выполнение пакета ['
        || batchShortName || '] (log_id=' || lStartLogId || ').'
      , true
    );
  end;
  gBatchLevel := case when batchLevel = 1 then null else batchLevel - 1 end;
  resultId := batchResultId;            --Возвращаем результат выполнения пакета
exception when others then
  SendNotify( SQLERRM);                 --Отсылаем нотификацию
  gBatchLevel := case when batchLevel = 1 then null else batchLevel - 1 end;
  -- Добавляем информацию по агрументам вызова если не было логгирования
  if lStartLogId is null then
    raise_application_error(
      pkg_Error.ErrorInfo
      , 'При выполнении процедуры pkg_Scheduler.execBatch'
        || case
            when lIsJob then '( oracleJobId => '|| oracleJobId ||')'
            else '( batchId => ' || batchId ||')'
          end
        || ' произошла ошибка.'
      , true
    );
  else
    raise;
  end if;
end execBatch;

/* proc: execBatch( BATCH_ID)
  Выполняет указанный пакет заданий

  Параметры:
  batchId              - Id задания
*/
function execBatch(
  batchId integer
)
return integer
is
  nextDate date;                        --Временная переменная
  resultId sch_result.result_id%type;   --Результат выполнения пакета

begin
  execBatch( batchId, null, nextDate, resultId);
  return resultId;
end execBatch;

/* proc: execBatch( BATCH_SHORT_NAME)
  Выполняет указанный пакет заданий

  Параметры:
  batchShortName       - Имя (batch_short_name) исполняемого задания
*/
function execBatch(
  batchShortName varchar2
)
return integer
is
  nextDate date;                        --Временная переменная
  batchId sch_batch.batch_id%type;      --Id выполняемого задания
  resultId sch_result.result_id%type;   --Результат выполнения пакета

begin
  begin
    select
      b.batch_id
    into batchId
    from
      sch_batch b
    where
      b.date_del is null
      and b.batch_short_name = batchShortName
    ;
  exception when no_data_found then
    raise_application_error(
      pkg_Error.BatchNotFound
      , 'Не найден пакет для выполнения с именем ['
        || batchShortName || '].'
    );
  end;
  execBatch( batchId, null, nextDate, resultId);
  return resultId;
end execBatch;



/* group: Другие функции */

/* func: clearLog
  Удаляет старые записи лога.

  Параметры:
  toDate                      - Дата, до которой надо удалить логи
                                (не включая, в часовом поясе systimestamp)

  Возврат:
  число удаленных записей.
*/
function clearLog(
  toDate date
)
return integer
is

  toTime timestamp with time zone := to_timestamp_tz(
    to_char( toDate, 'dd.mm.yyyy hh24:mi:ss')
      || to_char( systimestamp, ' tzh:tzm')
    , 'dd.mm.yyyy hh24:mi:ss tzh:tzm'
  );


  nDeleted integer := 0;

-- clearLog
begin

  -- Удаляет логи сессий, у которых все записи сформированы до граничной даты
  delete
    lg_log lg
  where
    lg.sessionid in
      (
      select
        t.sessionid
      from
        lg_log t
      where
        t.log_time < sys_extract_utc( toTime)
        and t.sessionid is not null
      group by
        t.sessionid
      having
        not exists
          (
          select
            null
          from
            lg_log tt
          where
            tt.sessionid = t.sessionid
            and tt.log_time >= toTime
          )
      )
  ;
  nDeleted := nDeleted + sql%rowcount;
  logger.debug( 'deleted by sessionid: ' || nDeleted);

  -- Удаляет устаревшие записи старого лога (без sessionid)
  delete from
    sch_log lg
  where
    lg.rowid in
      (
      select
        t.rowid
      from
        sch_log t
      start with
        t.log_id in
          (
          select /*+ index(t2 sch_log_ix_root_date_ins) */
            t2.log_id
          from
            sch_log t2
          where
            case when
              t2.parent_log_id is null
              and t2.sessionid is null
            then
              t2.date_ins
            end < toDate
          )
      connect by
        prior t.log_id = t.parent_log_id
      )
  ;
  nDeleted := nDeleted + SQL%ROWCOUNT;

  return nDeleted;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при удалении старых записей лога ('
      || ' toDate=' || to_char( toDate, 'dd.mm.yyyy hh24:mi:ss')
      || ').'
    , true
  );
end clearLog;

/* func: getLog
  Возвращает ветку из лога ( таблицы lg_log).

  Параметры:
  rootLogId                - Id корневой записи из lg_log

  Замечания:
  - функция предназначена для использования в SQL-запросах вида:
  select lg.* from table( pkg_Scheduler.getLog( :rootLogId)) lg
*/
function getLog(
  rootLogId integer
)
return
  sch_log_table_t
pipelined parallel_enable
is

  cursor curLog( rootLogId integer) is
    select
      sch_log_t(
        lg.log_id
        , nullif( rootLogId, lg.log_id)
        , case ct.context_type_short_name
            when pkg_SchedulerMain.Batch_CtxTpSName then
              case when lg.open_context_flag != 0 then
                Bstart_MessageTypeCode
              else
                Bfinish_MessageTypeCode
              end
            when pkg_SchedulerMain.Job_CtxTpSName then
              case when lg.open_context_flag != 0 then
                Jstart_MessageTypeCode
              else
                Jfinish_MessageTypeCode
              end
            else
              case lg.level_code
                when pkg_Logging.Fatal_LevelCode then
                  Error_MessageTypeCode
                when pkg_Logging.Error_LevelCode then
                  Error_MessageTypeCode
                when pkg_Logging.Warn_LevelCode then
                  Warning_MessageTypeCode
                when pkg_Logging.Info_LevelCode then
                  Info_MessageTypeCode
                else
                  Debug_MessageTypeCode
              end
          end
        , coalesce( lg.context_value_id, lg.message_value)
        , lg.message_text
        , 1 + ( lg.context_level - ccl.open_context_level)
          + case when lg.open_context_flag in ( 1, -1) then 0 else 1 end
        , lg.date_ins
        , lg.operator_id
      )
      as log_row
    from
      v_lg_context_change_log ccl
      inner join lg_log lg
        on lg.sessionid = ccl.sessionid
          and lg.log_id >= ccl.open_log_id
          and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
      left join lg_context_type ct
        on ct.context_type_id = lg.context_type_id
    where
      ccl.log_id = rootLogId
    order by
      lg.log_id
  ;

  cursor curOldLog( rootLogId integer) is
    select
      sch_log_t(
        lg.log_id
        , lg.parent_log_id
        , lg.message_type_code
        , lg.message_value
        , lg.message_text
        , level
        , lg.date_ins
        , lg.operator_id
      )
      as log_row
    from
      sch_log lg
    start with
      lg.log_id = rootLogId
    connect by
      prior lg.log_id = lg.parent_log_id
    order siblings by
      lg.date_ins
      , lg.log_id
  ;

  -- Флаг лога с использованием контекста модуля Logging
  isContextLog integer;

begin
  select
    count(*)
  into isContextLog
  from
    lg_log lg
  where
    lg.log_id = rootLogId
    and lg.context_type_id is not null
  ;
  if isContextLog = 1 then
    for rec in curLog( rootLogId) loop
      pipe row( rec.log_row);
    end loop;
  else
    for rec in curOldLog( rootLogId) loop
      pipe row( rec.log_row);
    end loop;
  end if;
  return;
end getLog;



/* group: Функции, используемые в заданиях */



/* group: Установка флагов выполнения заданий */

/* func: getSendNotifyFlag
  Возвращает значение флага автоматической рассылки нотификации.
*/
function getSendNotifyFlag
return integer
is
begin
  return gSendNotifyFlag;
end getSendNotifyFlag;

/* proc: setSendNotifyFlag
  Устанавливает флаг рассылки нотификации в указанное значение.
*/
procedure setSendNotifyFlag(
  flagValue integer := 1
)
is
begin
  gSendNotifyFlag := flagValue;
end setSendNotifyFlag;



/* group: Переменные пакетного задания */

/* iproc: setContext
  Устанавливает значение переменной пакетного задания.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  varValue                    - значение переменной
  isConstant                  - переменная является константой
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)
  stringValue                 - значение в виде строки ( для логгирования)
*/
procedure setContext(
  varName varchar2
  , varValue anydata
  , isConstant integer := null
  , valueIndex pls_integer := null
  , stringValue varchar2 := null
)
is

  -- Эффективное имя переменной
  vName VariableNameT;

  -- Переменная уже определена?
  isExist boolean;

  -- Индекс значения
  valIndex pls_integer := coalesce( valueIndex, 1);

  -- Переменная
  v VariableT;

-- setContent
begin
  if valIndex < 1 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Некорректный индекс значения переменной.'
    );
  end if;
  vName := upper( trim( varName));
  isExist := gVariableCol.exists( vName);
  if isExist then
    v := gVariableCol( vName);
    if v.isConstant then
      raise_application_error(
        pkg_Error.VariableAlreadyExist
        , 'Переменная "' || vName
          || '" уже существует и не может быть изменена.'
      );
    end if;
  else
    v.valueCol := ValueColT( null);
    v.isConstant := coalesce( isConstant, 0) = 1;
  end if;

  if v.valueCol.count() < valIndex then
    v.valueCol.extend( valIndex - v.valueCol.count());
  end if;
  v.valueCol( valIndex) := varValue;
  gVariableCol( vName) := v;

  -- Логгируем установку значения
  if gBatchLevel > 0 or logger.isTraceEnabled() then
    logger.log(
      levelCode         =>
          case when gBatchLevel > 0 then
            lg_logger_t.getInfoLevelCode()
          else
            lg_logger_t.getTraceLevelCode()
          end
      , messageText     =>
          varName
          || case when valIndex > 1 then
              '[' || valIndex || ']'
            end
          || ' := ' || stringValue
          || case
              when isConstant = 1 then ' (константа)'
              when isExist then ' (изменена)'
              else ' (создана)'
            end
    );
  end if;
end setContext;

/* proc: setContext( ANYDATA)
  Устанавливает значение переменной пакетного задания произвольного типа.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  varValue                    - значение переменной
  isConstant                  - переменная является константой
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)
*/
procedure setContext(
  varName varchar2
  , varValue anydata
  , isConstant integer := null
  , valueIndex pls_integer := null
)
is
begin
  setContext(
    varName             => varName
    , varValue          => varValue
    , isConstant        => isConstant
    , valueIndex        => valueIndex
    , stringValue       => '<anydata>'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при установке значения переменной произвольного типа ('
        || ' varName="' || varName || '"'
        || ', isConstant=' || isConstant
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end setContext;

/* proc: setContext( DATE)
  Устанавливает значение переменной пакетного задания типа дата.
  заданий.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  varValue                    - значение переменной
  isConstant                  - переменная является константой
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)
*/
procedure setContext(
  varName varchar2
  , varValue date
  , isConstant integer := null
  , valueIndex pls_integer := null
)
is

  -- Данные значения
  varData anydata;

begin
  varData := anydata.convertDate( varValue);
  setContext(
    varName             => varName
    , varValue          => varData
    , isConstant        => isConstant
    , valueIndex        => valueIndex
    , stringValue       =>
        '{' || to_char( varValue, 'dd.mm.yyyy hh24:mi:ss') || '}'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при установке значения переменной типа дата ('
        || ' varName="' || varName || '"'
        || ', isConstant=' || isConstant
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end setContext;

/* proc: setContext( NUMBER)
  Устанавливает числовое значение переменной пакетного задания.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  varValue                    - значение переменной
  isConstant                  - переменная является константой
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)
*/
procedure setContext(
  varName varchar2
  , varValue number
  , isConstant integer := null
  , valueIndex pls_integer := null
)
is

  -- Данные значения
  varData anydata;

begin
  varData := anydata.convertNumber( varValue);
  setContext(
    varName             => varName
    , varValue          => varData
    , isConstant        => isConstant
    , valueIndex        => valueIndex
    , stringValue       => to_char( varValue)
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при установке числового значения переменной ('
        || ' varName="' || varName || '"'
        || ', isConstant=' || isConstant
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end setContext;

/* proc: setContext( STRING)
  Устанавливает строковое значение переменной пакетного задания.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  varValue                    - значение переменной
  isConstant                  - переменная является константой
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)
  encryptedValue              - зашифрованное значение переменной
                                ( если указано, то используется для логирования
                                  вместо значения переменной)
*/
procedure setContext(
  varName varchar2
  , varValue varchar2
  , isConstant integer := null
  , valueIndex pls_integer := null
  , encryptedValue varchar2 := null
)
is

  -- Данные значения
  varData anydata;

begin
  varData := anydata.convertVarchar2( varValue);
  setContext(
    varName             => varName
    , varValue          => varData
    , isConstant        => isConstant
    , valueIndex        => valueIndex
    , stringValue       =>
        case when encryptedValue is null then
          '"' || varValue || '"'
        else
          '"' || encryptedValue || '" ( encrypted)'
        end
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при установке строкового значения переменной ('
        || ' varName="' || varName || '"'
        || ', isConstant=' || isConstant
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end setContext;

/* iproc: getContext
  Возвращает значение переменной пакетного задания.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)

  Возврат:
  значение переменной.
*/
function getContext(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return anydata
is

  -- Эффективное имя переменной
  vName VariableNameT;

  -- Переменная определена?
  isExist boolean;

begin
  vName := upper( trim( varName));
  isExist := gVariableCol.exists( vName);
  if logger.isTraceEnabled() then
    logger.trace(
      varName
      || case when valueIndex > 1 then
          '[' || valueIndex || ']'
        end
      || ' - получение значения переменной'
      || case when not isExist then
          ' ( не определена)'
        end
    );
  end if;
  if isExist then
    return
      gVariableCol( vName).valueCol( coalesce( valueIndex, 1))
    ;
  else
    if coalesce( riseException, 0) = 0 then
      return null;
    else
      raise_application_error(
        pkg_Error.VariableNotDefined
        , 'Переменная "' || varName || '" не определена.'
      );
    end if;
  end if;
end getContext;

/* func: getContextAnydata
  Возвращает значение переменной пакетного задания произвольного типа.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)

  Возврат:
  значение переменной.
*/
function getContextAnydata(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return anydata
is

  -- Данные значения
  varData anydata;

begin
  varData := getContext(
    varName             => varName
    , riseException     => riseException
    , valueIndex        => valueIndex
  );
  return varData;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении значения переменной произвольного типа ('
        || ' varName="' || varName || '"'
        || ', riseException=' || riseException
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end getContextAnydata;

/* func: getContextDate
  Возвращает значение переменной пакетного задания типа дата.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)

  Возврат:
  значение переменной.
*/
function getContextDate(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return date
is

  -- Данные значения
  varData anydata;

  -- Значение, возвращаемое функцией конвертации данных
  num number;

  -- Значение переменной
  varValue date;

begin
  varData := getContext(
    varName             => varName
    , riseException     => riseException
    , valueIndex        => valueIndex
  );
  if varData is not null then
    num := varData.getDate( varValue);
  end if;
  return varValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении значения переменной типа дата ('
        || ' varName="' || varName || '"'
        || ', riseException=' || riseException
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end getContextDate;

/* func: getContextNumber
  Возвращает значение переменной пакетного задания числового типа.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)

  Возврат:
  значение переменной.
*/
function getContextNumber(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return number
is

  -- Данные значения
  varData anydata;

  -- Значение, возвращаемое функцией конвертации данных
  num number;

  -- Значение переменной
  varValue number;

begin
  varData := getContext(
    varName             => varName
    , riseException     => riseException
    , valueIndex        => valueIndex
  );
  if varData is not null then
    num := varData.getNumber( varValue);
  end if;
  return varValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении значения переменной числового типа ('
        || ' varName="' || varName || '"'
        || ', riseException=' || riseException
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end getContextNumber;

/* func: getContextString
  Возвращает значение переменной пакетного задания строкового типа.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))
  valueIndex                  - индекс значения в списке значений
                                ( начиная с 1, по умолчанию 1)

  Возврат:
  значение переменной.
*/
function getContextString(
  varName in varchar2
  , riseException integer := null
  , valueIndex integer := null
)
return varchar2
is

  -- Данные значения
  varData anydata;

  -- Значение, возвращаемое функцией конвертации данных
  num number;

  -- Значение переменной
  varValue varchar2(4000);

begin
  varData := getContext(
    varName             => varName
    , riseException     => riseException
    , valueIndex        => valueIndex
  );
  if varData is not null then
    num := varData.getVarchar2( varValue);
  end if;
  return varValue;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении значения переменной строкового типа ('
        || ' varName="' || varName || '"'
        || ', riseException=' || riseException
        || ', valueIndex=' || valueIndex
        || ').'
      )
    , true
  );
end getContextString;

/* func: getContextValueCount
  Возвращает число значений для переменной пакетного задания.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))

  Возврат:
  число значений или 0 при отсутствии переменной.
*/
function getContextValueCount(
  varName in varchar2
  , riseException integer := null
)
return integer
is

  -- Эффективное имя переменной
  vName VariableNameT;

  -- Число значений переменной
  valueCount pls_integer := 0;

begin
  vName := upper( trim( varName));
  if gVariableCol.exists( vName) then
    valueCount := gVariableCol( vName).valueCol.count();
  elsif riseException = 1 then
    raise_application_error(
      pkg_Error.VariableNotDefined
      , 'Переменная "' || varName || '" не определена.'
    );
  end if;
  return valueCount;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при возврате числа значений переменной ('
        || ' varName="' || varName || '"'
        || ', riseException=' || riseException
        || ').'
      )
    , true
  );
end getContextValueCount;

/* proc: deleteContext
  Удаляет переменную пакетного задания.

  Параметры:
  varName                     - имя переменной ( без учета регистра)
  riseException               - флаг генерации исключения при отсутствии
                                переменной
                                ( 1 да, 0 нет ( по умолчанию))
*/
procedure deleteContext(
  varName in varchar2
  , riseException integer := null
)
is

  -- Эффективное имя переменной
  vName VariableNameT;

begin
  vName := upper( trim( varName));
  if gVariableCol.exists( vName) then
    if gBatchLevel > 0 or logger.isTraceEnabled() then
      logger.log(
        levelCode       =>
            case when gBatchLevel > 0 then
              lg_logger_t.getInfoLevelCode()
            else
              lg_logger_t.getTraceLevelCode()
            end
        , messageText   =>
            varName || ' - переменная удалена.'
      );
    end if;
    gVariableCol.delete( vName);
  elsif riseException = 1 then
    raise_application_error(
      pkg_Error.VariableNotDefined
      , 'Переменная "' || varName || '" не определена.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении удалении переменной ('
        || ' varName="' || varName || '"'
        || ', riseException=' || riseException
        || ').'
      )
    , true
  );
end deleteContext;



/* group: Выполнение пакетного задания */

/* proc: execBatch( ORACLE_JOB)
  Выполняет указанный пакет заданий

  Параметры:
  oracleJobId          - Id задания Oracle (для определения batch_id)
  nextDate             - Дата следующего запуска
*/
procedure execBatch(
  oracleJobId number
  , nextDate in out date
)
is
  resultId sch_result.result_id%type;   --Результат выполнения пакета

begin
  execBatch( null, oracleJobId, nextDate, resultId);
end execBatch;



/* group: Устаревшие функции */

/* func: getContextInteger
  Устаревшая функция, следует использовать <getContextNumber>.
*/
function getContextInteger(
  varName in varchar2
  , riseException integer := 0
)
return number
is
begin
  return
    getContextNumber(
      varName           => varName
      , riseException   => riseException
    )
  ;
end getContextInteger;

/* func: getDebugFlag
  Устаревшая функция, следует использовать isTraceEnabled() логера (тип
  lg_logger_t).
*/
function getDebugFlag
return integer
is
begin
  return
    case when logger.isTraceEnabled() then
      1
    else
      0
    end
  ;
end getDebugFlag;

/* proc: setDebugFlag
  Устаревшая функция, следует использовать setLevel() логера (тип
  lg_logger_t).
*/
procedure setDebugFlag(
  flagValue integer := 1
)
is
begin
  if coalesce( flagValue = 1, true) then
    logger.setLevel( levelCode => lg_logger_t.getTraceLevelCode());
  else
    logger.setLevel( levelCode => null);
  end if;
end setDebugFlag;

/* proc: writeLog
  Устаревшая функция, следует использовать логер пакетного задания либо
  собственный логер (тип lg_logger_t).
*/
procedure writeLog(
  messageTypeCode varchar2
  , messageText varchar2
  , messageValue number := null
  , operatorId integer := null
)
is
begin
  if operatorId is not null then
    pkg_Operator.setCurrentUserId( operatorId => operatorId);
  end if;
  logger.log(
    levelCode                 =>
        case messageTypeCode
          when Error_MessageTypeCode then
            pkg_Logging.Error_LevelCode
          when Warning_MessageTypeCode then
            pkg_Logging.Warn_LevelCode
          when Info_MessageTypeCode then
            pkg_Logging.Info_LevelCode
          when Debug_MessageTypeCode then
            pkg_Logging.Debug_LevelCode
          else
            pkg_Logging.Info_LevelCode
        end
    , messageText             => messageText
    , messageValue            => messageValue
  );
end writeLog;

end pkg_Scheduler;
/
