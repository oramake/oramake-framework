-- script: Install/Schema/2.4.0/run.sql
-- ���������� �������� ����� �� ������ 2.4.0.
--
-- �������� ���������:
--  - �������������� ������� <ml_message>, <ml_attachment>;
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run ml_message-rename.sql
@oms-run Install/Schema/Last/ml_message.tab
@oms-run ml_attachment-rename.sql
@oms-run Install/Schema/Last/ml_attachment.tab
@oms-run Install/Schema/Last/ml_message.con
@oms-run Install/Schema/Last/ml_attachment.con
@oms-run Install/Schema/Last/ml_attachment_bi_define.trg
@oms-run Install/Schema/Last/ml_message_bi_define.trg
