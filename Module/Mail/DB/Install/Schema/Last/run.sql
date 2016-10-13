-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.


-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql


-- �������

@oms-run ml_attachment.tab
@oms-run ml_fetch_request.tab
@oms-run ml_message.tab
@oms-run ml_message_state.tab
@oms-run ml_request_state.tab


-- Outline-����������� �����������

@oms-run ml_attachment.con
@oms-run ml_fetch_request.con
@oms-run ml_message.con
@oms-run ml_message_state.con
@oms-run ml_request_state.con


-- ������������������

@oms-run ml_attachment_seq.sqs
@oms-run ml_fetch_request_seq.sqs
@oms-run ml_message_seq.sqs
