-- �������������� ������������� �������������
declare
  -- ���������� ���������������� ����������
  cnt integer;
begin
  cnt := pkg_AccessOperator.autoUnlockOperator();
  jobResultMessage := '�������������� ����������: ' || to_char( cnt ) || '.';
end;