-- script: Install/Schema/2.3.0/run.sql
-- ���������� �������� ����� �� ������ 2.3.0.
--
-- �������� ���������:
--  - � ������� <ml_message> ��������� ���� retry_send_count
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run ml_message.sql
