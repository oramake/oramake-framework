-- trigger: op_operator_bi_define
-- ������������� ����� ������� <op_operator> ��� ������� ������.
create or replace trigger op_operator_bi_define
  before insert
  on op_operator
  for each row
begin

  -- ���������� �������� ���������� �����
  if :new.operator_id is null then
    :new.operator_id := op_operator_seq.nextval;
  end if;

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
