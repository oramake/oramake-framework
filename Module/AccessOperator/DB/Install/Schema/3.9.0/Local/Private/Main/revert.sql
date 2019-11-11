-- script: Install/Schema/3.9.0/Local/Private/Main/revert.sql
-- �������� ������ 3.9.0 �������� ������


-- �������� ������� ������

@oms-drop-foreign-key.sql op_action_type


-- �������� �����

alter table
  op_operator
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
