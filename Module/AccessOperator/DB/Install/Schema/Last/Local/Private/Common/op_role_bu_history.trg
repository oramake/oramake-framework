-- trigger: op_role_bu_history
-- ������� ��� ������������� �������� ��� ��������� ������ � <op_role>.

create or replace trigger op_role_bu_history
  before update
  on op_role
  for each row
-- op_role_bu_history
begin

  -- ���������� �������� ��������� ���� Id ��������� �� ��� ����� ����
  if not updating( 'change_operator_id') or :new.change_operator_id is null then
    :new.change_operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- ��������� ����� ���������� ������
  :new.change_date := sysdate;

  -- ����������� ������� ����������
  :new.change_number := :old.change_number + 1;
end op_role_bu_history;
/