-- view: v_mod_install_file
-- ����������������� ����� �������.
--
create or replace force view
  v_mod_install_file
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  t.install_file_id
  , t.install_action_id
  , sf.module_name
  , sf.svn_root
  , sf.file_path
  , t.install_user
  , t.run_level
  , t.start_date
  , t.finish_date
  , sf.object_name
  , sf.object_type
  , t.source_file_id
  , t.date_ins
  , t.operator_id
from
  mod_install_file t
  inner join v_mod_source_file sf
    on sf.source_file_id = t.source_file_id
/


comment on table v_mod_install_file is
  '����������������� ����� ������� [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_install_file.install_file_id is
  'Id ������'
/
comment on column v_mod_install_file.install_action_id is
  'Id �������� �� ���������'
/
comment on column v_mod_install_file.module_name is
  '�������� ������'
/
comment on column v_mod_install_file.svn_root is
  '���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_install_file.file_path is
  '���� � ��������� �����'
/
comment on column v_mod_install_file.install_user is
  '��� ������������, ��� ������� ����������� ��������� ( � ������� ��������)'
/
comment on column v_mod_install_file.run_level is
  '������� ����������� ������������ ����� ( 1 ��� ����� �������� ������, 2 ��� ����������� �� ���� ����� � �.�.)'
/
comment on column v_mod_install_file.start_date is
  '���� ������ ��������� �����'
/
comment on column v_mod_install_file.finish_date is
  '���� ���������� ��������� ����� ( null ���� ��� �� ���� ������� ���������)'
/
comment on column v_mod_install_file.object_name is
  '��� ������� ��, �������� ������������� �������� ����'
/
comment on column v_mod_install_file.object_type is
  '��� ������� ��, �������� ������������� �������� ����'
/
comment on column v_mod_install_file.source_file_id is
  'Id ��������� �����'
/
comment on column v_mod_install_file.date_ins is
  '���� ���������� ������'
/
comment on column v_mod_install_file.operator_id is
  'Id ���������, ����������� ������'
/
