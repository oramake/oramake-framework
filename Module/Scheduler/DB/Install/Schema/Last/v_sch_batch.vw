-- view: v_sch_batch
-- Текущее состояние пакетов.
--
--Замечания:
--duration_second             - длительность последнего выполнения в секундах,
--  для выполняющихся пакетов рассчитывается на основе dba_jobs.this_date и
--  текущей даты, иначе определяется по логу;
--
create or replace force view
  v_sch_batch
as
select
  d.batch_id
  , d.batch_short_name
  , d.module_id
  , d.batch_name_rus
  , d.batch_name_eng
  , d.batch_type_id
  , d.retrial_count
  , d.retrial_timeout
  , d.activated_flag
  , d.nls_language
  , d.nls_territory
  , d.retrial_number
  , d.date_ins
  , d.operator_id
  , d.last_date
  , d.this_date
  , d.next_date
  , d.failures
  , d.sid
  , d.serial#
  , d.session_status
  , d.root_log_id as root_log_id
  , d.min_log_date as last_start_date
  , d.max_log_date as last_log_date
  , d.batch_result_id as batch_result_id
  , d.error_job_count as error_job_count
  , d.error_count as error_count
  , d.warning_count as warning_count
  , case when d.sid is not null then
      extract( SECOND   from d.elapsed_time)
      + extract( MINUTE from d.elapsed_time) * 60
      + extract( HOUR   from d.elapsed_time) * 60 * 60
      + extract( DAY    from d.elapsed_time) * 60 * 60 * 24
    else
      (d.max_log_date - d.min_log_date)
      * 86400
    end as duration_second
  -- TODO: for backward compatability
  , case when
      activated_flag = 1
    then
      batch_id
    end as oracle_job_id
from
  (
  select
    b.*
    , to_char(b.batch_id) as job
    , j.last_start_date as last_date
    , systimestamp - ss.elapsed_time as this_date
    , ss.elapsed_time
    , j.next_run_date as next_date
    , j.failure_count as failures
    , ss.sid as sid
    , ss.serial# as serial#
    , ss.session_status
    -- pkg_SchedulerMain.getBatchLogInfo(d.batch_id)
    , o.root_log_id
    , o.min_log_date
    , o.max_log_date
    , o.batch_result_id
    , o.error_job_count
    , o.error_count
    , o.warning_count
  from
    sch_batch b
    left outer join user_scheduler_jobs j
      -- pkg_Scheduler.getOracleJobName
      on j.job_name = 'SCHEDULER_' || to_char(batch_id)
    left outer join
      (
      select /*+ordered*/
        jr.job_name
        , jr.elapsed_time
        , ss.sid
        , ss.serial#
        , ss.status as session_status
      from
        user_scheduler_running_jobs jr
        inner join v$session ss
          on jr.session_id = ss.sid
      ) ss
      -- pkg_Scheduler.getOracleJobName
      on ss.job_name = 'SCHEDULER_' || to_char(batch_id)
    -- pkg_SchedulerMain.getBatchLogInfo(d.batch_id) 
    left join
      (
      select
        a.batch_id
        , max( a.start_log_id) as root_log_id
        , min( lg.date_ins) as min_log_date
        , max( lg.date_ins) as max_log_date
        , max( a.batch_result_id) as batch_result_id
        , sum(
            case when
                lg.context_type_id =  
                  (
                    -- jobContextTypeId = 2   
                    select
                      max( ct.context_type_id)
                    from
                      v_mod_module md
                      inner join lg_context_type ct
                        on ct.module_id = md.module_id
                    where
                      md.svn_root = 'Oracle/Module/Scheduler' -- Module_SvnRoot
                      and ct.context_type_short_name = 'JOB'  -- Job_CtxTpSName
                  )
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
                  'FATAL'   -- pkg_Logging.Fatal_LevelCode
                  , 'ERROR' -- pkg_Logging.Error_LevelCode
                )
              then 1
              else 0
            end
          )
          as error_count
        , sum(
            case when
                lg.level_code = 'WARN' -- pkg_Logging.Warn_LevelCode
              then 1
              else 0
            end
          )
          as warning_count
      from
        (
        select
          bo.batch_id
          , max( bo.sessionid)
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
          bo.batch_operation_label = 'EXEC' --Exec_BatchMsgLabel
          and bo.execution_level = 1
        group by
          bo.batch_id
        ) a
      inner join lg_log lg
        on lg.sessionid = a.sessionid
        and lg.log_id >= a.start_log_id
        and lg.log_id <= coalesce( a.finish_log_id, lg.log_id)
      group by
        a.batch_id
      ) o
      on
        o.batch_id = b.batch_id
  ) d
/


comment on table v_sch_batch is 'Текущее состояние и результат последнего выполнения неудаленных пакетов заданий'
/

comment on column v_sch_batch.batch_id is 'ID пакета'
/

comment on column v_sch_batch.batch_short_name is 'Короткое имя пакета (уникальное)'
/

comment on column v_sch_batch.module_id is
  'Id модуля, к которому относится пакетно задание ( батч)'
/

comment on column v_sch_batch.batch_type_id is 'ID типа пакета'
/

comment on column v_sch_batch.retrial_count is 'Число попыток повторного выполнения'
/

comment on column v_sch_batch.retrial_timeout is 'Интервал между попытками повторного выполнения (в минутах)'
/

comment on column v_sch_batch.activated_flag is
  'Флаг активированного пакетного задания (1 - активированное, 0 - неактивированное)'
/

comment on column v_sch_batch.nls_language is
  'Значение NLS_LANGUAGE для job ( по-умолчанию "AMERICAN")'
/
comment on column v_sch_batch.nls_territory is
  'Значение NLS_TERRITORY для job ( по-умолчанию берётся из сессии, в котором активирован батч)'
/

comment on column v_sch_batch.retrial_number is 'Порядковый номер очередной попытки повторного выполнения'
/

comment on column v_sch_batch.date_ins is 'Дата создания пакета'
/

comment on column v_sch_batch.operator_id is 'ID оператора, создавшего пакет'
/

comment on column v_sch_batch.last_date is 'Дата предыдущего запуска задания Oracle'
/

comment on column v_sch_batch.this_date is 'Дата текущего запуска задания Oracle (если выполняется в данный момент)'
/

comment on column v_sch_batch.next_date is 'Дата следующего запуска задания Oracle'
/

comment on column v_sch_batch.failures is 'Число неудачных попыток запуска задания Oracle'
/

comment on column v_sch_batch.session_status is
  'Статус сессии выполнения батча'
/

comment on column v_sch_batch.root_log_id is 'ID корневого сообщения лога для последнего запуска пакета'
/

comment on column v_sch_batch.last_start_date is 'Дата последнего (текущего) запуска пакета'
/

comment on column v_sch_batch.last_log_date is 'Дата последнего сообщения в логе, связанного с выполнением пакета'
/

comment on column v_sch_batch.batch_result_id is 'ID результата последнего выполнения пакета (из лога)'
/

comment on column v_sch_batch.error_job_count is 'Число заданий, завершившихся с ошибкой при последнем (текущем) выполнении пакета'
/

comment on column v_sch_batch.error_count is 'Число логгированных сообщений об ошибках при последнем (текущем) выполнении пакета'
/

comment on column v_sch_batch.warning_count is 'Число логгированных предупреждений при последнем (текущем) выполнении пакета'
/

comment on column v_sch_batch.duration_second is 'Длительность последнего (текущего) выполнения пакета'
/
