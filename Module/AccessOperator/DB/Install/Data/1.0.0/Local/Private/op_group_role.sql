--script: op_group_role.sql
--Привязка ролей для входа в консультантский и админский интерфейс к круппам "Консультанты скоринга" и "Администраторы"
BEGIN
merge into
  op_group_role d
using
  (
  select
    1062 as role_id
    , 1001 as group_id
  from dual
  union all
  select
    1063 as role_id
    , 1000 as group_id
  from dual
  ) s
on
  (
  d.group_id = s.group_id
 and d.role_id = s.role_id
  )
when not matched then insert
  (
  role_id
  , group_id
  )
values
  (
  s.role_id
  , s.group_id
  )
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
commit;
end;
/

