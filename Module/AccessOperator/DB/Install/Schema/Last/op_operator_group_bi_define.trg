-- trigger: op_operator_group_bi_define
-- ������������� ����� ������� <op_operator_group> ��� ������� ������.
create or replace trigger op_operator_group_bi_define
  before insert
  on op_operator_group
  for each row
begin

  -- Id ���������, ����������� ������
  if :new.operator_id_ins is null then
    :new.operator_id_ins := pkg_Operator.getCurrentUserId();
  end if;

  -- ���������� ���� ���������� ������
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
