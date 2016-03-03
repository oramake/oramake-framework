-- view: v_opt_value_history
-- �������� ����������� ���������� ( �������).
create or replace force view
  v_opt_value_history
as
select
  -- SVN root: Oracle/Module/Option
  d.*
from
  (
  select
    h.value_id
    , h.option_id
    , h.prod_value_flag
    , h.instance_name
    , h.used_operator_id
    , h.value_type_code
    , case when h.list_separator is not null then 1 else 0 end
      as value_list_flag
    , h.list_separator
    , h.encryption_flag
    , h.storage_value_type_code
    , h.date_value
    , h.number_value
    , h.string_value
    , h.old_option_value_id
    , h.old_option_id
    , h.old_option_value_del_date
    , h.old_option_del_date
    , h.deleted
    , h.change_number
    , h.change_date
    , h.change_operator_id
    , h.base_date_ins
    , h.base_operator_id
    , h.value_history_id
    , h.date_ins
    , h.operator_id
  from
    opt_value_history h
  union all
  select
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
    , t.old_option_value_id
    , t.old_option_id
    , t.old_option_value_del_date
    , t.old_option_del_date
    , t.deleted
    , t.change_number
    , t.change_date
    , t.change_operator_id
    , t.date_ins as base_date_ins
    , t.operator_id as base_operator_id
    , cast( null as integer) as value_history_id
    , cast( null as date) date_ins
    , cast( null as integer) operator_id
  from
    opt_value t
  ) d
/

comment on table v_opt_value_history is
  '�������� ����������� ���������� ( �������) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_value_history.value_id is
  'Id ��������'
/
comment on column v_opt_value_history.option_id is
  'Id ���������'
/
comment on column v_opt_value_history.prod_value_flag is
  '���� ������������� �������� ������ � ������������ ( ���� ��������) �� ( 1 ������ � ������������ ��, 0 ������ � �������� ��, null ��� �����������)'
/
comment on column v_opt_value_history.instance_name is
  '��� ���������� ��, � ������� ����� �������������� �������� ( � ������� ��������, null ��� �����������)'
/
comment on column v_opt_value_history.used_operator_id is
  'Id ���������, ��� �������� ����� �������������� �������� ( null ��� �����������)'
/
comment on column v_opt_value_history.value_type_code is
  '��� ���� �������� ���������'
/
comment on column v_opt_value_history.value_list_flag is
  '���� ������� ��� ��������� ������ �������� ���������� ���� ( 1 ��, 0 ���)'
/
comment on column v_opt_value_history.list_separator is
  '������, ������������ � �������� ����������� � ������ ��������, ����������� � ���� string_value ( null ���� ������ �� ������������)'
/
comment on column v_opt_value_history.encryption_flag is
  '���� �������� �������� ��������� � ������������� ���� ( �������� ������ ��� �������� ���������� ����) ( 1 ��, 0 ���)'
/
comment on column v_opt_value_history.storage_value_type_code is
  '��� ����, ������������� ��� �������� �������� ��������� ( ���������� �� ���� �������� ��������� � ������ ������������� ������ ��������, �.�. ������ �������� � ���� ������)'
/
comment on column v_opt_value_history.date_value is
  '�������� ��������� ���� ����'
/
comment on column v_opt_value_history.number_value is
  '�������� �������� ���������'
/
comment on column v_opt_value_history.string_value is
  '��������� �������� ��������� ( ���� �� ������ �������� � ���� list_separator) ���� ������ �������� � ������������, ��������� � ���� list_separator ( ���� ��� ������). �������� ��������� ���������� ���� �������� � ������ ��� ���������, �������� ���� ���� �������� � ������� "yyyy-mm-dd hh24:mi:ss", ����� �������� � ������� "tm9" � ���������� ������������ �����.'
/
comment on column v_opt_value_history.old_option_value_id is
  '���������� ����: Id �������� � ������� opt_option_value'
/
comment on column v_opt_value_history.old_option_id is
  '���������� ����: Id ��������� � ������� opt_option'
/
comment on column v_opt_value_history.old_option_value_del_date is
  '���������� ����: ���� �������� �������� �� ������� opt_option_value'
/
comment on column v_opt_value_history.old_option_del_date is
  '���������� ����: ���� �������� ��������� �� ������� opt_option'
/
comment on column v_opt_value_history.deleted is
  '���� ����������� �������� ������ ( 0 - ������������, 1 - �������)'
/
comment on column v_opt_value_history.change_number is
  '���������� ����� ��������� ������ ( ������� � 1)'
/
comment on column v_opt_value_history.change_date is
  '���� ��������� ������'
/
comment on column v_opt_value_history.change_operator_id is
  'Id ���������, ����������� ������'
/
comment on column v_opt_value_history.base_date_ins is
  '���� ���������� ������ � �������� �������'
/
comment on column v_opt_value_history.base_operator_id is
  'Id ���������, ����������� ������ � �������� �������'
/
comment on column v_opt_value_history.value_history_id is
  'Id ������������ ������'
/
comment on column v_opt_value_history.date_ins is
  '���� ���������� ������������ ������'
/
comment on column v_opt_value_history.operator_id is
  'Id ���������, ����������� ������������ ������'
/
