-- view: v_opt_option_new2old_diff
-- �������� � ������ �� ������� ��������� ����������� ���������� ����� ������
-- ( opt_option_new, opt_value) � ����������� ( opt_option, opt_option_value)
-- ��������� ( ������������� ������ �� ������������� v_opt_option �
-- v_opt_option_new2old).
--
create or replace force view
  v_opt_option_new2old_diff
as
select
  -- SVN root: Oracle/Module/Option
  b.*
from
  (
  select
    'V_OPT_OPTION' as view_name
    , a.*
  from
    (
    select
      t.option_id
      , t.option_name
      , t.option_short_name
      , t.is_global
      , t.link_global_local
      , t.mask_id
      , t.datetime_value
      , t.integer_value
      , t.string_value
      , t.option_value_id
    from
      v_opt_option t
    minus
    select
      t.option_id
      , t.option_name
      , t.option_short_name
      , t.is_global
      , t.link_global_local
      , t.mask_id
      , t.datetime_value
      , t.integer_value
      , t.string_value
      , t.option_value_id
    from
      v_opt_option_new2old t
    ) a
  union all
  select
    'V_OPT_OPTION_NEW2OLD' as view_name
    , a.*
  from
    (
    select
      t.option_id
      , t.option_name
      , t.option_short_name
      , t.is_global
      , t.link_global_local
      , t.mask_id
      , t.datetime_value
      , t.integer_value
      , t.string_value
      , t.option_value_id
    from
      v_opt_option_new2old t
    minus
    select
      t.option_id
      , t.option_name
      , t.option_short_name
      , t.is_global
      , t.link_global_local
      , t.mask_id
      , t.datetime_value
      , t.integer_value
      , t.string_value
      , t.option_value_id
    from
      v_opt_option t
    ) a
  ) b
where
  -- ��������� ��������, ��������� ��������� � ������� SQL*Loader ���������
  -- ������ � ���������� ������� ��� ���������� ���������� �������� �������
  b.option_id >= 0
order by
  2, 1
/



comment on table v_opt_option_new2old_diff is
  '�������� � ������ �� ������� ��������� ����������� ���������� ����� ������ ( opt_option_new, opt_value) � ����������� ( opt_option, opt_option_value) ��������� ( ������������� ������ �� ������������� v_opt_option � v_opt_option_new2old) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_option_new2old_diff.view_name is
  'Id ��������� � ������� opt_option'
/
comment on column v_opt_option_new2old_diff.option_id is
  'Id ��������� � ������� opt_option'
/
comment on column v_opt_option_new2old_diff.option_name is
  '�������� ��������� � ������� opt_option'
/
comment on column v_opt_option_new2old_diff.option_short_name is
  '�������� �������� ��������� � ������� opt_option'
/
comment on column v_opt_option_new2old_diff.is_global is
  '���������� ����, �� ������������'
/
comment on column v_opt_option_new2old_diff.link_global_local is
  '���������� ����, �� ������������'
/
comment on column v_opt_option_new2old_diff.mask_id is
  'Id ����� ��� �������� ���������'
/
comment on column v_opt_option_new2old_diff.datetime_value is
  '�������� ��������� ���� ����'
/
comment on column v_opt_option_new2old_diff.integer_value is
  '�������� �������� ���������'
/
comment on column v_opt_option_new2old_diff.string_value is
  '��������� �������� ���������'
/
comment on column v_opt_option_new2old_diff.option_value_id is
  'Id �������� � ������� opt_option_value'
/
