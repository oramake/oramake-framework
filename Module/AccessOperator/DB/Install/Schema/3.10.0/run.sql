-- script: Install/Schema/3.10.0/Local/Private/Main/run.sql
-- ��������� �������� ������ 3.10.0 ������


@oms-set-indexTablespace.sql



-- ������ ��������

@oms-run op_login_attempt_group.sql
@oms-run op_role.sql
@oms-run op_group.sql


-- �������� �������������

@oms-run Install/Schema/Last/v_op_login_attempt_group.vw
