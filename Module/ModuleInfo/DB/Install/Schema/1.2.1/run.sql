-- script: Install/Schema/1.2.1/run.sql
-- ���������� �������� ����� �� ������ 1.2.1.
--
-- �������� ���������:
--  - �� ������� <mod_install_type> ������� ���� operator_id, � �����
--    ������ ������� mod_install_type_bi_define;
--

drop trigger
  mod_install_type_bi_define
/

alter table
  mod_install_type
drop column
  operator_id
/
