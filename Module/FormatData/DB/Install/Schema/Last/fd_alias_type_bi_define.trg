-- trigger: fd_alias_type_bi_define
-- ������������� ����� ������� <fd_alias_type> ��� ������� ������.
create or replace trigger fd_alias_type_bi_define
  before insert
  on fd_alias_type
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
