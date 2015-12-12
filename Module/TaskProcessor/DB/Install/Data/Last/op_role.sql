begin
merge into
  op_role d
using
  (
  select
    pkg_TaskProcessorBase.Administrator_RoleName as short_name
    , 'Полный доступ к модулю TaskProcessor' as role_name
    , 'TaskProcessor administrator' as role_name_en
    , 'Полный доступ к модулю TaskProcessor, используемому для организации выполнения заданий прикладных модулей.' as description
  from dual
  minus
  select
    t.role_id
    , t.short_name
    , t.role_name
    , t.role_name_en
    , t.description
  from
    op_role t
  where
    t.short_name = pkg_TaskProcessorBase.Administrator_RoleName
  ) s
on
  (
  d.short_name = s.short_name
  )
when not matched then insert
  (
  role_id
  , short_name
  , role_name
  , role_name_en
  , description
  )
values
  (
  s.role_id
  , s.short_name
  , s.role_name
  , s.role_name_en
  , s.description
  )
when matched then update set
  d.role_name             = s.role_name
  , d.role_name_en        = s.role_name_en
  , d.description         = s.description
;
  dbms_output.put_line( 'changed: ' || sql%rowcount);
  commit;
end;
/
