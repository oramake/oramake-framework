begin
merge into 
  fd_alias_type d
using  
  (
  select
    pkg_FormatBase.FirstName_AliasTypeCode as alias_type_code
    , 'Имя' as alias_type_name_rus
    , 'First name' as alias_type_name_eng
  from dual
  union all select
    pkg_FormatBase.MiddleName_AliasTypeCode
    , 'Отчество'
    , 'Middle name'
  from dual
  union all select
    pkg_FormatBase.NoValue_AliasTypeCode
    , 'Отсутствие значения'
    , 'Absent value'
  from dual
  minus
  select
    t.alias_type_code
    , t.alias_type_name_rus
    , t.alias_type_name_eng
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
  , alias_type_name_rus
  , alias_type_name_eng
  )
values
  (
  s.alias_type_code
  , s.alias_type_name_rus
  , s.alias_type_name_eng
  )
when matched then update set
  d.alias_type_name_rus      = s.alias_type_name_rus
  , d.alias_type_name_eng    = s.alias_type_name_eng
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
