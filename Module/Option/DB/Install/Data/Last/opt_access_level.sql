begin
merge into
  opt_access_level d
using
  (
  select
    pkg_OptionMain.Full_AccessLevelCode as access_level_code
    , 'Полный доступ' as access_level_name
  from dual
  union all select
    pkg_OptionMain.Read_AccessLevelCode
    , 'Только для чтения'
  from dual
  union all select
    pkg_OptionMain.Value_AccessLevelCode
    , 'Изменение значения'
  from dual
  minus
  select
    t.access_level_code
    , t.access_level_name
  from
    opt_access_level t
  ) s
on
  (
  d.access_level_code = s.access_level_code
  )
when not matched then insert
  (
  access_level_code
  , access_level_name
  )
values
  (
  s.access_level_code
  , s.access_level_name
  )
when matched then update set
  d.access_level_name            = s.access_level_name
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
