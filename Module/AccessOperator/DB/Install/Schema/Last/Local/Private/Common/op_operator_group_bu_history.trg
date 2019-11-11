-- trigger: op_operator_group_bu_history
-- ������� ��� ������������� �������� ��� ��������� ������ � <op_operator_group>.

create or replace trigger op_operator_group_bu_history
  before update
  on op_operator_group
  for each row
-- op_operator_group_bu_history
begin
  -- ���������� �������� ��������� ���� Id ��������� �� ��� ����� ����
  if not updating( 'change_operator_id') or :new.change_operator_id is null
      then
    :new.change_operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- ��������� ����� ���������� ������
  :new.change_date := sysdate;

  -- ����������� ������� ����������
  :new.change_number := :old.change_number + 1;
end op_operator_group_bu_history;
/