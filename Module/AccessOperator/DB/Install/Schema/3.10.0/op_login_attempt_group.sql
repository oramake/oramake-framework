-- script: Install/Schema/3.10.0/op_login_attempt_group.sql
-- ��������� ������� <op_login_attempt_group>

alter table
  op_login_attempt_group
add
  (
  block_wait_period integer
  )
/


comment on column op_login_attempt_group.block_wait_period is
  '���������� ���� ���������� ���������� ��������� ��� ���������� ����������'
/