-- script: Install/Config/before-action.sql
-- ��������, ����������� ����� ���������� ���������� ������.
--
-- ����������� ��������:
--  - ������������ �������� ������� ���� ������� (� ��������� ���������
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

@oms-stop-batch "%"
