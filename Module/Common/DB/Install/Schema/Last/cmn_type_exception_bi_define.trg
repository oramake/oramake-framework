-- trigger: cmn_type_exception_bi_define
-- ������������� ����� ������� <cmn_type_exception> ��� ������� ������.

create or replace trigger cmn_type_exception_bi_define
  before insert
  on cmn_type_exception
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
end cmn_type_exception_bi_define;
/