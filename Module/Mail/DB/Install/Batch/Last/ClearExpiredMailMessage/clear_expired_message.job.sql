-- �������� �������� ��������� � �������� ������ �����
declare

                                        --����� ��������� ���������
  nDeleted integer;

begin
  nDeleted := pkg_MailHandler.ClearExpiredMessage(
    checkDate => trunc( sysdate)
  );
  jobResultMessage := '������� ' || to_char( nDeleted) || ' ��������(�,�).';
end;