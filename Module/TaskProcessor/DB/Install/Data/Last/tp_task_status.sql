begin
merge into 
  tp_task_status d
using  
  (
  select
    pkg_TaskProcessorBase.Idle_TaskStatusCode as task_status_code
    , 'Idle' as task_status_name_eng
    , 'Бездействие' as task_status_name_rus
  from dual
  union all select
    pkg_TaskProcessorBase.Queued_TaskStatusCode
    , 'Queued'
    , 'В очереди'
  from dual
  union all select
    pkg_TaskProcessorBase.Running_TaskStatusCode
    , 'Running'
    , 'Выполняется'
  from dual
  minus
  select
    t.task_status_code
    , t.task_status_name_eng
    , t.task_status_name_rus
  from
    tp_task_status t
  ) s
on
  (
  d.task_status_code = s.task_status_code
  )
when not matched then insert  
  (
  task_status_code
  , task_status_name_eng
  , task_status_name_rus
  )
values
  (
  s.task_status_code
  , s.task_status_name_eng
  , s.task_status_name_rus
  )
when matched then update set
  d.task_status_name_eng          = s.task_status_name_eng
  , d.task_status_name_rus        = s.task_status_name_rus
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
