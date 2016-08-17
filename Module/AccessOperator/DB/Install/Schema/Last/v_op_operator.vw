-- view: v_op_operator
-- ���������.
create or replace view v_op_operator
as
select
  -- SVN root: Oracle/Module/AccessOperator
  operator_id
  , login
  , password
  , date_begin
  , date_finish
  , operator_name
  , operator_name_en
  , operator_comment
  , operator_id_ins
  , date_ins
from
  op_operator op
where
  op.date_finish is null
/

comment on table v_op_operator is
  '����������� ���������'
/
comment on column v_op_operator.operator_id is
  '��������� ����. ������������� ������������'
/
comment on column v_op_operator.login is
  '����� ������������'
/
comment on column v_op_operator.password is
  '��� ������ ������������'
/
comment on column v_op_operator.date_begin is
  '���� ������ �������� ������'
/
comment on column v_op_operator.date_finish is
  '���� ��������� �������� ������'
/
comment on column v_op_operator.operator_name is
  '������������ ������������ �� ����� �� ���������'
/
comment on column v_op_operator.operator_name_en is
  '������������ ������������ �� ���������� �����'
/
comment on column v_op_operator.operator_comment is
  '�����������'
/
comment on column v_op_operator.operator_id_ins is
  'Id ������������, ���������� ������'
/
comment on column v_op_operator.date_ins is
  '���� �������� ������'
/
