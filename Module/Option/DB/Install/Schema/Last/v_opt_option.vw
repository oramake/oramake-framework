-- view: v_opt_option
-- ����������� ��������� ����������� ������� ( ���������� ������).
create or replace force view
  v_opt_option
as
select
  -- SVN root: Oracle/Module/Option
  t.option_id
  , t.module_id
  , t.object_short_name
  , t.object_type_id
  , t.option_short_name
  , t.value_type_code
  , t.value_list_flag
  , t.encryption_flag
  , t.test_prod_sensitive_flag
  , t.access_level_code
  , t.option_name
  , t.option_description
  , t.change_number
  , t.change_date
  , t.change_operator_id
  , t.date_ins
  , t.operator_id
from
  opt_option t
where
  t.deleted = 0
/

comment on table v_opt_option is
  '����������� ��������� ����������� ������� ( ���������� ������) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_option.option_id is
  'Id ���������'
/
comment on column v_opt_option.module_id is
  'Id ������, � �������� ��������� ��������'
/
comment on column v_opt_option.object_short_name is
  '�������� �������� ������� ������ ( ���������� � ������ ������), � �������� ��������� �������� ( null ���� �� ��������� ���������� ���������� �� �������� ���� �������� ��������� �� ����� ������)'
/
comment on column v_opt_option.object_type_id is
  'Id ���� �������'
/
comment on column v_opt_option.option_short_name is
  '�������� �������� ��������� ( ���������� � ������ ������ ���� � ������ ������� ������, ���� ��������� ���� object_short_name)'
/
comment on column v_opt_option.value_type_code is
  '��� ���� �������� ���������'
/
comment on column v_opt_option.value_list_flag is
  '���� ������� ��� ��������� ������ �������� ���������� ���� ( 1 ��, 0 ���)'
/
comment on column v_opt_option.encryption_flag is
  '���� �������� �������� ��������� � ������������� ���� ( �������� ������ ��� �������� ���������� ����) ( 1 ��, 0 ���)'
/
comment on column v_opt_option.test_prod_sensitive_flag is
  '���� �������� ��� �������� ��������� ���� ���� ������ ( �������� ��� ������������), ��� �������� ��� ������������� ( 1 ��, 0 ���)'
/
comment on column v_opt_option.access_level_code is
  '��� ������ ������� � ��������� ����� ���������������� ���������'
/
comment on column v_opt_option.option_name is
  '�������� ���������'
/
comment on column v_opt_option.option_description is
  '�������� ���������'
/
comment on column v_opt_option.change_number is
  '���������� ����� ��������� ������ ( ������� � 1)'
/
comment on column v_opt_option.change_date is
  '���� ��������� ������'
/
comment on column v_opt_option.change_operator_id is
  'Id ���������, ����������� ������'
/
comment on column v_opt_option.date_ins is
  '���� ���������� ������'
/
comment on column v_opt_option.operator_id is
  'Id ���������, ����������� ������'
/
