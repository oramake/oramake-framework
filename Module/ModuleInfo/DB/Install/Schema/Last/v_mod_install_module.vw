-- view: v_mod_install_module
-- ������������� ������ ( ����������� ������ ������ �������� �����
-- �������� ������ �������).
--
create or replace force view
  v_mod_install_module
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  t.install_result_id
  , t.module_name
  , t.svn_root
  , t.object_schema as main_object_schema
  , t.current_version
  , t.install_date
  , t.host
  , t.os_user
  , t.svn_path
  , t.svn_version_info
  , t.module_id
  , t.install_action_id
  , t.date_ins
  , t.operator_id
from
  v_mod_install_version t
where
  -- ��������� �������� ����� � ������
  t.install_type_code = 'OBJ'
  and is_main_part = 1
/


comment on table v_mod_install_module is
  '������������� ������ ( ����������� ������ ������ �������� ����� �������� ������ �������) [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_install_module.install_result_id is
  'Id ���������� ���������'
/
comment on column v_mod_install_module.module_name is
  '�������� ������'
/
comment on column v_mod_install_module.svn_root is
  '���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_install_module.main_object_schema is
  '�����, � ������� ����������� ������� �������� ����� ������ ( � ������� ��������)'
/
comment on column v_mod_install_module.current_version is
  '������� ������'
/
comment on column v_mod_install_module.install_date is
  '���� ���������'
/
comment on column v_mod_install_module.host is
  '��� �����, � �������� ����������� ��������'
/
comment on column v_mod_install_module.os_user is
  '��� ������������ ������������ �������, ������������ ��������'
/
comment on column v_mod_install_module.svn_path is
  '���� � Subversion, �� �������� ���� �������� ����� ������ ( ������� � ����� �����������)'
/
comment on column v_mod_install_module.svn_version_info is
  '���������� � ������ ������ ������ �� Subversion ( � ������� ������ ������� svnversion)'
/
comment on column v_mod_install_module.module_id is
  'Id ������'
/
comment on column v_mod_install_module.install_action_id is
  'Id �������� �� ��������� ( null ���� ��� ���������� �� ��������)'
/
comment on column v_mod_install_module.date_ins is
  '���� ���������� ������'
/
comment on column v_mod_install_module.operator_id is
  'Id ���������, ����������� ������'
/
