-- trigger: ml_attachment_bi_define
-- ������������� ����� ������� <ml_attachment> ��� ������� ������.
create or replace trigger ml_attachment_bi_define
  before insert
  on ml_attachment
  for each row
begin

  -- ���������� �������� ���������� �����
  if :new.attachment_id is null then
    :new.attachment_id := ml_attachment_seq.nextval;
  end if;

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
