-- script: Install/Schema/Last/Local/Private/Common/run.sql
-- ��������� ��������� ������ �������� ������

@oms-set-indexTablespace.sql


-- ���������� private ����� � public �����

@oms-run op_operator.sql
@oms-run op_role.sql
@oms-run op_group.sql
@oms-run op_operator_role.sql
@oms-run op_operator_group.sql


-- �������� ������

@oms-run op_action_type.tab


-- ���������� ������

@oms-run Install/Data/1.0.0/Local/Private/Main/op_action_type.sql


-- ������� ����������� �����������

@oms-run op_action_type.con
@oms-run op_operator.con
@oms-run op_role.con
@oms-run op_group.con
@oms-run op_operator_role.con
@oms-run op_operator_group.con
@oms-run op_group_role.con

-- ������������������

@oms-run Install/Schema/Last/Local/op_group_seq.sqs
@oms-run Install/Schema/Last/Local/op_operator_seq.sqs
@oms-run Install/Schema/Last/Local/op_password_hist_seq.sqs
@oms-run Install/Schema/Last/Local/op_role_seq.sql
@oms-run op_login_attempt_group_seq.sqs
