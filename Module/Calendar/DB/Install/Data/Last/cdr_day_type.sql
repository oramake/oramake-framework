begin
merge into
  cdr_day_type d
using
  (
  select
    pkg_Calendar.PublicHoliday_DayTypeId as day_type_id
    , 'Государственный праздник' as day_type_name
  from dual
  union all select
    pkg_Calendar.WorkingDay_DayTypeId
    , 'Рабочий день'
  from dual
  union all select
    pkg_Calendar.DayOff_DayTypeId
    , 'Выходной день'
  from dual
  minus
  select
    t.day_type_id
    , t.day_type_name
  from
    cdr_day_type t
  ) s
on
  (
  d.day_type_id = s.day_type_id
  )
when not matched then insert
  (
  day_type_id
  , day_type_name
  )
values
  (
  s.day_type_id
  , s.day_type_name
  )
when matched then update set
  d.day_type_name            = s.day_type_name
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
