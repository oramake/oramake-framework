-- script: Install/Schema/3.10.0/revert.sql
-- �������� ������ 3.10.0 �������� ������


-- �������� ������� ������


-- �������� �����

alter table
  op_login_attempt_group
drop
  (
  block_wait_period
  )
cascade constraint
/

prompt disable all triggers on op_role

alter table
  op_role
disable all triggers
/


prompt drop added columns from op_role

alter table
  op_role
drop
  (
  is_unused
  )
cascade constraint
/

prompt enable all triggers on op_role

alter table
  op_role
enable all triggers
/


prompt disable all triggers on op_group

alter table
  op_group
disable all triggers
/


prompt drop added columns from op_group

alter table
  op_group
drop
  (
  is_unused
  , description
  )
cascade constraint
/

prompt enable all triggers on op_group

alter table
  op_group
enable all triggers
/


-- �������� ������


-- �������� �������������������