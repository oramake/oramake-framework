-- view: v_opt_option_value
-- ����������� ��������� � �������� ������������� ����������.
--
create or replace force view
  v_opt_option_value
as
select
  -- SVN root: Oracle/Module/Option
  d.option_id
  , v.value_id
  , md.module_name
  , d.object_short_name
  , ot.object_type_short_name
  , d.option_short_name
  , d.value_type_code
  , v.date_value
  , v.number_value
  , v.string_value
  , v.list_separator
  , d.value_list_flag
  , d.encryption_flag
  , d.test_prod_sensitive_flag
  , d.access_level_code
  , d.option_name
  , d.option_description
  , v.prod_value_flag
  , v.instance_name
  , v.used_operator_id
  , d.module_id
  , md.svn_root as module_svn_root
  , d.object_type_id
  , ot.object_type_name
  , ot.module_id as object_type_module_id
  , ot.module_name as object_type_module_name
  , ot.module_svn_root as object_type_module_svn_root
  , d.change_number as option_change_number
  , d.change_date as option_change_date
  , d.change_operator_id as option_change_operator_id
  , d.date_ins as option_date_ins
  , d.operator_id as option_operator_id
  , v.change_number as value_change_number
  , v.change_date as value_change_date
  , v.change_operator_id as value_change_operator_id
  , v.date_ins as value_date_ins
  , v.operator_id as value_operator_id
from
  v_opt_option d
  inner join v_mod_module md
    on md.module_id = d.module_id
  left outer join v_opt_object_type ot
    on ot.object_type_id = d.object_type_id
  left outer join
    (
    select
      vl.option_id
      , vl.value_type_code
      , vl.value_list_flag
      , max( vl.value_id)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as value_id
      , max( vl.prod_value_flag)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as prod_value_flag
      , max( vl.instance_name)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as instance_name
      , max( vl.used_operator_id)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as used_operator_id
      , max( vl.list_separator)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as list_separator
      , max( vl.date_value)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as date_value
      , max( vl.number_value)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as number_value
      , max( vl.string_value)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as string_value
      , max( vl.change_number)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as change_number
      , max( vl.change_date)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as change_date
      , max( vl.change_operator_id)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as change_operator_id
      , max( vl.date_ins)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as date_ins
      , max( vl.operator_id)
          keep (
            dense_rank first order by
              vl.used_operator_id nulls last
              , vl.instance_name nulls last
              , vl.prod_value_flag nulls last
          )
        as operator_id
    from
      v_opt_value vl
      inner join
        (
        select
          max( pkg_Common.isProduction()) as is_production
          , max( upper( pkg_Common.getInstanceName())) as instance_name
          , max( pkg_OptionMain.getCurrentUsedOperatorId()) as used_operator_id
        from
          dual
        ) cfg
        on nullif( vl.prod_value_flag, cfg.is_production) is null
          and nullif( vl.instance_name, cfg.instance_name) is null
          and nullif( vl.used_operator_id, cfg.used_operator_id) is null
    group by
      vl.option_id
      , vl.value_type_code
      , vl.value_list_flag
    ) v
    on v.option_id = d.option_id
      and v.value_type_code = d.value_type_code
      and v.value_list_flag = d.value_list_flag
/


comment on table v_opt_option_value is
  '����������� ��������� � �������� ������������� ���������� [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_option_value.option_id is
  'Id ���������'
/
comment on column v_opt_option_value.value_id is
  'Id �������� ( null ��� ���������� ����������� ��������)'
/
comment on column v_opt_option_value.module_name is
  '������������ ������, � �������� ��������� ��������'
/
comment on column v_opt_option_value.object_short_name is
  '������� ������������ ������� ������ ( ���������� � ������ ������), � �������� ��������� �������� ( null ���� �� ��������� ���������� ���������� �� �������� ���� �������� ��������� �� ����� ������)'
/
comment on column v_opt_option_value.object_type_short_name is
  '������� ������������ ���� �������'
/
comment on column v_opt_option_value.option_short_name is
  '������� ������������ ��������� ( ���������� � ������ ������ ���� � ������ ������� ������, ���� ��������� ���� object_short_name)'
/
comment on column v_opt_option_value.value_type_code is
  '��� ���� �������� ���������'
/
comment on column v_opt_option_value.date_value is
  '�������� ��������� ���� ����'
/
comment on column v_opt_option_value.number_value is
  '�������� �������� ���������'
/
comment on column v_opt_option_value.string_value is
  '��������� �������� ��������� ( ���� �� ������ �������� � ���� list_separator) ���� ������ �������� � ������������, ��������� � ���� list_separator ( ���� ��� ������). �������� ��������� ���������� ���� �������� � ������ ��� ���������, �������� ���� ���� �������� � ������� "yyyy-mm-dd hh24:mi:ss", ����� �������� � ������� "tm9" � ���������� ������������ �����.'
/
comment on column v_opt_option_value.list_separator is
  '������, ������������ � �������� ����������� � ������ ��������, ����������� � ���� string_value ( null ���� ������ �� ������������)'
/
comment on column v_opt_option_value.value_list_flag is
  '���� ������� ��� ��������� ������ �������� ���������� ���� ( 1 ��, 0 ���)'
/
comment on column v_opt_option_value.encryption_flag is
  '���� �������� �������� ��������� � ������������� ���� ( �������� ������ ��� �������� ���������� ����) ( 1 ��, 0 ���)'
/
comment on column v_opt_option_value.test_prod_sensitive_flag is
  '���� �������� ��� �������� ��������� ���� ���� ������ ( �������� ��� ������������), ��� �������� ��� ������������� ( 1 ��, 0 ���)'
/
comment on column v_opt_option_value.access_level_code is
  '��� ������ ������� � ��������� ����� ���������������� ���������'
/
comment on column v_opt_option_value.option_name is
  '������������ ���������'
/
comment on column v_opt_option_value.option_description is
  '�������� ���������'
/
comment on column v_opt_option_value.prod_value_flag is
  '���� ������������� �������� ������ � ������������ ( ���� ��������) �� ( 1 ������ � ������������ ��, 0 ������ � �������� ��, null ��� �����������)'
/
comment on column v_opt_option_value.instance_name is
  '��� ���������� ��, � ������� ����� �������������� �������� ( � ������� ��������, null ��� �����������)'
/
comment on column v_opt_option_value.used_operator_id is
  'Id ���������, ��� �������� ����� �������������� �������� ( null ��� �����������)'
/
comment on column v_opt_option_value.module_id is
  'Id ������, � �������� ��������� ��������'
/
comment on column v_opt_option_value.module_svn_root is
  '������: ���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_opt_option_value.object_type_id is
  'Id ���� �������'
/
comment on column v_opt_option_value.object_type_name is
  '������������ ���� �������'
/
comment on column v_opt_option_value.object_type_module_id is
  '������ ���� �������: Id ������'
/
comment on column v_opt_option_value.object_type_module_name is
  '������ ���� �������: ������������ ������'
/
comment on column v_opt_option_value.object_type_module_svn_root is
  '������ ���� �������: ���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_opt_option_value.option_change_number is
  '��������: ���������� ����� ��������� ������ ( ������� � 1)'
/
comment on column v_opt_option_value.option_change_date is
  '��������: ���� ��������� ������'
/
comment on column v_opt_option_value.option_change_operator_id is
  '��������: Id ���������, ����������� ������'
/
comment on column v_opt_option_value.option_date_ins is
  '��������: ���� ���������� ������'
/
comment on column v_opt_option_value.option_operator_id is
  '��������: Id ���������, ����������� ������'
/
comment on column v_opt_option_value.value_change_number is
  '��������: ���������� ����� ��������� ������ ( ������� � 1)'
/
comment on column v_opt_option_value.value_change_date is
  '��������: ���� ��������� ������'
/
comment on column v_opt_option_value.value_change_operator_id is
  '��������: Id ���������, ����������� ������'
/
comment on column v_opt_option_value.value_date_ins is
  '��������: ���� ���������� ������'
/
comment on column v_opt_option_value.value_operator_id is
  '��������: Id ���������, ����������� ������'
/
