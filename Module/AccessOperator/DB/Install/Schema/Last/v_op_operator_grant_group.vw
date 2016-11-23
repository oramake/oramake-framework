--view: OP_PASSWORD_HIST_SEQ.sql
--create or replace view v_op_operator_grant_group
create or replace view v_op_operator_grant_group as
select
  -- SVN root: RusFinanceInfo/Module/AccessOperator
  d.operator_id
  , d.group_id
  , d.source_group_id
  , d.date_ins
  , d.operator_id_ins
from
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
  union all
  select
    ogr.operator_id
    , gr.group_id
    , ogr.group_id as source_group_id
    , ogr.date_ins
    , ogr.operator_id_ins
  from
    op_operator_group ogr
    cross join op_group gr
  where
    ogr.group_id = 1
  ) d
/  
