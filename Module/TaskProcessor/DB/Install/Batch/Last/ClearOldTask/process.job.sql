-- �������� ������ �������������� �������
declare

                                        --����� ��������� �������
  nDeleted integer;

begin
  nDeleted := pkg_TaskProcessorUtility.ClearOldTask;
  jobResultMessage := '������� ' || to_char( nDeleted) || ' �������.';
end;