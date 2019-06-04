-- script: Install/Schema/2.1.0/revert.sql
-- �������� ��������� � �������� �����, ��������� ��� ��������� ������ 2.1.0.
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run Install/Schema/2.1.0/Revert/lg_context_type.sql

@oms-run Install/Schema/2.1.0/Revert/create-lg_message_type.sql
@oms-run Install/Schema/2.1.0/Revert/lg_log.sql
@oms-run Install/Schema/2.1.0/Revert/lg_level.sql

drop view v_lg_current_log
/
