-- trigger: ml_message_state_bi_define
-- ������������� ����� ������� <ml_message_state> ��� ������� ������.
create or replace trigger ml_message_state_bi_define
  before insert
  on ml_message_state
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
