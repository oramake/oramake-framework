begin
merge into
  v_op_role d
using
  (
  select
    pkg_TaskProcessorBase.Administrator_RoleName as role_short_name
    , 'Полный доступ к модулю TaskProcessor' as role_name
    , 'TaskProcessor administrator' as role_name_en
    , 'Полный доступ к модулю TaskProcessor, используемому для организации выполнения заданий прикладных модулей.' as description
  from dual
  minus
  select
    t.role_short_name
    , t.role_name
    , t.role_name_en
    , t.description
  from
    v_op_role t
  where
    t.role_short_name = pkg_TaskProcessorBase.Administrator_RoleName
  ) s
on
  (
  d.role_short_name = s.role_short_name
  )
when not matched then insert
  (
  role_id
  , role_short_name
  , role_name
  , role_name_en
  , description
  , operator_id
  )
values
  (
  op_role_seq.nextval
  , s.role_short_name
  , s.role_name
  , s.role_name_en
  , s.description
  , pkg_Operator.getCurrentUserId()
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
