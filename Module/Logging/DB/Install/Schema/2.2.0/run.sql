-- script: Install/Schema/2.2.0/run.sql
-- ���������� �������� ����� �� ������ 2.2.0.
--
-- �������� ���������:
--  - ������� ������� <lg_log_data>, � ������� <lg_log> ��������� ����
--    long_message_text_flag, text_data_flag;
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run lg_log.sql
@oms-run lg_log_data.sql
