-- view: v_mod_source_file
-- �������� ����� �������.
--
create or replace force view
  v_mod_source_file
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  sf.source_file_id
  , md.module_name
  , md.svn_root
  , sf.file_path
  , mp.part_number
  , mp.is_main_part
  , sf.object_name
  , sf.object_type
  , sf.module_id
  , sf.module_part_id
  , sf.date_ins
  , sf.operator_id
from
  mod_source_file sf
  inner join v_mod_module md
    on md.module_id = sf.module_id
  inner join mod_module_part mp
    on mp.module_part_id = sf.module_part_id
/



comment on table v_mod_source_file is
  '�������� ����� ������� [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_source_file.source_file_id is
  'Id ��������� �����'
/
comment on column v_mod_source_file.module_name is
  '�������� ������'
/
comment on column v_mod_source_file.svn_root is
  '���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_source_file.file_path is
  '���� � ��������� �����'
/
comment on column v_mod_source_file.part_number is
  '����� ����� ������ ( ����������, ������� � 1)'
/
comment on column v_mod_source_file.is_main_part is
  '���� �������� ����� ������ ( 1 �������� ����� ������, 0 ��������������)'
/
comment on column v_mod_source_file.object_name is
  '��� ������� ��, �������� ������������� �������� ����'
/
comment on column v_mod_source_file.object_type is
  '��� ������� ��, �������� ������������� �������� ����'
/
comment on column v_mod_source_file.module_id is
  'Id ������'
/
comment on column v_mod_source_file.module_part_id is
  'Id ����� ������'
/
comment on column v_mod_source_file.date_ins is
  '���� ���������� ������'
/
comment on column v_mod_source_file.operator_id is
  'Id ���������, ����������� ������'
/
