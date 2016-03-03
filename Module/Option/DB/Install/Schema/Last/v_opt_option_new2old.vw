-- view: v_opt_option_new2old
-- ����������� ��������� � �������� ������������� ���������� �� ����� ������
-- ( opt_option_new, opt_value) � ���������� ���� ( �������� ��������
-- ����������� ������������� v_opt_option).
--
create or replace force view
  v_opt_option_new2old
as
select
  -- SVN root: Oracle/Module/Option
  v.old_option_id as option_id
  , case when vl.prod_value_flag = 0 then
      coalesce( opn.old_option_name_test, opn.option_name || ' (����)')
    else
      opn.option_name
    end
    as option_name
  , opn.old_option_short_name
    || case when vl.prod_value_flag = 0 then
        'Test'
      end
    as option_short_name
  , cast( 1 as number(1)) as is_global
  , cast( null as integer) as link_global_local
  , opn.old_mask_id as mask_id
  , v.date_value as datetime_value
  , v.number_value as integer_value
  , v.string_value
  , v.old_option_value_id as option_value_id
from
  opt_option_new opn
  inner join v_opt_value vl
    on vl.option_id = opn.option_id
      and vl.value_type_code = opn.value_type_code
      and vl.value_list_flag = opn.value_list_flag
      -- ����������� ������� �������� ��� ���������� �� / ��������� ��
      -- �������������� ��� ���������� ��������
      and vl.instance_name is null
      and vl.used_operator_id is null
  inner join
    (
    select
      vlh.value_id
      , vlh.old_option_id
      , max( vlh.value_type_code)
          keep (
            dense_rank last order by
              vlh.change_number
          )
        as value_type_code
      , max( vlh.value_list_flag)
          keep (
            dense_rank last order by
              vlh.change_number
          )
        as value_list_flag
      , max( vlh.date_value)
          keep (
            dense_rank last order by
              vlh.change_number
          )
        as date_value
        -- ���������� �������� ���� ������� � ���������� �������
      , max( round( vlh.number_value, 4))
          keep (
            dense_rank last order by
              vlh.change_number
          )
        as number_value
      , max( vlh.string_value)
          keep (
            dense_rank last order by
              vlh.change_number
          )
        as string_value
      , max( vlh.old_option_value_id)
          keep (
            dense_rank last order by
              vlh.change_number
          )
        as old_option_value_id
    from
      v_opt_value_history vlh
    where
      vlh.old_option_value_del_date is null
      and vlh.deleted = 0
    group by
      vlh.value_id
      , vlh.old_option_id
    ) v
    on v.value_id = vl.value_id
      and v.value_type_code = vl.value_type_code
      and v.value_list_flag = vl.value_list_flag
where
  opn.deleted = 0
/



comment on table v_opt_option_new2old is
  '����������� ��������� � �������� ������������� ���������� �� ����� ������ ( opt_option_new, opt_value) � ���������� ���� ( �������� �������� ����������� ������������� v_opt_option) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_option_new2old.option_id is
  'Id ��������� � ������� opt_option'
/
comment on column v_opt_option_new2old.option_name is
  '�������� ��������� � ������� opt_option'
/
comment on column v_opt_option_new2old.option_short_name is
  '�������� �������� ��������� � ������� opt_option'
/
comment on column v_opt_option_new2old.is_global is
  '���������� ����, �� ������������'
/
comment on column v_opt_option_new2old.link_global_local is
  '���������� ����, �� ������������'
/
comment on column v_opt_option_new2old.mask_id is
  'Id ����� ��� �������� ���������'
/
comment on column v_opt_option_new2old.datetime_value is
  '�������� ��������� ���� ����'
/
comment on column v_opt_option_new2old.integer_value is
  '�������� �������� ���������'
/
comment on column v_opt_option_new2old.string_value is
  '��������� �������� ���������'
/
comment on column v_opt_option_new2old.option_value_id is
  'Id �������� � ������� opt_option_value'
/
