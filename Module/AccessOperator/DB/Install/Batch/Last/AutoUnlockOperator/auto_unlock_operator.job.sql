-- �������������� ������������� �������������
declare
  -- ���������� ���������������� ����������
  cnt integer;
begin
  cnt := pkg_AccessOperator.autoUnlockOperator(
    operatorId => pkg_Operator.getCurrentUserId()
  );
  jobResultMessage := '�������������� ����������: ' || to_char( cnt ) || '.';
end;