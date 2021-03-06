--view: v_op_operator_role
-- create or replace view v_op_operator_role
create or replace view v_op_operator_role as
select
  -- SVN root: Module/AccessOperator
  d.operator_id
  , d.role_id
  , d.source_group_id
  , d.date_ins
  , d.operator_id_ins
from
  (
  select
    opr.operator_id
    , opr.role_id
    , cast( null as integer) as source_group_id
    , opr.date_ins
    , opr.operator_id_ins
  from
    op_operator_role opr
  where
    opr.user_access_flag = 1
  union all
  select
    ogr.operator_id
    , grr.role_id
    , ogr.group_id as source_group_id
    , ogr.date_ins
    , ogr.operator_id_ins
  from
    op_operator_group ogr
    inner join op_group_role grr
      on grr.group_id = ogr.group_id
  where
    ogr.user_access_flag = 1
  ) d
/
