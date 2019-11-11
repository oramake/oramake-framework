alter table
  op_operator_group
add (
    user_access_flag number(1) default 1 not null
  , grant_option_flag number(1) default 0 not null
  , constraint op_operator_group_ck_access_fl check
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

comment on column op_operator_group.user_access_flag is
  'Признак доступа в группе'
/
comment on column op_operator_group.grant_option_flag is
  'Признак выдачи прав на доступ в группе'
/

alter trigger 
  op_operator_group_bu_history 
disable
/

merge into
  op_operator_group og
using
  (
  select
    ogr.operator_id
    , ggr.grant_group_id as group_id
    , ogr.group_id as source_group_id
    , ogr.date_ins
    , ogr.operator_id_ins
  from
    op_operator_group ogr
    inner join op_grant_group ggr
      on ggr.group_id = ogr.group_id
  ) src
on
  (
    og.operator_id = src.operator_id
    and og.group_id = src.group_id
  )
when matched then
  update set
    og.grant_option_flag = 1
when not matched then
  insert (
    og.operator_id
  , og.group_id
  , og.date_ins
  , og.operator_id_ins
  , og.user_access_flag
  , og.grant_option_flag
  )
  values (
    src.operator_id
  , src.group_id
  , src.date_ins
  , src.operator_id_ins
  , 0
  , 1
  )
/
commit
/

alter trigger 
  op_operator_group_bu_history 
enable
/

