drop table
  op_grant_group
/

delete from
  op_operator_group
where 
  group_id in (
  select 
    group_id
  from
    op_group
  where 
    is_grant_only = 1
)
/

delete from
  op_group_role
where 
  group_id in (
  select 
    group_id
  from
    op_group
  where 
    is_grant_only = 1
)
/

delete from
  op_group
where
  is_grant_only = 1
/
commit
/

alter table
  op_group
drop constraint
  op_group_uk
/

alter table
  op_group
drop (
  is_grant_only
)
/
