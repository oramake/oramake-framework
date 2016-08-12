-- trigger: op_role_bi_define
-- ������������� ����� ������� <op_role> ��� ������� ������.
create or replace trigger op_role_bi_define
  before insert
  on op_role
  for each row
begin

  -- ���������� �������� ���������� �����
  if :new.role_id is null then
    :new.role_id := op_role_seq.nextval;
  end if;

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
