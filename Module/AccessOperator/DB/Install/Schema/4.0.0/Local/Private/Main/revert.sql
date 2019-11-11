-- script: Install/Schema/Last/Local/Private/Main/revert.sql
-- �������� ��������� ������ �������� ������

@oms-set-indexTablespace.sql

-- �������

@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/op_load_lock_form_sources_tmp.tab
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/op_operator_waiting_emp_bind.tab
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/rp_action.tab
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/rp_customize_type.tab

-- ������������������

@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/op_oper_waiting_emp_bind_seq.sqs

-- ����������� ����������

@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/op_operator_waiting_emp_bind.con
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/rp_action.con
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/rp_customize_type.con

-- �������������

@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/v_op_operator_waiting_emp_bnd.vw

-- ��������

@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/OP_GRANT_GROUP_AIUD_ADD_EVENT.trg
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/op_group_aiud_add_event.trg
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/op_group_role_aid_add_event.trg
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/op_login_atm_grp_aiu_add_event.trg
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/op_oper_wait_emp_bind_bi_def.trg
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/op_operator_aiud_add_event.trg
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/op_operator_grp_aid_add_event.trg
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/op_role_aiud_add_event.trg
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/rp_action_bi_define.trg
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/rp_customize_type_bi_define.trg

-- ������

@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/pkg_AccessOperatorInternal.pks
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/pkg_AccessOperatorInternal.pkb
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/pkg_ReplicateOperator.pks
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/pkg_ReplicateOperator.pkb
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/pkg_AccessOperator.pks
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/pkg_AccessOperator.pkb

-- ������

@oms-run Install/Data/1.0.0/Local/Private/Main/op_action_type.sql
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/rp_customize_type.sql
@oms-run Install/Schema/4.0.0/Local/Private/Main/Revert/rp_action.sql

