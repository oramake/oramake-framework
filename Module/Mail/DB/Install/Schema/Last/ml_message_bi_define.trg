-- trigger: ml_message_bi_define
-- ������������� ����� ������� <ml_message> ��� ������� ������.
create or replace trigger ml_message_bi_define
  before insert
  on ml_message
  for each row
begin

  -- ���������� �������� ���������� �����
  if :new.message_id is null then
    :new.message_id := ml_message_seq.nextval;
  end if;

  -- Id ���������, ����������� ������
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- ���������� ���� ���������� ������
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;

  -- ����������� ����� �����������
  :new.sender_address := lower( trim( :new.sender_address));

  -- ����������� ����� ����������
  :new.recipient_address := lower( trim( :new.recipient_address));
end;
/
