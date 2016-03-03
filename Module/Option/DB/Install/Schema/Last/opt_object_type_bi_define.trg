-- trigger: opt_object_type_bi_define
-- ������������� ����� ������� <opt_object_type> ��� ������� ������.
create or replace trigger opt_object_type_bi_define
  before insert
  on opt_object_type
  for each row
begin

  -- ���������� �������� ���������� �����
  if :new.object_type_id is null then
    select
      opt_object_type_seq.nextval
    into :new.object_type_id
    from
      dual
    ;
  end if;

  -- ������ ����������� �� ���������
  if :new.deleted is null then
    :new.deleted := 0;
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
