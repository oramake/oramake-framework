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

declare
  triggerName varchar2(100) := 'OPH_GROUP_BD_HISTORY';
  triggerExists number(1,0);
begin
  select
    count(1)
  into
    triggerExists
  from
    user_triggers
  where
    trigger_name = upper(triggerName)
  ;
  if triggerExists >= 1 then
    execute immediate
'alter trigger ' || triggerName || ' disable';
  else
    pkg_Common.outputMessage('Trigger ' || triggerName || ' does not exist');
  end if;
end;
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


declare
  triggerName varchar2(100) := 'OPH_GROUP_BD_HISTORY';
  triggerExists number(1,0);
begin
  select
    count(1)
  into
    triggerExists
  from
    user_triggers
  where
    trigger_name = upper(triggerName)
  ;
  if triggerExists >= 1 then
    execute immediate
'alter trigger ' || triggerName || ' enable';
  else
    pkg_Common.outputMessage('Trigger ' || triggerName || ' does not exist');
  end if;
end;
/

