begin
merge into
  opt_value_type d
using
  (
  select
    pkg_OptionMain.Date_ValueTypeCode as value_type_code
    , '����' as value_type_name
  from dual
  union all select
    pkg_OptionMain.Number_ValueTypeCode
    , '�����'
  from dual
  union all select
    pkg_OptionMain.String_ValueTypeCode
    , '������'
  from dual
  minus
  select
    t.value_type_code
    , t.value_type_name
  from
    opt_value_type t
  ) s
on
  (
  d.value_type_code = s.value_type_code
  )
when not matched then insert
  (
  value_type_code
  , value_type_name
  )
values
  (
  s.value_type_code
  , s.value_type_name
  )
when matched then update set
  d.value_type_name            = s.value_type_name
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
