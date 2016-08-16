-- view: v_opt_option_history
-- ����������� ��������� ����������� ������� ( �������).
create or replace force view
  v_opt_option_history
as
select
  -- SVN root: Oracle/Module/Option
  d.*
from
  (
  select
    h.option_id
    , h.module_id
    , h.object_short_name
    , h.object_type_id
    , h.option_short_name
    , h.value_type_code
    , h.value_list_flag
    , h.encryption_flag
    , h.test_prod_sensitive_flag
    , h.access_level_code
    , h.option_name
    , h.option_description
    , h.deleted
    , h.change_number
    , h.change_date
    , h.change_operator_id
    , h.base_date_ins
    , h.base_operator_id
    , h.option_history_id
    , h.date_ins
    , h.operator_id
  from
    opt_option_history h
  union all
  select
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
    , t.deleted
    , t.change_number
    , t.change_date
    , t.change_operator_id
    , t.date_ins as base_date_ins
    , t.operator_id as base_operator_id
    , cast( null as integer) as option_history_id
    , cast( null as date) date_ins
    , cast( null as integer) operator_id
  from
    opt_option t
  ) d
/

comment on table v_opt_option_history is
  '����������� ��������� ����������� ������� ( �������) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_option_history.option_id is
  'Id ���������'
/
comment on column v_opt_option_history.module_id is
  'Id ������, � �������� ��������� ��������'
/
comment on column v_opt_option_history.object_short_name is
  '������� ������������ ������� ������ ( ���������� � ������ ������), � �������� ��������� �������� ( null ���� �� ��������� ���������� ���������� �� �������� ���� �������� ��������� �� ����� ������)'
/
comment on column v_opt_option_history.object_type_id is
  'Id ���� �������'
/
comment on column v_opt_option_history.option_short_name is
  '������� ������������ ��������� ( ���������� � ������ ������ ���� � ������ ������� ������, ���� ��������� ���� object_short_name)'
/
comment on column v_opt_option_history.value_type_code is
  '��� ���� �������� ���������'
/
comment on column v_opt_option_history.value_list_flag is
  '���� ������� ��� ��������� ������ �������� ���������� ���� ( 1 ��, 0 ���)'
/
comment on column v_opt_option_history.encryption_flag is
  '���� �������� �������� ��������� � ������������� ���� ( �������� ������ ��� �������� ���������� ����) ( 1 ��, 0 ���)'
/
comment on column v_opt_option_history.test_prod_sensitive_flag is
  '���� �������� ��� �������� ��������� ���� ���� ������ ( �������� ��� ������������), ��� �������� ��� ������������� ( 1 ��, 0 ���)'
/
comment on column v_opt_option_history.access_level_code is
  '��� ������ ������� � ��������� ����� ���������������� ���������'
/
comment on column v_opt_option_history.option_name is
  '������������ ���������'
/
comment on column v_opt_option_history.option_description is
  '�������� ���������'
/
comment on column v_opt_option_history.deleted is
  '���� ����������� �������� ������ ( 0 - ������������, 1 - �������)'
/
comment on column v_opt_option_history.change_number is
  '���������� ����� ��������� ������ ( ������� � 1)'
/
comment on column v_opt_option_history.change_date is
  '���� ��������� ������'
/
comment on column v_opt_option_history.change_operator_id is
  'Id ���������, ����������� ������'
/
comment on column v_opt_option_history.base_date_ins is
  '���� ���������� ������ � �������� �������'
/
comment on column v_opt_option_history.base_operator_id is
  'Id ���������, ����������� ������ � �������� �������'
/
comment on column v_opt_option_history.option_history_id is
  'Id ������������ ������'
/
comment on column v_opt_option_history.date_ins is
  '���� ���������� ������������ ������'
/
comment on column v_opt_option_history.operator_id is
  'Id ���������, ����������� ������������ ������'
/
