begin
merge into 
  sch_interval_type d
using  
  (
  select 
    pkg_Scheduler.Minute_IntervalTypeCode as interval_type_code
    , '������' as interval_type_name_rus
    , 'Minute' as interval_type_name_eng
  from dual
  union all select
    pkg_Scheduler.Hour_IntervalTypeCode
    , '����'
    , 'Hour'
  from dual
  union all select
    pkg_Scheduler.DayOfMonth_IntervalTypeCode
    , '��� ������'
    , 'Day of month'
  from dual
  union all select
    pkg_Scheduler.Month_IntervalTypeCode
    , '������'
    , 'Month'
  from dual
  union all select
    pkg_Scheduler.DayOfWeek_IntervalTypeCode
    , '��� ������'
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
