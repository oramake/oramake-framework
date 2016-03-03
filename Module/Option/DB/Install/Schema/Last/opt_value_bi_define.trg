-- trigger: opt_value_bi_define
-- ������������� ����� ������� <opt_value> ��� ���������� ������.
create or replace trigger opt_value_bi_define
  before insert
  on opt_value
  for each row
begin

  -- ���������� �������� ���������� �����
  if :new.value_id is null then
    select
      opt_option_value_seq.nextval
    into
      :new.value_id
    from
      dual
    ;
  end if;

  -- Id ���������, ����������� ������
  if :new.operator_id is null then
    :new.operator_id :=
      coalesce( :new.change_operator_id, pkg_Operator.getCurrentUserId())
    ;
  end if;

  -- ���������� ���� ���������� ������
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;

  -- ������ ����������� �� ���������
  if :new.deleted is null then
    :new.deleted := 0;
  end if;

  -- ���������� ����� ���������
  if :new.change_number is null then
    :new.change_number := 1;
  end if;

  -- ���������� ����� ��������� ������
  if :new.change_date is null then
    :new.change_date := :new.date_ins;
  end if;

  -- ��������, ���������� ������
  if :new.change_operator_id is null then
    :new.change_operator_id := :new.operator_id;
  end if;
end;
/
