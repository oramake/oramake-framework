-- trigger: lg_log_bi_define
-- ������������� ����� ������� <lg_log> ��� ������� ������.
create or replace trigger lg_log_bi_define
  before insert
  on lg_log
  for each row
begin

  -- ���������� �������� ���������� �����
  if :new.log_id is null then
    :new.log_id := lg_log_seq.nextval;
  end if;

  -- Id ���������, ����������� ������
  if :new.operator_id is null then
    :new.operator_id := pkg_LoggingInternal.getCurrentOperatorId();
  end if;

  -- ���������� ���� ���������� ������
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
