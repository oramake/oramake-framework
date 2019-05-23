-- script: Install/Schema/2.1.0/run.sql
-- ���������� �������� ����� �� ������ 2.1.0.
--
-- �������� ���������:
--  - � ������� <lg_log> ������� ���� parent_log_id � message_type_code, �
--    ���� sessionid, level_code, log_time ������� ������������� (�������
--    ��� ���� �������������);
--  - ������� ������� lg_message_type;
--  - � ������� <lg_context_type> ��������� ���� temporary_use_date;
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run lg_level.sql
@oms-run lg_log.sql
@oms-run drop-lg_message_type.sql

@oms-run lg_context_type.sql
