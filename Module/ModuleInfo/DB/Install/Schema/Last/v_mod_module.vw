-- view: v_mod_module
-- ����������� ������.
--
create or replace force view
  v_mod_module
as
select
  -- SVN root: Oracle/Module/ModuleInfo
  md.module_id
  , case when md.svn_root like '%/Module/_%' then
      substr( md.svn_root, instr( md.svn_root, '/Module/') + 8)
    else
      md.svn_root
    end
    as module_name
  , substr( md.svn_root, 1, instr( md.svn_root, '/') - 1)
    as repository_name
  , md.svn_root
  , md.initial_svn_root
  , md.initial_svn_revision
  , md.date_ins
  , md.operator_id
from
  mod_module md
/



comment on table v_mod_module is
  '����������� ������ [ SVN root: Oracle/Module/ModuleInfo]'
/
comment on column v_mod_module.module_id is
  'Id ������'
/
comment on column v_mod_module.module_name is
  '�������� ������'
/
comment on column v_mod_module.repository_name is
  '�������� �����������, � �������� ��������� ������'
/
comment on column v_mod_module.svn_root is
  '���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_mod_module.initial_svn_root is
  '�������������� ���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ����� ���������� �� svn_root � ������ �������������� ������ ��� �������� � ������ �����������)'
/
comment on column v_mod_module.initial_svn_revision is
  '����� ������ � Subversion, � ������� ��� ������ �������������� �������� ������� ������ ( �������� ����� ���� ��������� �� ��������� ���� initial_svn_root ���������� ���������� ���������� ������������ ������������� ������)'
/
comment on column v_mod_module.date_ins is
  '���� ���������� ������'
/
comment on column v_mod_module.operator_id is
  'Id ���������, ����������� ������'
/
