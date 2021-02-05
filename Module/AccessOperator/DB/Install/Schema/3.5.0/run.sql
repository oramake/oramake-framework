-- script: Install/Schema/3.5.0/run.sql
-- ��������� �������� ������ 3.5.0 ������

@oms-set-indexTablespace.sql

-- �������� ������
@oms-run Install/Schema/Last/op_lock_type.tab
@oms-run Install/Schema/Last/op_login_attempt_group.tab


-- ������ �������
@oms-run Install/Data/1.0.0/op_lock_type.sql
@oms-run Install/Data/3.5.0/Local/Private/Main/op_login_attempt_group.sql
@oms-run op_operator.sql

-- ������� ����������� �����������
@oms-run Install/Schema/Last/op_lock_type.con
@oms-run Install/Schema/Last/op_login_attempt_group.con
@oms-run op_operator.con

-- �������� �������������
@oms-run Install/Schema/Last/v_op_operator.vw
@oms-run Install/Schema/Last/v_op_login_attempt_group.vw
@oms-run Install/Schema/Last/v_op_operator_to_lock.vw

-- �������� �������
@oms-run ./pkg_Operator.pks
@oms-run ./pkg_Operator.pkb
