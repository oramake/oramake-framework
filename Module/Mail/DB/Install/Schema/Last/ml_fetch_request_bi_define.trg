-- trigger: ml_fetch_request_bi_define
-- ������������� ����� ������� <ml_fetch_request> ��� ������� ������.
create or replace trigger ml_fetch_request_bi_define
  before insert
  on ml_fetch_request
  for each row
begin

  -- ���������� �������� ���������� �����
  if :new.fetch_request_id is null then
    :new.fetch_request_id := ml_fetch_request_seq.nextval;
  end if;

  -- ���������� ���� ���������� ������
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
