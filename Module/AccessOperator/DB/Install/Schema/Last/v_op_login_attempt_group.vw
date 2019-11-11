-- view: v_op_login_attempt_group
-- ������������� ��� ����������� ���������� ������ ������� <op_login_attempt_group>

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
  '������������� ��� ����������� ���������� ������ ������� op_login_attempt_group [SVN root: Module/AccessOperator]'
/
comment on column v_op_login_attempt_group.login_attempt_group_id is
  '������������� ������'
/
comment on column v_op_login_attempt_group.login_attempt_group_name is
  '������������ ������'
/
comment on column v_op_login_attempt_group.is_default is
  '������� �� ���������'
/
comment on column v_op_login_attempt_group.lock_type_code is
  '��� ����������'
/
comment on column v_op_login_attempt_group.max_login_attempt_count is
  '����������� ���������� ���������� ������� ����� � �������'
/
comment on column v_op_login_attempt_group.used_for_cl is
  '������� � "������������ ��� CL"'
/
comment on column v_op_login_attempt_group.locking_time is
  '����� ���������� � ��������. ����������� ��� ���� TEMPORAL'
/
comment on column v_op_login_attempt_group.block_wait_period is
  '���������� ���� ���������� ���������� ��������� ��� ���������� ����������'
/
comment on column v_op_login_attempt_group.change_date is
  '����/����� ���������� ���������'
/
comment on column v_op_login_attempt_group.change_operator_id is
  '������������� ���������, ��������� ����������� ������'
/
comment on column v_op_login_attempt_group.date_ins is
  '���� ������� ������'
/
comment on column v_op_login_attempt_group.operator_id is
  '������������� ���������'
/
