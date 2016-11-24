-- trigger: cdr_day_bi_define
-- ������������� ����� ������� <cdr_day> ��� ������� ������.
create or replace trigger cdr_day_bi_define
  before insert
  on cdr_day
  for each row
begin

  -- �������� ���� � ������
	:new.day := trunc( :new.day);

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
