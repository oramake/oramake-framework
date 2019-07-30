-- view: v_fd_no_value_alias
-- �������� ��� �������������� ��������.
create or replace view
  v_fd_no_value_alias
as
select
  -- SVN root: Oracle/Module/FormatData
  al.alias_type_code
  , al.alias_name
  , al.base_name
  , al.date_ins
from
  fd_alias al
where
  al.alias_type_code = 'NV'
/



comment on table v_fd_no_value_alias is
  '��������, ������������ ��� ��������� ������� ����� �������� [ SVN root: Oracle/Module/FormatData]'
/
comment on column v_fd_no_value_alias.alias_type_code is
  '��� ���� ��������'
/
comment on column v_fd_no_value_alias.alias_name is
  '�������� ��������'
/
comment on column v_fd_no_value_alias.base_name is
  '������� �����'
/
comment on column v_fd_no_value_alias.date_ins is
  '���� ���������� ������'
/
