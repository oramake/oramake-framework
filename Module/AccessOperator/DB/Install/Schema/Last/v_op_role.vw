-- view: v_op_role
-- Роли.
--
create or replace force view
  v_op_role
as
select
  -- SVN root: Module/AccessOperator
  role_id
  , short_name as role_short_name
  , role_name
  , role_name_en
  , description
  , date_ins
  , operator_id
from
  op_role
/


comment on table v_op_role is
  'Роли [ SVN root: Module/AccessOperator]'
/
comment on column v_op_role.role_id is
  'Идентификатор роли'
/
comment on column v_op_role.role_short_name is
  'Краткое наименование роли'
/
comment on column v_op_role.role_name is
  'Наименование роли на языке по умолчанию'
/
comment on column v_op_role.role_name_en is
  'Наименование роли на английском языке'
/
comment on column v_op_role.description is
  'Описание роли на языке по умолчанию'
/
comment on column v_op_role.date_ins is
  'Дата создания записи'
/
comment on column v_op_role.operator_id is
  'Идентификатор оператора, создавшего запись'
/

