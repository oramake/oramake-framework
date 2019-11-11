-- trigger: op_action_type_bi_define
-- ������� �� ���������� ��������� ����� � �������� <op_action_type>

create or replace trigger op_action_type_bi_define
before insert on op_action_type
for each row  
-- op_action_type_bi_define
begin
  -- ���������� ����� �������� ������
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
  
  -- Id ���������, ����������� ������
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId();
  end if;  
end op_action_type_bi_define;
/