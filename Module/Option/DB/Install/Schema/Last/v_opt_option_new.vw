-- view: v_opt_option_new
-- ����������� ��������� ����������� ������� ( ���������� ������).
create or replace force view
  v_opt_option_new
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
  opt_option_new t
where
  t.deleted = 0
/

comment on table v_opt_option_new is
  '����������� ��������� ����������� ������� ( ���������� ������) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_option_new.option_id is
  'Id ���������'
/
comment on column v_opt_option_new.module_id is
  'Id ������, � �������� ��������� ��������'
/
comment on column v_opt_option_new.object_short_name is
  '�������� �������� ������� ������ ( ���������� � ������ ������), � �������� ��������� �������� ( null ���� �� ��������� ���������� ���������� �� �������� ���� �������� ��������� �� ����� ������)'
/
comment on column v_opt_option_new.object_type_id is
  'Id ���� �������'
/
comment on column v_opt_option_new.option_short_name is
  '�������� �������� ��������� ( ���������� � ������ ������ ���� � ������ ������� ������, ���� ��������� ���� object_short_name)'
/
comment on column v_opt_option_new.value_type_code is
  '��� ���� �������� ���������'
/
comment on column v_opt_option_new.value_list_flag is
  '���� ������� ��� ��������� ������ �������� ���������� ���� ( 1 ��, 0 ���)'
/
comment on column v_opt_option_new.encryption_flag is
  '���� �������� �������� ��������� � ������������� ���� ( �������� ������ ��� �������� ���������� ����) ( 1 ��, 0 ���)'
/
comment on column v_opt_option_new.test_prod_sensitive_flag is
  '���� �������� ��� �������� ��������� ���� ���� ������ ( �������� ��� ������������), ��� �������� ��� ������������� ( 1 ��, 0 ���)'
/
comment on column v_opt_option_new.access_level_code is
  '��� ������ ������� � ��������� ����� ���������������� ���������'
/
comment on column v_opt_option_new.option_name is
  '�������� ���������'
/
comment on column v_opt_option_new.option_description is
  '�������� ���������'
/
comment on column v_opt_option_new.change_number is
  '���������� ����� ��������� ������ ( ������� � 1)'
/
comment on column v_opt_option_new.change_date is
  '���� ��������� ������'
/
comment on column v_opt_option_new.change_operator_id is
  'Id ���������, ����������� ������'
/
comment on column v_opt_option_new.date_ins is
  '���� ���������� ������'
/
comment on column v_opt_option_new.operator_id is
  'Id ���������, ����������� ������'
/
