-- script: Install/Schema/2.7.0/run.sql
-- ���������� �������� ����� �� ������ 2.7.0.
--
-- �������� ���������:
--  - � ���������� ������� <ml_message_ux> ������ ����� sender � recipient
--    ����� �������������� sender_address � recipient_address;
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run ml_message.sql
