-- script: Install/Schema/2.0.0/run.sql
-- ���������� �������� ����� �� ������ 2.0.0.
--
-- �������� ���������:
--  - ������� ���������� ����������� ��������� � �����������
--    SMTP-���������;
--  - � ������� <ml_message> ��������� ���� incoming_flag,
--    mailbox_delete_date, mailbox_for_delete_flag;
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run opt_option.sql

@oms-run ml_message.sql
