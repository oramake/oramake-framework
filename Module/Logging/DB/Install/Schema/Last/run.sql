-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.


-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql


-- �������

@oms-run lg_context_type.tab
@oms-run lg_destination.tab
@oms-run lg_level.tab
@oms-run lg_log.tab
@oms-run lg_message_type.tab


-- Outline-����������� �����������

@oms-run lg_context_type.con
@oms-run lg_log.con


-- ������������������

@oms-run lg_context_type_seq.sqs
@oms-run lg_log_seq.sqs
