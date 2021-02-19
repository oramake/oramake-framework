-- script: Install/Schema/Last/Local/Private/Common/revert.sql
-- �������� ��������� ������ �������� ������


-- �������� ������� ������

@oms-drop-foreign-key.sql rp_action
@oms-drop-foreign-key.sql rp_customize_type
@oms-drop-foreign-key.sql op_action_type


-- �������� �����

alter table
  op_operator
drop
  (
  change_operator_id
  )
cascade constraint
/

alter table
  op_operator
drop
  (
  action_type_code
  , computer_name
  , ip_address
  , change_number
  , change_date
  )
cascade constraint
/
alter table
  op_role
drop
  (
  change_number
  , change_date
  , change_operator_id
  )
cascade constraint
/
alter table
  op_group
drop
  (
  change_number
  , change_date
  , change_operator_id
  )
cascade constraint
/
alter table
  op_operator_role
drop
  (
  action_type_code
  , computer_name
  , ip_address
  , change_number
  , change_date
  , change_operator_id
  )
cascade constraint
/
alter table
  op_operator_group
drop
  (
  action_type_code
  , computer_name
  , ip_address
  , change_number
  , change_date
  , change_operator_id
  )
cascade constraint
/
alter table
  op_group_role
drop
  (
  action_type_code
  , computer_name
  , ip_address
  , change_number
  , change_date
  , change_operator_id
  )
cascade constraint
/

-- �������� ������

drop table
  op_action_type
cascade constraint
/


-- �������� �������������������

drop sequence
  op_login_attempt_group_seq
/
drop sequence
  op_group_seq
/
drop sequence
  op_operator_seq
/
drop sequence
  op_password_hist_seq
/
drop sequence
  op_role_seq
/
