create or replace view v_op_operator_grant_group as
select
  -- SVN root: Module/AccessOperator
  d.operator_id
  , d.group_id
  , d.source_group_id
  , d.date_ins
  , d.operator_id_ins
from
  (
  -- Группы, на котрые оператору явно выдана грант опция
  select
    ogr.operator_id
    , ogr.group_id as group_id
    , null as source_group_id
    , ogr.date_ins
    , ogr.operator_id_ins
  from
    op_operator_group ogr
  where
    ogr.grant_option_flag = 1
  union all
  -- Все группы, для опреаторов-членов группы №1
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
;
