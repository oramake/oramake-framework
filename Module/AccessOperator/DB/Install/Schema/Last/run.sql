-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.


-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql


-- �������

@oms-run op_grant_group.tab
@oms-run op_group.tab
@oms-run op_group_role.tab
@oms-run op_operator.tab
@oms-run op_operator_group.tab
@oms-run op_operator_role.tab
@oms-run op_password_hist.tab
@oms-run op_role.tab


-- Outline-����������� �����������

@oms-run op_grant_group.con
@oms-run op_group.con
@oms-run op_group_role.con
@oms-run op_operator_group.con
@oms-run op_operator_role.con
@oms-run op_role.con


-- ������������������

@oms-run op_group_seq.sqs
@oms-run op_operator_seq.sqs
@oms-run op_password_hist_seq.sqs
@oms-run op_role_seq.sqs
