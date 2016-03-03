-- trigger: opt_value_type_bi_define
-- ������������� ����� ������� <opt_value_type> ��� ������� ������.
create or replace trigger opt_value_type_bi_define
  before insert
  on opt_value_type
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
