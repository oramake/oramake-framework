-- script: Install/Schema/5.1.0/run.sql
-- ���������� �������� ����� �� ������ 5.1.0.
--
-- �������� ���������:
--  - ������� ������������� v_sch_batch_root_log, v_sch_batch_root_log_old,
--    v_sch_batch_result, sch_message_type;
--  - ������ ������� sch_log � ������� sch_log_ix_root_batch_date_log,
--    sch_log_ix_root_date_ins;
--

@oms-run drop-old-object.sql
