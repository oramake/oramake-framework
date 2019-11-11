alter table
  op_operator_role
add (
    user_access_flag number(1) default 1 not null
  , grant_option_flag number(1) default 0 not null
  , constraint op_operator_role_ck_access_fl check
      (
        (
          user_access_flag = 1
          and grant_option_flag = 0
        ) or
        (
          user_access_flag = 0
          and grant_option_flag = 1
        ) or
        (
          user_access_flag = 1
          and grant_option_flag = 1
        )
      )
)
/

comment on column op_operator_role.user_access_flag is
  'Признак доступа по роли'
/
comment on column op_operator_role.grant_option_flag is
  'Признак выдачи прав на доступ по роли'
/

alter trigger 
  op_operator_role_bu_history 
disable
/

merge into
  op_operator_role orr
using
  (
  select
    distinct
    ogr.operator_id
    , grr.role_id
  from
    op_operator_group ogr
    inner join op_grant_group ggr
      on ggr.group_id = ogr.group_id
    inner join op_group_role grr
      on grr.group_id = ggr.grant_group_id
  ) src
on
  (
    orr.operator_id = src.operator_id
    and orr.role_id = src.role_id
  )
when matched then
  update set
    orr.grant_option_flag = 1
when not matched then
  insert (
    orr.operator_id
  , orr.role_id
  , orr.date_ins
  , orr.operator_id_ins
  , orr.user_access_flag
  , orr.grant_option_flag
  )
  values (
    src.operator_id
  , src.role_id
  , sysdate
  , 1
  , 0
  , 1
  )
/
commit
/

alter trigger 
  op_operator_role_bu_history 
enable
/
