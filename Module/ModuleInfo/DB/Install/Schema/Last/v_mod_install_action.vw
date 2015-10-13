-- view: v_mod_install_action
-- �������� �� ��������� �������.
--
create or replace force view
  v_mod_install_action
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  ia.install_action_id
  , ia.host
  , ia.host_process_start_time
  , ia.host_process_id
  , ia.os_user
  , md.module_name
  , md.svn_root
  , ia.module_version
  , ia.install_version
  , ia.action_goal_list
  , ia.action_option_list
  , ia.svn_path
  , ia.svn_version_info
  , ia.module_id
  , ia.date_ins
  , ia.operator_id
from
  mod_install_action ia
  inner join v_mod_module md
    on md.module_id = ia.module_id
/



comment on table v_mod_install_action is
  '�������� �� ��������� ������� [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_install_action.install_action_id is
  'Id �������� �� ���������'
/
comment on column v_mod_install_action.host is
  '��� �����, � �������� ����������� ��������'
/
comment on column v_mod_install_action.host_process_start_time is
  '����� ������ ���������� ��������, � ������� ����������� �������� ( ����������� ��������� ����� �� �����)'
/
comment on column v_mod_install_action.host_process_id is
  '������������� �������� �� �����, � ������� ����������� ��������'
/
comment on column v_mod_install_action.os_user is
  '��� ������������ ������������ �������, ������������ ��������'
/
comment on column v_mod_install_action.module_name is
  '�������� ������'
/
comment on column v_mod_install_action.svn_root is
  '���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_install_action.module_version is
  '������ ������'
/
comment on column v_mod_install_action.install_version is
  '��������������� ������ ������'
/
comment on column v_mod_install_action.action_goal_list is
  '���� ���������� �������� ( ������ � ��������� � �������� �����������)'
/
comment on column v_mod_install_action.action_option_list is
  '��������� �������� ( ������ � ��������� � �������� �����������)'
/
comment on column v_mod_install_action.svn_path is
  '���� � Subversion, �� �������� ���� �������� ����� ������ ( ������� � ����� �����������)'
/
comment on column v_mod_install_action.svn_version_info is
  '���������� � ������ ������ ������ �� Subversion ( � ������� ������ ������� svnversion)'
/
comment on column v_mod_install_action.module_id is
  'Id ������'
/
comment on column v_mod_install_action.date_ins is
  '���� ���������� ������'
/
comment on column v_mod_install_action.operator_id is
  'Id ���������, ����������� ������'
/
