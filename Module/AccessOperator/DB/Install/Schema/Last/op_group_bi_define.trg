-- trigger: op_group_bi_define
-- ������������� ����� ������� <op_group> ��� ������� ������.
create or replace trigger op_group_bi_define
  before insert
  on op_group
  for each row
begin

  -- ���������� �������� ���������� �����
  if :new.group_id is null then
    :new.group_id := op_group_seq.nextval;
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
