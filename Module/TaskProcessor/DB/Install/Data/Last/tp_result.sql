begin
merge into
  tp_result d
using  
  (
  select
    pkg_TaskProcessor.True_ResultCode as result_code
    , 'True result' as result_name_eng
    , 'Положительный результат' as result_name_rus
  from dual
  union all select
    pkg_TaskProcessor.False_ResultCode
    , 'False result'
    , 'Отрицательный результат'
  from dual
  union all select
    pkg_TaskProcessor.Error_ResultCode
    , 'Error'
    , 'Ошибка'
  from dual
  union all select
    pkg_TaskProcessor.Stop_ResultCode
    , 'Stopped'
    , 'Остановлено'
  from dual
  union all select
    pkg_TaskProcessor.Abort_ResultCode
    , 'Aborted'
    , 'Прервано'
  from dual
  minus
  select
    t.result_code
    , t.result_name_eng
    , t.result_name_rus
  from
    tp_result t
  ) s
on
  (
  d.result_code = s.result_code
  )
when not matched then insert  
  (
  result_code
  , result_name_eng
  , result_name_rus
  )
values
  (
  s.result_code
  , s.result_name_eng
  , s.result_name_rus
  )
when matched then update set
  d.result_name_eng          = s.result_name_eng
  , d.result_name_rus        = s.result_name_rus
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
