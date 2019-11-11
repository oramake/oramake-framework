create or replace view v_op_operator_grant_role as
select
  -- SVN root: Module/AccessOperator
  d.operator_id
  , d.role_id
  , d.source_group_id
  , d.date_ins
  , d.operator_id_ins
from
  (
  -- Роли, на котрые оператору явно выдана грант опция
  select
    orr.operator_id
    , orr.role_id
    , null as source_group_id
    , orr.date_ins
    , orr.operator_id_ins
  from
    op_operator_role orr
  where
    orr.grant_option_flag = 1
  union all
  -- Все роли, для опреаторов-членов группы №1
  select
    oog.operator_id
    , r.role_id
    , oog.group_id as source_group_id
    , oog.date_ins
    , oog.operator_id_ins
  from
    op_operator_group oog
    cross join op_role r
  where
    oog.group_id = 1
  ) d
;
