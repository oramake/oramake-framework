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
  , d.oracle_job_id
  , d.nls_language
  , d.nls_territory
  , d.retrial_number
  , d.date_ins
  , d.operator_id
  , d.job
  , d.last_date
  , d.this_date
  , d.next_date
  , d.total_time
  , d.failures
  , d.is_job_broken
  , d.sid
  , d.serial#
  , d.log_data.root_log_id as root_log_id
  , d.log_data.min_log_date as last_start_date
  , d.log_data.max_log_date as last_log_date
  , d.log_data.batch_result_id as batch_result_id
  , d.log_data.error_job_count as error_job_count
  , d.log_data.error_count as error_count
  , d.log_data.warning_count as warning_count
  , (
      case when d.sid is not null then
        sysdate - d.this_date
      else
        d.log_data.max_log_date - d.log_data.min_log_date
      end
    ) * 86400
    as duration_second
from
  (
  select
    d.*
    , pkg_SchedulerMain.getBatchLogInfo(d.batch_id) as log_data
  from
    (
    select
      b.*
      , to_char(b.batch_id) as job
      , j.last_start_date as last_date
      , to_date(null) as this_date
      , j.next_run_date as next_date
      , null as total_time
      , j.failure_count as failures
      , null as is_job_broken
      , ss.sid as sid
      , ss.serial# as serial#
    from
      sch_batch b
      left outer join user_scheduler_jobs j
        -- pkg_Scheduler.getOracleJobName
        on j.job_name = 'Scheduler:' || to_char(batch_id)
      left outer join
        (
        select /*+ordered*/
          jr.job_name
          , ss.sid
          , ss.serial#
        from
          user_scheduler_job_run_details jr
          inner join v$session ss
            on jr.session_id = ss.sid
        ) ss
        on ss.job_name = 'Scheduler:' || to_char(batch_id)
    ) d
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

comment on column v_sch_batch.oracle_job_id is 'ID задания Oracle (dba_jobs.job), созданного для выполнения пакета'
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

comment on column v_sch_batch.job is 'ID существующего задания Oracle (dba_jobs.job), используемого для выполнения пакета'
/

comment on column v_sch_batch.last_date is 'Дата предыдущего запуска задания Oracle'
/

comment on column v_sch_batch.this_date is 'Дата текущего запуска задания Oracle (если выполняется в данный момент)'
/

comment on column v_sch_batch.next_date is 'Дата следующего запуска задания Oracle'
/

comment on column v_sch_batch.total_time is 'Суммарное время выполнения задания Oracle (в секундах)'
/

comment on column v_sch_batch.failures is 'Число неудачных попыток запуска задания Oracle'
/

comment on column v_sch_batch.is_job_broken is 'Флаг того, что назначенное задание Oracle неработоспособно или не существует (1 или null)'
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
