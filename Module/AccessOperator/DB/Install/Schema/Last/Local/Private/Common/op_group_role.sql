-- script: Install/Schema/Last/Local/Private/Main/op_group_role.sql
-- ��������� pivate ����� ������� <op_group_role>

prompt disable all triggers on op_group_role

alter table
  op_group_role
disable all triggers
/


prompt add new columns into op_group_role

alter table
  op_group_role
add
  (
  action_type_code varchar2(20) default 'CREATEGROUPROLE' not null
  , computer_name varchar2(100)
  , ip_address varchar2(15)
  , change_number integer default 1
  , change_date date default sysdate not null
  , change_operator_id integer
  )
/

comment on column op_group_role.action_type_code is
  '��� ���� ��������'
/
comment on column op_group_role.computer_name is
  '��� ����������, � �������� ������������� ��������� ��������'
/
comment on column op_group_role.ip_address is
  'IP ����� ����������, � �������� ������������� ��������� ��������'
/
comment on column op_group_role.change_number is
  '����� ��������� ������'
/
comment on column op_group_role.change_date is
  '���� ���������� ��������� ������'
/
comment on column op_group_role.change_operator_id is
  '�� ���������, ������� ������� ������ ���������'
/

prompt add new constraints on op_group_role

alter table
  op_group_role
add
  constraint op_group_role_ck_chg_nm check ( change_number >= 1)
/


prompt set change_operator_id in op_group_role

update
  op_group_role opr
set
  opr.change_operator_id = opr.operator_id
  , opr.change_date = opr.date_ins
/

commit
/


prompt modify change_operator_id in op_group_role to not null


alter table
  op_group_role
modify
  (
  change_operator_id not null
  )
/


prompt enable all triggers on op_group_role

alter table
  op_group_role
enable all triggers
/
