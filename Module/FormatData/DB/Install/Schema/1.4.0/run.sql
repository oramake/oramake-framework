-- script: Install/Schema/1.4.0/run.sql
-- ���������� �������� ����� �� ������ 1.4.0.
--
-- �������� ���������:
--  - � ������� <fd_alias_type> ���� alias_type_name_rus ������������� �
--    alias_type_name, � ���� operator_id �������;
--  - � ������� <fd_alias> ���� operator_id �������;
--

@oms-run fd_alias_type.sql
@oms-run fd_alias.sql
