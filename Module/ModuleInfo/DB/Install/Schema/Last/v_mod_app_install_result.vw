-- view: v_mod_app_install_result
-- ���������� ��������� ����������.
--
create or replace force view
  v_mod_app_install_result
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  t.app_install_result_id
  , md.module_name
  , md.svn_root
  , dp.deployment_path
  , t.install_date
  , t.install_version
  , t.module_version
  , t.is_current_version
  , t.svn_path
  , t.svn_version_info
  , t.java_return_code
  , t.error_message
  , t.module_id
  , t.deployment_id
  , t.date_ins
  , t.operator_id
from
  mod_app_install_result t
  inner join mod_deployment dp
    on dp.deployment_id = t.deployment_id
  inner join v_mod_module md
    on md.module_id = t.module_id
/



comment on table v_mod_app_install_result is
  '���������� ��������� ���������� [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_app_install_result.app_install_result_id is
  'Id ���������� ��������� ����������'
/
comment on column v_mod_app_install_result.module_name is
  '�������� ������'
/
comment on column v_mod_app_install_result.svn_root is
  '���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_app_install_result.deployment_path is
  '���� ��� ������������� ����������'
/
comment on column v_mod_app_install_result.install_date is
  '���� ���������'
/
comment on column v_mod_app_install_result.install_version is
  '��������������� ������ ����������'
/
comment on column v_mod_app_install_result.module_version is
  '������ ������'
/
comment on column v_mod_app_install_result.is_current_version is
  '���� ������� ������ ( 1 - �������, 0 - ����� ������������� �� �������, null - ��������� �� ���� ������� ���������)'
/
comment on column v_mod_app_install_result.svn_path is
  '���� � Subversion, �� �������� ���� �������� ����� ������ ( ������� � ����� �����������)'
/
comment on column v_mod_app_install_result.svn_version_info is
  '���������� � ������ ������ ������ �� Subversion ( � ������� ������ ������� svnversion)'
/
comment on column v_mod_app_install_result.java_return_code is
  '��� ���������� ���������� ��������� Java-���������� ( 0 �������� ���������� ������)'
/
comment on column v_mod_app_install_result.error_message is
  '����� ��������� �� ������� ��� ���������� ���������'
/
comment on column v_mod_app_install_result.module_id is
  'Id ������'
/
comment on column v_mod_app_install_result.deployment_id is
  'Id ��������� ��� ������������� ����������'
/
comment on column v_mod_app_install_result.date_ins is
  '���� ���������� ������'
/
comment on column v_mod_app_install_result.operator_id is
  'Id ���������, ����������� ������'
/
