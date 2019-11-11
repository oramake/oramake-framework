-- script: Install/Schema/3.5.0/revert.sql
-- ������ ��������� �������� ������ 3.5.0 ������

-- �������� �������
alter table
  op_operator
disable all triggers
/

alter table
  op_operator
drop
  (
  login_attempt_group_id
  , curr_login_attempt_count
  , last_success_login_date
  )
cascade constraint
/

alter table
  op_operator
enable all triggers
/


-- �������� ������
drop table
  op_lock_type
cascade constraint
/
drop table
  op_login_attempt_group
cascade constraint
/


