-- view: v_mod_install_version
-- ������������� ������ ������ �������.
--
create or replace force view
  v_mod_install_version
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  ir.install_result_id
  , ir.install_date
  , ir.module_name
  , ir.svn_root
  , ir.part_number
  , ir.is_main_part
  , ir.result_version as current_version
  , ir.install_type_code
  , ir.object_schema
  , ir.privs_user
  , ir.install_script
  , ir.host
  , ir.os_user
  , ir.svn_path
  , ir.svn_version_info
  , ir.module_id
  , ir.module_part_id
  , ir.install_action_id
  , ir.date_ins
  , ir.operator_id
from
  v_mod_install_result ir
where
  ir.is_current_version = 1
  and ir.result_version is not null
/


comment on table v_mod_install_version is
  '������������� ������ ������ ������� [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_install_version.install_result_id is
  'Id ���������� ���������'
/
comment on column v_mod_install_version.install_date is
  '���� ���������'
/
comment on column v_mod_install_version.module_name is
  '�������� ������'
/
comment on column v_mod_install_version.svn_root is
  '���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_install_version.part_number is
  '����� ����� ������ ( ����������, ������� � 1)'
/
comment on column v_mod_install_version.is_main_part is
  '���� �������� ����� ������ ( 1 �������� ����� ������, 0 ��������������)'
/
comment on column v_mod_install_version.current_version is
  '������� ������'
/
comment on column v_mod_install_version.install_type_code is
  '��� ���� ���������'
/
comment on column v_mod_install_version.object_schema is
  '�����, � ������� ����������� ������� ������ ����� ������ ( � ������� ��������)'
/
comment on column v_mod_install_version.privs_user is
  '��� ������������, ��� �������� ����������� ��������� ���� ������� ( � ������� ��������)'
/
comment on column v_mod_install_version.install_script is
  '��������� ������������ ������ ( ����� �������������, ���� ��� ��������� ����� ���� ����������� ������ ������������ ����������� �������, �������� run.sql)'
/
comment on column v_mod_install_version.host is
  '��� �����, � �������� ����������� ��������'
/
comment on column v_mod_install_version.os_user is
  '��� ������������ ������������ �������, ������������ ��������'
/
comment on column v_mod_install_version.svn_path is
  '���� � Subversion, �� �������� ���� �������� ����� ������ ( ������� � ����� �����������)'
/
comment on column v_mod_install_version.svn_version_info is
  '���������� � ������ ������ ������ �� Subversion ( � ������� ������ ������� svnversion)'
/
comment on column v_mod_install_version.module_id is
  'Id ������'
/
comment on column v_mod_install_version.module_part_id is
  'Id ����� ������'
/
comment on column v_mod_install_version.install_action_id is
  'Id �������� �� ��������� ( null ���� ��� ���������� �� ��������)'
/
comment on column v_mod_install_version.date_ins is
  '���� ���������� ������'
/
comment on column v_mod_install_version.operator_id is
  'Id ���������, ����������� ������'
/
