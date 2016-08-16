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

@oms-run recreate-option-uk.sql

@oms-run change-tab-comment.sql
@oms-run Install/Schema/Last/opt_option_value_t.typ
