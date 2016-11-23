--view: v_op_operator_grant_role
-- create or replace view v_op_operator_grant_role
create or replace view v_op_operator_grant_role as
select
  -- SVN root: RusFinanceInfo/Module/AccessOperator
  d.operator_id
  , d.role_id
  , d.source_group_id
  , d.date_ins
  , d.operator_id_ins
from
  (
  select
    ogr.operator_id
    , grr.role_id
    , ogr.group_id as source_group_id
    , ogr.date_ins
    , ogr.operator_id_ins
  from
    op_operator_group ogr
    inner join op_group gr
      on gr.group_id = ogr.group_id
    inner join op_group_role grr
      on grr.group_id = ogr.group_id
  where
    (
      ogr.group_id = 1
      or gr.is_grant_only = 1
    )
  ) d
/  
