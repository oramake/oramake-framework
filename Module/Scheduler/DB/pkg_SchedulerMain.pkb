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

/* ivar: jobContextTypeId
  Id типа контекста выполнения лога для задания
  ( кэшированное значение).
*/
jobContextTypeId integer;



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

/* ifunc: getLastRootLogId
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
      v_sch_batch_root_log_old t
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
  Возвращает информацию из лога выполнения пакетного задания, используется
  из <v_sch_batch>.

  Параметры:
  batchId                     - Id пакетного задания
*/
function getBatchLogInfo(
  batchId integer
)
return sch_batch_log_info_t
is

  -- Информация из лога
  lgi sch_batch_log_info_t;

begin
  if batchId is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Должен быть указан Id пакетного задания.'
    );
  end if;

  if jobContextTypeId is null then
    -- max для отказоустойчивости (запись должна быть)
    select
      max( ct.context_type_id)
    into jobContextTypeId
    from
      v_mod_module md
      inner join lg_context_type ct
        on ct.module_id = md.module_id
    where
      md.svn_root = Module_SvnRoot
      and ct.context_type_short_name = Job_CtxTpSName
    ;
  end if;

  lgi := sch_batch_log_info_t();

  -- Предполагаем наличие лога выполнения с использованием контекста
  select
    max( a.start_log_id) as root_log_id
    , min( lg.date_ins) as min_log_date
    , max( lg.date_ins) as max_log_date
    , max( a.batch_result_id) as batch_result_id
    , sum(
        case when
            lg.context_type_id = jobContextTypeId
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
    lgi.root_log_id
    , lgi.min_log_date
    , lgi.max_log_date
    , lgi.batch_result_id
    , lgi.error_job_count
    , lgi.error_count
    , lgi.warning_count
  from
    (
    select
      max( bo.sessionid)
          keep( dense_rank last order by bo.start_time_utc, bo.start_log_id)
        as sessionid
      , max( bo.start_log_id)
          keep( dense_rank last order by bo.start_time_utc, bo.start_log_id)
        as start_log_id
      , max( bo.finish_log_id)
          keep( dense_rank last order by bo.start_time_utc, bo.start_log_id)
        as finish_log_id
      , max( bo.result_id)
          keep( dense_rank last order by bo.start_time_utc, bo.start_log_id)
        as batch_result_id
    from
      v_sch_batch_operation bo
    where
      bo.batch_id = batchId
      and bo.batch_operation_label = Exec_BatchMsgLabel
      and bo.execution_level = 1
    ) a
    inner join lg_log lg
      on lg.sessionid = a.sessionid
        and lg.log_id >= a.start_log_id
        and lg.log_id <= coalesce( a.finish_log_id, lg.log_id)
  ;

  -- Ищем в старом логе если не нашли в новом
  if lgi.root_log_id is null then
    lgi.root_log_id := getLastRootLogId( batchId => batchId);
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

  return lgi;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при возврате информации из лога выполнения пакетного задания ('
        || ' batchId=' || batchId
        || ').'
      )
    , true
  );
end getBatchLogInfo;

end pkg_SchedulerMain;
/
