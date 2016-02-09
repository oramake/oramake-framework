-- trigger: ccs_type_exception_bi_define
-- ������������� ����� ������� <ccs_type_exception> ��� ������� ������.

create or replace trigger ccs_type_exception_bi_define
  before insert
  on ccs_type_exception
  for each row
begin

  -- Id ���������, ����������� ������
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId();
  end if;

  -- ���������� ����� �������� ������
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end ccs_type_exception_bi_define;
/
