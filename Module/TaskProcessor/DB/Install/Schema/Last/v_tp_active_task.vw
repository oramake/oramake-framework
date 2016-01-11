-- view: v_tp_active_task
-- јктивные задани€.
-- ƒл€ эффективной выборки из представлени€ создан функциональный индекс
-- <tp_task_ix_active>.
create or replace force view v_tp_active_task
as
select /*+ index( a tp_task_ix_active) */
  -- SVN root: Oracle/Module/TaskProcessor
  a.*
from
  (
  select
    case when ts.task_status_code not in ( 'I') then
        coalesce( ts.next_start_date, ts.start_date)
      end
      as start_order_date
    , case when ts.task_status_code not in ( 'I') then
        ts.task_id
      end
      as task_id
    , case when ts.task_status_code not in ( 'I') then
        ts.task_type_id
      end
      as task_type_id
    , case when ts.task_status_code not in ( 'I') then
        ts.task_status_code
      end
      as task_status_code
    , case when ts.task_status_code not in ( 'I') then
        ts.manage_operator_id
      end
      as manage_operator_id
    , case when ts.task_status_code not in ( 'I') then
        ts.sid
      end
      as sid
    , case when ts.task_status_code not in ( 'I') then
        ts.serial#
      end
      as serial#
  from
    tp_task ts
  ) a
where
  a.task_id is not null
/



comment on table v_tp_active_task is
  'јктивные задани€ [ SVN root: Oracle/Module/TaskProcessor]'
/
comment on column v_tp_active_task.start_order_date is
  'ѕор€дкова€ дата запуска ( дата следующего запуска, если задание стоит в очереди или дата текущего запуска, если оно выполн€етс€)'
/
comment on column v_tp_active_task.task_id is
  'Id задани€'
/
comment on column v_tp_active_task.task_type_id is
  'Id типа задани€'
/
comment on column v_tp_active_task.task_status_code is
  ' од состо€ни€ задани€'
/
comment on column v_tp_active_task.manage_operator_id is
  'Id оператора, выполнившего действие по управлению заданием'
/
comment on column v_tp_active_task.sid is
  'sid сессии, в которой выполн€етс€ задание ( из v$session)'
/
comment on column v_tp_active_task.serial# is
  'serial# сессии, в которой выполн€етс€ задание ( из v$session)'
/
