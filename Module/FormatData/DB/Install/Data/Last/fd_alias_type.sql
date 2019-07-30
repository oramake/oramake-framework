begin
merge into
  fd_alias_type d
using
  (
  select
    pkg_FormatBase.FirstName_AliasTypeCode as alias_type_code
    , 'Имя' as alias_type_name
  from dual
  union all select
    pkg_FormatBase.MiddleName_AliasTypeCode
    , 'Отчество'
  from dual
  union all select
    pkg_FormatBase.NoValue_AliasTypeCode
    , 'Отсутствие значения'
  from dual
  minus
  select
    t.alias_type_code
    , t.alias_type_name
  from
    fd_alias_type t
  ) s
on
  (
  d.alias_type_code = s.alias_type_code
  )
when not matched then insert
  (
  alias_type_code
  , alias_type_name
  )
values
  (
  s.alias_type_code
  , s.alias_type_name
  )
when matched then update set
  d.alias_type_name      = s.alias_type_name
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
