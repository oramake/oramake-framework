-- script: oms-save-uninstall-info.sql
-- ��������� � �� ���������� �� ������ ��������� ������ ������ ( ����
-- uninstall).
--
-- ���������:
-- modulePartNumberList       - ������ ������� ������ ������� � ���� ������ �
--                              ������������ ":"
-- uninstallResultVersion     - ����� ������ ������, ���������� � �� �
--                              ���������� ������ ��������� ����������
--
-- ���������:
--  - ������ ������������ ������ OMS;
--  - ��� ���������� �������� ������������ ������
--    <OmsInternal/add-install-result.sql>
--

@&OMS_SCRIPT_DIR/OmsInternal/add-install-result.sql "&1" "" OBJ "" 1 "&2" "" ""
