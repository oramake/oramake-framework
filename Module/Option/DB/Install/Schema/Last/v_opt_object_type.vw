-- view: v_opt_object_type
-- ���� �������� ( ���������� ������).
--
create or replace force view
  v_opt_object_type
as
select
  -- SVN root: Oracle/Module/Option
  t.object_type_id
  , t.module_id
  , md.module_name
  , t.object_type_short_name
  , t.object_type_name
  , md.svn_root as module_svn_root
  , t.date_ins
  , t.operator_id
from
  opt_object_type t
  inner join v_mod_module md
    on md.module_id = t.module_id
where
  t.deleted = 0
/



comment on table v_opt_object_type is
  '���� �������� ( ���������� ������) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_object_type.object_type_id is
  'Id ���� �������'
/
comment on column v_opt_object_type.module_id is
  'Id ������, � �������� ��������� ��� �������'
/
comment on column v_opt_object_type.module_name is
  '�������� ������, � �������� ��������� ��� �������'
/
comment on column v_opt_object_type.object_type_short_name is
  '�������� �������� ���� ������� ( ���������� � ������ ������)'
/
comment on column v_opt_object_type.object_type_name is
  '�������� ���� �������'
/
comment on column v_opt_object_type.module_svn_root is
  '���� � ��������� �������� ������ � Subversion ( ������� � ����� �����������, ��������: "Oracle/Module/ModuleInfo")'
/
comment on column v_opt_object_type.date_ins is
  '���� ���������� ������'
/
comment on column v_opt_object_type.operator_id is
  'Id ���������, ����������� ������'
/
