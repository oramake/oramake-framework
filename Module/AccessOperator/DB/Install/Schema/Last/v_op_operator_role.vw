-- view: v_op_operator_role
-- Доступ оператора к ролям.
create or replace view v_op_operator_role as
select
  -- SVN root: Oracle/Module/AccessOperator
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
  union all
  select
    ogr.operator_id
    , rl.role_id
    , ogr.group_id as source_group_id
    , ogr.date_ins
    , ogr.operator_id_ins
  from
    op_operator_group ogr
    cross join op_role rl
  where
    ogr.group_id = 1 -- pkg_Operator.FullAccess_GroupId
  ) d
/
comment on table v_op_operator_role is
  'Доступ оператора к ролям [ SVN root: Oracle/Module/AccessOperator]'
/
comment on column v_op_operator_role.operator_id is
  'Id оператора'
/
comment on column v_op_operator_role.role_id is
  'Id роли'
/
comment on column v_op_operator_role.source_group_id is
  'Id группы, через которую выдана роль ( если роль выдана через группу)'
/
comment on column v_op_operator_role.date_ins is
  'Дата выдачи роли / либо дата принадлежности к группе'
/
comment on column v_op_operator_role.operator_id_ins is
  'Id оператора, добавившего запись'
/




