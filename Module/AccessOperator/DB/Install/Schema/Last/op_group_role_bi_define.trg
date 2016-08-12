-- trigger: op_group_role_bi_define
-- ������������� ����� ������� <op_group_role> ��� ������� ������.
create or replace trigger op_group_role_bi_define
  before insert
  on op_group_role
  for each row
begin

  -- Id ���������, ����������� ������
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- ���������� ���� ���������� ������
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
