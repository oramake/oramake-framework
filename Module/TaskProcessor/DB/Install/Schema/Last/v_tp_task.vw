-- view: v_tp_task
-- «адани€ ( интерфейсное представление).
create or replace force view v_tp_task
as
select
  -- SVN root: Oracle/Module/TaskProcessor
  ts.task_id
  , ts.task_type_id
  , ts.task_status_code
  , ts.next_start_date
  , ts.sid
  , ts.serial#
  , ts.start_number
  , ts.start_date
  , ts.finish_date
  , case when ts.sid is not null then
      sysdate - ts.start_date
    else
      ts.finish_date - ts.start_date
    end
    * 86400
    as duration_second
  , ts.result_code
  , ts.exec_result
  , ts.error_code
  , ts.error_message
  , ts.manage_date
  , ts.manage_operator_id
  , ts.date_ins
  , ts.operator_id
from
  tp_task ts
/



comment on table v_tp_task is
  '«адани€ ( интерфейсное представление) [ SVN root: Oracle/Module/TaskProcessor]'
;
comment on column v_tp_task.task_id is
  'Id задани€'
;
comment on column v_tp_task.task_type_id is
  'Id типа задани€'
;
comment on column v_tp_task.task_status_code is
  ' од состо€ни€ задани€'
;
comment on column v_tp_task.next_start_date is
  'ƒата следующего запуска ( если задание стоит в очереди)'
;
comment on column v_tp_task.sid is
  'sid сессии, в которой выполн€етс€ задание ( из v$session)'
;
comment on column v_tp_task.serial# is
  'serial# сессии, в которой выполн€етс€ задание ( из v$session)'
;
comment on column v_tp_task.start_number is
  'Ќомер запуска, начина€ с 1 ( последнего или текущего, если задание выполн€етс€)'
;
comment on column v_tp_task.start_date is
  'ƒата запуска ( последнего или текущего, если задание выполн€етс€)'
;
comment on column v_tp_task.finish_date is
  'ƒата завершени€ выполнени€'
;
comment on column v_tp_task.duration_second is
  'ƒлительность выполнени€ ( в секундах)'
;
comment on column v_tp_task.result_code is
  ' од результата выполнени€'
;
comment on column v_tp_task.exec_result is
  '–езультат выполнени€, возвращенный прикладным обработчиком'
;
comment on column v_tp_task.error_code is
  ' од ошибки выполнени€'
;
comment on column v_tp_task.error_message is
  '—ообщение об ошибке выполнени€'
;
comment on column v_tp_task.manage_date is
  'ƒата действи€ по управлению заданием ( создание, постановка на запуск, остановка и т.д.)'
;
comment on column v_tp_task.manage_operator_id is
  'Id оператора, выполнившего действие по управлению заданием'
;
comment on column v_tp_task.date_ins is
  'ƒата добавлени€ записи'
;
comment on column v_tp_task.operator_id is
  'Id оператора, добавившего запись'
;
