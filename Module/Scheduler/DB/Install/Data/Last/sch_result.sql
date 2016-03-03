begin
merge into 
  sch_result d
using  
  (
  select 
    pkg_Scheduler.True_ResultID as result_id
    , 'Положительный результат' as result_name_rus
    , 'True result' as result_name_eng
  from dual
  union all select
    pkg_Scheduler.False_ResultID
    , 'Отрицательный результат'
    , 'False result'
  from dual
  union all select
    pkg_Scheduler.Error_ResultID
    , 'Ошибка'
    , 'Error'
  from dual
  union all select
    pkg_Scheduler.RunError_ResultID
    , 'Ошибка при запуске'
    , 'Run error'
  from dual
  union all select
    pkg_Scheduler.Skip_ResultID
    , 'Пропущен по условию'
    , 'Skip'
  from dual
  union all select
    pkg_Scheduler.RetryAttempt_ResultID
    , 'Повторить попытку'
    , 'Retry attempt'
  from dual
  ) s
on
  (
  d.result_id = s.result_id
  )
when not matched then insert  
  (
  result_id
  , result_name_rus
  , result_name_eng
  )
values
  (
  s.result_id
  , s.result_name_rus
  , s.result_name_eng
  )
when matched then update set
  d.result_name_rus         = s.result_name_rus
  , d.result_name_eng       = s.result_name_eng
;
commit;
end;
/
