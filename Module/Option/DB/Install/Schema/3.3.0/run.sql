-- script: Install/Schema/3.3.0/run.sql
-- ���������� �������� ����� �� ������ 3.3.0.
--
-- �������� ���������:
--  - ������� ���������� ������� opt_option_value, opt_option, doc_mask,
--    doc_storage_rule;
--  - ������� opt_option_new ������������� � opt_option;
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run drop-old-object.sql
@oms-run drop-old-column.sql
@oms-run rename-object.sql
