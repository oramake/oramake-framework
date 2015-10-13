-- view: v_fd_middle_name_alias
-- �������� ��� �������� ��������.
create or replace view
  v_fd_middle_name_alias
as
select
  -- SVN root: Oracle/Module/FormatData
  al.alias_type_code
  , al.alias_name
  , al.base_name
  , al.date_ins
  , al.operator_id
from
  fd_alias al
where
  al.alias_type_code = 'MN'
/



comment on table v_fd_middle_name_alias is
  '�������� ��� �������� �������� [ SVN root: Oracle/Module/FormatData]'
/
comment on column v_fd_middle_name_alias.alias_type_code is
  '��� ���� ��������'
/
comment on column v_fd_middle_name_alias.alias_name is
  '�������� ��������'
/
comment on column v_fd_middle_name_alias.base_name is
  '������� �����'
/
comment on column v_fd_middle_name_alias.date_ins is
  '���� ���������� ������'
/
comment on column v_fd_middle_name_alias.operator_id is
  'Id ���������, ����������� ������'
/
