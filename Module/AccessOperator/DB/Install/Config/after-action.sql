-- script: Install/Config/after-action.sql
-- ��������, ����������� ����� ��������� ���������� ������.
--
-- ����������� ��������:
--  - �������� ���������� �������� ������� ���� ������� (� ��������� �������
--    ������������);
--
-- ���������:
--  - ��� �������������� ��������� ������ ( INSTALL_VERSION=Last) ������ ��
--    �����������;
--
begin
  pkg_Operator.setCurrentUserId(1);
end;
/

@oms-resume-batch "%"
