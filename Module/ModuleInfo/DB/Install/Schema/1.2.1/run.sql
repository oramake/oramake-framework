-- script: Install/Schema/1.2.1/run.sql
-- ���������� �������� ����� �� ������ 1.2.1.
--
-- �������� ���������:
--  - ��������� ������� � ������ �������� �� ������� <mod_install_action>;
--  - �� ������� <mod_install_type> ������� ���� operator_id, � �����
--    ������ ������� mod_install_type_bi_define;
--  - � ������� <mod_app_install_result> ���� java_return_code �������������
--    � status_code;
--

@oms-run mod_install_action.sql
@oms-run mod_install_type.sql
@oms-run mod_app_install_result.sql
