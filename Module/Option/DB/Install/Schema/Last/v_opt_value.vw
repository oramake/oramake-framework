-- view: v_opt_value
-- �������� ����������� ���������� ( ���������� ������).
create or replace force view
  v_opt_value
as
select
  -- SVN root: Oracle/Module/Option
  t.value_id
  , t.option_id
  , t.prod_value_flag
  , t.instance_name
  , t.used_operator_id
  , t.value_type_code
  , case when t.list_separator is not null then 1 else 0 end
    as value_list_flag
  , t.list_separator
  , t.encryption_flag
  , t.storage_value_type_code
  , t.date_value
  , t.number_value
  , t.string_value
  , t.change_number
  , t.change_date
  , t.change_operator_id
  , t.date_ins
  , t.operator_id
from
  opt_value t
where
  t.deleted = 0
/

comment on table v_opt_value is
  '�������� ����������� ���������� ( ���������� ������) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_value.value_id is
  'Id ��������'
/
comment on column v_opt_value.option_id is
  'Id ���������'
/
comment on column v_opt_value.prod_value_flag is
  '���� ������������� �������� ������ � ������������ ( ���� ��������) �� ( 1 ������ � ������������ ��, 0 ������ � �������� ��, null ��� �����������)'
/
comment on column v_opt_value.instance_name is
  '��� ���������� ��, � ������� ����� �������������� �������� ( � ������� ��������, null ��� �����������)'
/
comment on column v_opt_value.used_operator_id is
  'Id ���������, ��� �������� ����� �������������� �������� ( null ��� �����������)'
/
comment on column v_opt_value.value_type_code is
  '��� ���� �������� ���������'
/
comment on column v_opt_value.value_list_flag is
  '���� ������� ��� ��������� ������ �������� ���������� ���� ( 1 ��, 0 ���)'
/
comment on column v_opt_value.list_separator is
  '������, ������������ � �������� ����������� � ������ ��������, ����������� � ���� string_value ( null ���� ������ �� ������������)'
/
comment on column v_opt_value.encryption_flag is
  '���� �������� �������� ��������� � ������������� ���� ( �������� ������ ��� �������� ���������� ����) ( 1 ��, 0 ���)'
/
comment on column v_opt_value.storage_value_type_code is
  '��� ����, ������������� ��� �������� �������� ��������� ( ���������� �� ���� �������� ��������� � ������ ������������� ������ ��������, �.�. ������ �������� � ���� ������)'
/
comment on column v_opt_value.date_value is
  '�������� ��������� ���� ����'
/
comment on column v_opt_value.number_value is
  '�������� �������� ���������'
/
comment on column v_opt_value.string_value is
  '��������� �������� ��������� ( ���� �� ������ �������� � ���� list_separator) ���� ������ �������� � ������������, ��������� � ���� list_separator ( ���� ��� ������). �������� ��������� ���������� ���� �������� � ������ ��� ���������, �������� ���� ���� �������� � ������� "yyyy-mm-dd hh24:mi:ss", ����� �������� � ������� "tm9" � ���������� ������������ �����.'
/
comment on column v_opt_value.change_number is
  '���������� ����� ��������� ������ ( ������� � 1)'
/
comment on column v_opt_value.change_date is
  '���� ��������� ������'
/
comment on column v_opt_value.change_operator_id is
  'Id ���������, ����������� ������'
/
comment on column v_opt_value.date_ins is
  '���� ���������� ������'
/
comment on column v_opt_value.operator_id is
  'Id ���������, ����������� ������'
/
