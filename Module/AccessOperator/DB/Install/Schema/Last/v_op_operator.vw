-- view: v_op_operator
-- Операторы.
create or replace view v_op_operator
as
select
  -- SVN root: Oracle/Module/AccessOperator
  operator_id
  , login
  , password
  , date_begin
  , date_finish
  , operator_name
  , operator_name_en
  , operator_comment
  , operator_id_ins
  , date_ins
from
  op_operator op
where
  op.date_finish is null
/

comment on table v_op_operator is
  'Действующие операторы'
/
comment on column v_op_operator.operator_id is
  'Первичный ключ. Идентификатор пользователя'
/
comment on column v_op_operator.login is
  'Логин пользователя'
/
comment on column v_op_operator.password is
  'Хеш пароля пользователя'
/
comment on column v_op_operator.date_begin is
  'Дата начала действия записи'
/
comment on column v_op_operator.date_finish is
  'Дата окончания действия записи'
/
comment on column v_op_operator.operator_name is
  'Наименование пользователя на языке по умолчанию'
/
comment on column v_op_operator.operator_name_en is
  'Наименование пользователя на английском языке'
/
comment on column v_op_operator.operator_comment is
  'Комментарий'
/
comment on column v_op_operator.operator_id_ins is
  'Id пользователя, создавшего запись'
/
comment on column v_op_operator.date_ins is
  'Дата создания записи'
/
