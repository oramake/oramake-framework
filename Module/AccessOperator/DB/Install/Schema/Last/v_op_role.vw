-- view: v_op_role
-- ����.
--
create or replace force view
  v_op_role
as
select
  -- SVN root: Module/AccessOperator
  role_id
  , short_name as role_short_name
  , role_name
  , role_name_en
  , description
  , date_ins
  , operator_id
from
  op_role
/


comment on table v_op_role is
  '���� [ SVN root: Module/AccessOperator]'
/
comment on column v_op_role.role_id is
  '������������� ����'
/
comment on column v_op_role.role_short_name is
  '������� ������������ ����'
/
comment on column v_op_role.role_name is
  '������������ ���� �� ����� �� ���������'
/
comment on column v_op_role.role_name_en is
  '������������ ���� �� ���������� �����'
/
comment on column v_op_role.description is
  '�������� ���� �� ����� �� ���������'
/
comment on column v_op_role.date_ins is
  '���� �������� ������'
/
comment on column v_op_role.operator_id is
  '������������� ���������, ���������� ������'
/

