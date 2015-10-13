-- view: v_mod_install_object
-- ����������������� ������� ��.
--
create or replace force view
  v_mod_install_object
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  a.owner
  , a.object_name
  , a.object_type
  , a.install_date
  , a.source_file_id
  , md.module_name
  , md.svn_root
  , ia.module_version
  , ia.install_version
  , a.file_path 
  , a.module_id
  , a.install_action_id
  , a.install_file_id
  , a.operator_id
from
  (
  select
    inf.install_user as owner
    , sf.object_name
    , sf.object_type
    , max( sf.source_file_id)
      keep ( dense_rank last order by inf.install_file_id)
      as source_file_id
    , max( sf.module_id)
      keep ( dense_rank last order by inf.install_file_id)
      as module_id
    , max( sf.file_path)
      keep ( dense_rank last order by inf.install_file_id)
      as file_path
    , max( inf.install_file_id)
      keep ( dense_rank last order by inf.install_file_id)
      as install_file_id
    , max( inf.install_action_id)
      keep ( dense_rank last order by inf.install_file_id)
      as install_action_id
    , max( inf.start_date)
      keep ( dense_rank last order by inf.install_file_id)
      as install_date
    , max( inf.operator_id)
      keep ( dense_rank last order by inf.install_file_id)
      as operator_id
  from
    mod_source_file sf
    inner join mod_install_file inf
      on inf.source_file_id = sf.source_file_id
  where
    sf.object_name is not null
  group by
    inf.install_user
    , sf.object_name
    , sf.object_type
  ) a
  inner join v_mod_module md
    on md.module_id = a.module_id
  left outer join mod_install_action ia
    on ia.install_action_id = a.install_action_id
      and ia.module_id = a.module_id
/


comment on table v_mod_install_object is
  '����������������� ������� �� [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_install_object.owner is
  '�������� �������'
/
comment on column v_mod_install_object.object_name is
  '��� �������'
/
comment on column v_mod_install_object.object_type is
  '��� �������'
/
comment on column v_mod_install_object.install_date is
  '���� ��������� ���������'
/
comment on column v_mod_install_object.source_file_id is
  'Id ��������� �����'
/
comment on column v_mod_install_object.module_name is
  '�������� ������'
/
comment on column v_mod_install_object.svn_root is
  '���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_install_object.module_version is
  '������ ������'
/
comment on column v_mod_install_object.install_version is
  '��������������� ������ ������'
/
comment on column v_mod_install_object.file_path is
  '���� � ��������� �����'
/
comment on column v_mod_install_object.module_id is
  'Id ������'
/
comment on column v_mod_install_object.install_action_id is
  'Id �������� �� ���������'
/
comment on column v_mod_install_object.install_file_id is
  'Id ������ �� ��������� �����'
/
comment on column v_mod_install_object.operator_id is
  'Id ���������, ����������� ������'
/
