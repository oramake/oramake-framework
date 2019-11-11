-- view: v_op_operator_to_lock
-- Представление для выборки операторов для блокирования
-- из удаленных БД

create or replace view v_op_operator_to_lock
as
select
  -- SVN root: Module/AccessOperator
  op.operator_id
  , op.date_finish
from
  op_operator op
inner join
  op_login_attempt_group grp
on
  op.login_attempt_group_id = grp.login_attempt_group_id
  and grp.lock_type_code != 'UNUSED'
  and op.date_finish is not null
  and op.curr_login_attempt_count > grp.max_login_attempt_count
/

comment on table v_op_operator_to_lock is
  'Представление для выборки операторов для блокирования из удаленных БД'
/
comment on column v_op_operator_to_lock.operator_id is
  'ИД оператора'
/
comment on column v_op_operator_to_lock.date_finish is
  'Дата блокировки оператора'
/
