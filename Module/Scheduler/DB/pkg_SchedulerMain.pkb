create or replace package body pkg_SchedulerMain is
/* package body: pkg_SchedulerMain::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_SchedulerMain'
);

/* ivar: schedulerModuleId
  Id записи для модуля Scheduler в таблице mod_module модуля ModuleInfo
  ( кэшированное значение).
*/
schedulerModuleId integer;



/* group: Функции */

/* func: getModuleId
  Возвращает Id модуля Scheduler в текущей БД ( с кэшированием ранее
  определенного значения).

  Возврат:
  Id записи для модуля Scheduler в таблице mod_module модуля ModuleInfo.
*/
function getModuleId
return integer
is
begin
  if schedulerModuleId is null then
    schedulerModuleId := pkg_ModuleInfo.getModuleId(
      svnRoot               => Module_SvnRoot
      , raiseExceptionFlag  => 1
    );
  end if;
  return schedulerModuleId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении Id модуля Scheduler в текущей БД.'
      )
    , true
  );
end getModuleId;

/* proc: getBatch( batchId)
  Возвращает данные пакетного задания.

  Параметры:
  dataRec                     - данные пакетного задания
                                ( возврат)
  batchId                     - Id пакетного задания
*/
procedure getBatch(
  dataRec out nocopy sch_batch%rowtype
  , batchId integer
)
is
begin
  select
    t.*
  into dataRec
  from
    sch_batch t
  where
    t.batch_id = batchId
  ;
exception
  when no_data_found then
    raise_application_error(
      pkg_Error.BatchNotFound
      , 'Пакетное задание не найдено ('
        || ' batchId=' || batchId
        || ').'
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при получении данных пакетного задания ('
          || ' batchId=' || batchId
          || ').'
        )
      , true
    );
end getBatch;

/* proc: getBatch( batchShortName)
  Возвращает данные пакетного задания.

  Параметры:
  dataRec                     - данные пакетного задания
                                ( возврат)
  batchShortName              - короткое название пакетного задания
*/
procedure getBatch(
  dataRec out nocopy sch_batch%rowtype
  , batchShortName varchar2
)
is
begin
  select
    t.*
  into dataRec
  from
    sch_batch t
  where
    t.batch_short_name = batchShortName
  ;
exception
  when no_data_found then
    raise_application_error(
      pkg_Error.BatchNotFound
      , 'Пакетное задание не найдено ('
        || ' batchShortName="' || batchShortName || '"'
        || ').'
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при получении данных пакетного задания ('
          || ' batchShortName="' || batchShortName || '"'
          || ').'
        )
      , true
    );
end getBatch;

/* func: getLastRootLogId
  Возвращает Id корневого лога последнего запуска пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания

  Возврат:
  Id записи или null, если лог отсутствует.
*/
function getLastRootLogId(
  batchId integer
)
return integer
is

  -- Id коренвой записи лога
  rootLogId integer;

begin
  select
    max( a.root_log_id)
  into rootLogId
  from
    (
    select
      t.log_id as root_log_id
    from
      v_sch_batch_root_log t
    where
      t.message_type_code = 'BSTART'
      and t.batch_id = batchId
    order by
      -- соответствует порядку сортировки в индексе
      -- sch_log_ix_root_batch_date_log
      t.date_ins desc
      , t.log_id desc
    ) a
  where
    rownum <= 1
  ;
  return rootLogId;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при возврате Id корневого лога запуска пакетного задания ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end getLastRootLogId;

/* func: getBatchLogInfo
  Возвращает информацию из лога выполнения пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания
                                ( не используется, если указан rootLogId)
  rootLogId                   - Id корневой записи лога
                                ( по умолчанию лог последнего запуска
                                  указанного пакетного задания)

  Замечания:
  - должен быть задан параметр batchId или rootLogId, иначе выбрасывается
    исключение;
*/
function getBatchLogInfo(
  batchId integer := null
  , rootLogId integer := null
)
return sch_batch_log_info_t
is

  -- Информация из лога
  lgi sch_batch_log_info_t;

  -- Флаг лога с использованием контекста модуля Logging
  isContextLog integer;

begin
  if batchId is null and rootLogId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Должен быть указан Id пакетного задания либо Id корневого лога.'
    );
  end if;

  lgi := sch_batch_log_info_t();
  lgi.root_log_id := rootLogId;
  if lgi.root_log_id is null then
    lgi.root_log_id := getLastRootLogId( batchId => batchId);
  end if;

  if lgi.root_log_id is not null then
    select
      count(*)
    into isContextLog
    from
      lg_log lg
    where
      lg.log_id = lgi.root_log_id
      and lg.context_type_id is not null
    ;
    if isContextLog = 1 then
      select
        min( lg.date_ins) as min_log_date
        , max( lg.date_ins) as max_log_date
        , max(
            case when
              ct.context_type_short_name = Batch_CtxTpSName
              -- результат батча верхнего уровня
              and lg.log_id = ccl.close_log_id
            then
              lg.message_value
            end
          )
          as batch_result_id
        , sum(
            case when
                ct.context_type_short_name = Job_CtxTpSName
                and lg.open_context_flag = 0
                and lg.message_value in ( 3, 4)
              then 1
              else 0
            end
          )
          as error_job_count
        , sum(
            case when
                lg.level_code in (
                  pkg_Logging.Fatal_LevelCode
                  , pkg_Logging.Error_LevelCode
                )
              then 1
              else 0
            end
          )
          as error_count
        , sum(
            case when
                lg.level_code = pkg_Logging.Warn_LevelCode
              then 1
              else 0
            end
          )
          as warning_count
      into
        lgi.min_log_date
        , lgi.max_log_date
        , lgi.batch_result_id
        , lgi.error_job_count
        , lgi.error_count
        , lgi.warning_count
      from
        v_lg_context_change_log ccl
        inner join lg_log lg
          on lg.sessionid = ccl.sessionid
            and lg.log_id >= ccl.open_log_id
            and lg.log_id <= coalesce( ccl.close_log_id, lg.log_id)
        left join lg_context_type ct
          on ct.context_type_id = lg.context_type_id
      where
        ccl.log_id = lgi.root_log_id
      ;
    else
      select
        min( lg.date_ins) as min_log_date
        , max( lg.date_ins) as max_log_date
        , max(
            case when lg.message_type_code = 'BFINISH' and level = 2 then
              lg.message_value
            end
          )
          as batch_result_id
        , sum(
            case when lg.message_type_code = 'JFINISH'
                and lg.message_value in ( 3, 4)
                then 1 else 0
            end
          )
          as error_job_count
        , sum(
            case when lg.message_type_code = 'ERROR'
              then 1 else 0
            end
          )
          as error_count
        , sum(
            case when lg.message_type_code = 'WARNING'
              then 1 else 0
            end
          )
          as warning_count
      into
        lgi.min_log_date
        , lgi.max_log_date
        , lgi.batch_result_id
        , lgi.error_job_count
        , lgi.error_count
        , lgi.warning_count
      from
        sch_log lg
      start with
        lg.log_id = lgi.root_log_id
      connect by
        prior lg.log_id = lg.parent_log_id
      ;
    end if;
  end if;

  return lgi;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при возврате информации из лога выполнения пакетного задания ('
        || ' batchId=' || batchId
        || ', rootLogId=' || rootLogId
        || ').'
      )
    , true
  );
end getBatchLogInfo;

end pkg_SchedulerMain;
/
