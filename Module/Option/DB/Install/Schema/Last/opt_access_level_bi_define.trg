-- trigger: opt_access_level_bi_define
-- ������������� ����� ������� <opt_access_level> ��� ������� ������.
create or replace trigger opt_access_level_bi_define
  before insert
  on opt_access_level
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
