-- script: Install/Schema/3.1.0/run.sql
-- ���������� �������� ����� �� ������ 3.1.0.
--
-- �������� ���������:
--  - � ������� <cmn_database_config> ��������� ���� main_instance_name;
--

alter table
  cmn_database_config
add (
  main_instance_name            varchar2(20)
)
/

comment on column cmn_database_config.main_instance_name is
  '��� ��������� ��������� �� (���� ������, �� �� ��������� ������������ �������� pkg_Common.getInstanceName ������ instance_name; ������� ��� standby ��)'
/
