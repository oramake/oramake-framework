-- trigger: tp_file_bi_define
-- ������������� ����� ������� <tp_file> ��� ������� ������.
create or replace trigger tp_file_bi_define
  before insert
  on tp_file
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
