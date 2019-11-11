-- trigger: op_login_attempt_group_bi_def.trg
-- ������� �� ���������� ��������� ����� � �������� <op_login_attempt_group>

create or replace trigger op_login_attempt_group_bi_def
before insert on op_login_attempt_group
for each row
begin
  -- ��������� Id ������
  if :new.login_attempt_group_id is null then
    select
      op_login_attempt_group_seq.nextval
    into 
      :new.login_attempt_group_id
    from
      dual
    ;
  end if;

  -- Id ���������, ����������� ������
  if :new.operator_id is null then
    :new.operator_id :=
      coalesce( :new.change_operator_id, pkg_Operator.GetCurrentUserId())
    ;
  end if;

  -- ���������� ����� �������� ������
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;

  -- ������ ����������� �� ���������
  if :new.deleted is null then
    :new.deleted := 0;
  end if;

  -- ���������� ����� ��������� ������.
  if :new.change_date is null then
    :new.change_date := :new.date_ins;
  end if;

  -- ��������, ���������� ������
  if :new.change_operator_id is null then
    :new.change_operator_id := :new.operator_id;
  end if;
  
end op_login_attempt_group_bi_def;
/