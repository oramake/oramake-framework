-- trigger: sch_privilege_bi_define
-- ������������� ����� ������� <sch_privilege> ��� ������� ������.
create or replace trigger sch_privilege_bi_define
  before insert
  on sch_privilege
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