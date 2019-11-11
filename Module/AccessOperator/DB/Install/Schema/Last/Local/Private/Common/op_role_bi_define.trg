-- trigger: op_role_bi_define
-- ������������� ����� ������� <op_role> ��� ���������� ������.

create or replace trigger op_role_bi_define
  before insert
  on op_role
  for each row
-- op_role_bi_define
begin
  -- ���������� �������� ���������� �����
  if :new.role_id is null then
    select
      op_role_seq.nextval
    into
      :new.role_id
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
end op_role_bi_define;
/