-- view: v_sch_operator_batch
-- Текущее состояние пакетных заданий, доступных оператору ( отбор по
-- read_operator_id).
create or replace force view
  v_sch_operator_batch
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
  , d.root_log_id
  , d.last_start_date
  , d.last_log_date
  , d.batch_result_id
  , d.error_job_count
  , d.error_count
  , d.warning_count
  , d.duration_second
  , d.read_operator_id
from
  (
  select
    b.*
    , bo.operator_id as read_operator_id
  from
    (
    select
      rp.batch_id
      , opr.operator_id
    from
      v_sch_role_privilege rp
      inner join v_op_operator_role opr
        on opr.role_id = rp.role_id
    where
      rp.privilege_code = 'READ'
    group by
      rp.batch_id
      , opr.operator_id
    ) bo
    inner join v_sch_batch b
      on b.batch_id = bo.batch_id
  ) d
/



comment on table v_sch_operator_batch is
  'Текущее состояние пакетных заданий, доступных оператору ( отбор по read_operator_id) [ SVN root: Oracle/Module/Scheduler]'
/
