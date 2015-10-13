-- view: v_mod_install_result
-- ���������� �������� �� ��������� �������.
--
create or replace force view
  v_mod_install_result
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  ir.install_result_id
  , ir.install_date
  , md.module_name
  , md.svn_root
  , mp.part_number
  , mp.is_main_part
  , ir.result_version
  , ir.install_type_code
  , ir.object_schema
  , ir.privs_user
  , ir.install_script
  , ir.is_current_version
  , ir.install_user
  , ir.install_version
  , ir.is_full_install
  , ir.is_revert_install
  , ia.module_version
  , ia.host
  , ia.os_user
  , ia.action_goal_list
  , ia.action_option_list
  , ia.svn_path
  , ia.svn_version_info
  , ir.module_id
  , ir.module_part_id
  , ir.install_action_id
  , ir.date_ins
  , ir.operator_id
from
  mod_install_result ir
  inner join v_mod_module md
    on md.module_id = ir.module_id
  inner join mod_module_part mp
    on mp.module_part_id = ir.module_part_id
  left outer join mod_install_action ia
    on ia.install_action_id = ir.install_action_id
/



comment on table v_mod_install_result is
  '���������� �������� �� ��������� ������� [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_install_result.install_result_id is
  'Id ���������� ���������'
/
comment on column v_mod_install_result.install_date is
  '���� ���������'
/
comment on column v_mod_install_result.module_name is
  '�������� ������'
/
comment on column v_mod_install_result.svn_root is
  '���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_install_result.part_number is
  '����� ����� ������ ( ����������, ������� � 1)'
/
comment on column v_mod_install_result.is_main_part is
  '���� �������� ����� ������ ( 1 �������� ����� ������, 0 ��������������)'
/
comment on column v_mod_install_result.result_version is
  '������, ������������ ���������� ���������� ��������� ( ���������� �� install_version � ������ ���������� ������ ��������� ����������, null � ������ ������ ������ ���������)'
/
comment on column v_mod_install_result.install_type_code is
  '��� ���� ���������'
/
comment on column v_mod_install_result.object_schema is
  '�����, � ������� ����������� ������� ������ ����� ������ ( � ������� ��������)'
/
comment on column v_mod_install_result.privs_user is
  '��� ������������, ��� �������� ����������� ��������� ���� ������� ( � ������� ��������)'
/
comment on column v_mod_install_result.install_script is
  '��������� ������������ ������ ( ����� �������������, ���� ��� ��������� ����� ���� ����������� ������ ������������ ����������� �������, �������� run.sql)'
/
comment on column v_mod_install_result.is_current_version is
  '���� ������� ������ ( 1 �������, ����� 0)'
/
comment on column v_mod_install_result.install_user is
  '��� ������������, ��� ������� ����������� ��������� ( � ������� ��������)'
/
comment on column v_mod_install_result.install_version is
  '��������������� ������'
/
comment on column v_mod_install_result.is_full_install is
  '���� ������ ��������� ( 1 ��� ������ ���������, 0 ��� ��������� ����������)'
/
comment on column v_mod_install_result.is_revert_install is
  '���� ���������� ������ ��������� ������ ( 1 ������ ��������� ������, 0 ��������� ������)'
/
comment on column v_mod_install_result.module_version is
  '������ ������'
/
comment on column v_mod_install_result.host is
  '��� �����, � �������� ����������� ��������'
/
comment on column v_mod_install_result.os_user is
  '��� ������������ ������������ �������, ������������ ��������'
/
comment on column v_mod_install_result.action_goal_list is
  '���� ���������� �������� ( ������ � ��������� � �������� �����������)'
/
comment on column v_mod_install_result.action_option_list is
  '��������� �������� ( ������ � ��������� � �������� �����������)'
/
comment on column v_mod_install_result.svn_path is
  '���� � Subversion, �� �������� ���� �������� ����� ������ ( ������� � ����� �����������)'
/
comment on column v_mod_install_result.svn_version_info is
  '���������� � ������ ������ ������ �� Subversion ( � ������� ������ ������� svnversion)'
/
comment on column v_mod_install_result.module_id is
  'Id ������'
/
comment on column v_mod_install_result.module_part_id is
  'Id ����� ������'
/
comment on column v_mod_install_result.install_action_id is
  'Id �������� �� ��������� ( null ���� ��� ���������� �� ��������)'
/
comment on column v_mod_install_result.date_ins is
  '���� ���������� ������'
/
comment on column v_mod_install_result.operator_id is
  'Id ���������, ����������� ������'
/
