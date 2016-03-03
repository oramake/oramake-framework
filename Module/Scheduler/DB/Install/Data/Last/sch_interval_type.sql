begin
merge into 
  sch_interval_type d
using  
  (
  select 
    pkg_Scheduler.Minute_IntervalTypeCode as interval_type_code
    , 'ћинуты' as interval_type_name_rus
    , 'Minute' as interval_type_name_eng
  from dual
  union all select
    pkg_Scheduler.Hour_IntervalTypeCode
    , '„асы'
    , 'Hour'
  from dual
  union all select
    pkg_Scheduler.DayOfMonth_IntervalTypeCode
    , 'ƒни мес€ца'
    , 'Day of month'
  from dual
  union all select
    pkg_Scheduler.Month_IntervalTypeCode
    , 'ћес€цы'
    , 'Month'
  from dual
  union all select
    pkg_Scheduler.DayOfWeek_IntervalTypeCode
    , 'ƒни недели'
    , 'Day of week'
  from dual
  ) s
on
  (
  d.interval_type_code = s.interval_type_code
  )
when not matched then insert  
  (
  interval_type_code
  , interval_type_name_rus
  , interval_type_name_eng
  )
values
  (
  s.interval_type_code
  , s.interval_type_name_rus
  , s.interval_type_name_eng
  )
when matched then update set
  d.interval_type_name_rus         = s.interval_type_name_rus
  , d.interval_type_name_eng       = s.interval_type_name_eng
;
commit;
end;
/
