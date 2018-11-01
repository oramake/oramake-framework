-- script: Install/Schema/2.0.0/run.sql
-- ���������� �������� ����� �� ������ 2.0.0.
--
-- �������� ���������:
--  - ������� ������� <lg_context_type>;
--  - � ������� <lg_log> ��������� ���� sessionid, level_code, message_label,
--    module_name, object_name, module_id, context_level, open_context_flag,
--    context_type_id, context_value_id, open_context_log_id,
--    open_context_log_time, context_type_level;
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run drop-lg_log_ai_save_parent.sql

@oms-run add-sessionid.sql
@oms-run add-level_code.sql
@oms-run add-message_label.sql

@oms-run add-context.sql

-- add module_name, object_name, module_id
@oms-run add-logger-info-cols.sql
