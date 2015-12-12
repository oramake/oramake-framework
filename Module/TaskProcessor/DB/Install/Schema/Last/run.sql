-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql



-- �������
@oms-run tp_file.tab
@oms-run tp_file_status.tab
@oms-run tp_result.tab
@oms-run tp_task.tab
@oms-run tp_task_log.tab
@oms-run tp_task_status.tab
@oms-run tp_task_type.tab

-- Outline-����������� �����������
@oms-run tp_file.con
@oms-run tp_file_status.con
@oms-run tp_result.con
@oms-run tp_task.con
@oms-run tp_task_log.con
@oms-run tp_task_status.con
@oms-run tp_task_type.con

-- ������������������
@oms-run tp_task_seq.sqs
@oms-run tp_task_log_seq.sqs
@oms-run tp_task_type_seq.sqs
