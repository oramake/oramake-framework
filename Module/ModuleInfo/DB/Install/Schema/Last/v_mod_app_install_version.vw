-- view: v_mod_app_install_version
-- ������������� ������ ����������.
--
create or replace force view
  v_mod_app_install_version
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  t.app_install_result_id
  , t.install_date
  , t.module_name
  , t.svn_root
  , t.deployment_path
  , t.install_version as current_version
  , t.module_version
  , t.svn_path
  , t.svn_version_info
  , t.module_id
  , t.deployment_id
  , t.date_ins
  , t.operator_id
from
  v_mod_app_install_result t
where
  t.is_current_version = 1
/



comment on table v_mod_app_install_version is
  '������������� ������ ���������� [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_app_install_version.app_install_result_id is
  'Id ���������� ��������� ����������'
/
comment on column v_mod_app_install_version.install_date is
  '���� ���������'
/
comment on column v_mod_app_install_version.module_name is
  '�������� ������'
/
comment on column v_mod_app_install_version.svn_root is
  '���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_app_install_version.deployment_path is
  '���� ��� ������������� ����������'
/
comment on column v_mod_app_install_version.current_version is
  '������� ������ ����������'
/
comment on column v_mod_app_install_version.module_version is
  '������ ������'
/
comment on column v_mod_app_install_version.svn_path is
  '���� � Subversion, �� �������� ���� �������� ����� ������ ( ������� � ����� �����������)'
/
comment on column v_mod_app_install_version.svn_version_info is
  '���������� � ������ ������ ������ �� Subversion ( � ������� ������ ������� svnversion)'
/
comment on column v_mod_app_install_version.module_id is
  'Id ������'
/
comment on column v_mod_app_install_version.deployment_id is
  'Id ��������� ��� ������������� ����������'
/
comment on column v_mod_app_install_version.date_ins is
  '���� ���������� ������'
/
comment on column v_mod_app_install_version.operator_id is
  'Id ���������, ����������� ������'
/
