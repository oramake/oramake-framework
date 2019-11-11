-- view: v_op_login_attempt_group
-- Представление для отображения актуальных данных таблицы <op_login_attempt_group>

create or replace view v_op_login_attempt_group
as
select
  -- Module/AccessOperator
  t.login_attempt_group_id
  , t.login_attempt_group_name
  , t.is_default
  , t.lock_type_code
  , t.max_login_attempt_count
  , t.used_for_cl
  , t.locking_time
  , t.block_wait_period
  , t.change_date
  , t.change_operator_id
  , t.date_ins
  , t.operator_id
from
  op_login_attempt_group t
where
  t.deleted = 0
/


comment on table v_op_login_attempt_group is
  'Представление для отображения актуальных данных таблицы op_login_attempt_group [SVN root: Module/AccessOperator]'
/
comment on column v_op_login_attempt_group.login_attempt_group_id is
  'Идентификатор записи'
/
comment on column v_op_login_attempt_group.login_attempt_group_name is
  'Наименование группы'
/
comment on column v_op_login_attempt_group.is_default is
  'Признак по умолчанию'
/
comment on column v_op_login_attempt_group.lock_type_code is
  'Тип блокировки'
/
comment on column v_op_login_attempt_group.max_login_attempt_count is
  'Максимально допустимое количество попыток входа в систему'
/
comment on column v_op_login_attempt_group.used_for_cl is
  'Признак – "Использовать для CL"'
/
comment on column v_op_login_attempt_group.locking_time is
  'Время блокировки в секундах. Указывается для типа TEMPORAL'
/
comment on column v_op_login_attempt_group.block_wait_period is
  'Количество дней отложенной блокировки оператора при увольнении сотрудника'
/
comment on column v_op_login_attempt_group.change_date is
  'Дата/время последнего изменения'
/
comment on column v_op_login_attempt_group.change_operator_id is
  'Идентификатор оператора, последним изменившего запись'
/
comment on column v_op_login_attempt_group.date_ins is
  'Дата вставки записи'
/
comment on column v_op_login_attempt_group.operator_id is
  'Идентификатор оператора'
/
