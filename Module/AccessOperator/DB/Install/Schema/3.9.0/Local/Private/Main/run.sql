-- script: Install/Schema/3.9.0/Local/Private/Main/run.sql
-- ��������� �������� ������ 3.9.0 ������


@oms-set-indexTablespace.sql


-- ���������� private ����� � public �����

@oms-run Install/Schema/Last/Local/Private/Main/op_operator.sql
@oms-run Install/Schema/Last/Local/Private/Main/op_role.sql
@oms-run Install/Schema/Last/Local/Private/Main/op_group.sql
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_role.sql
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_group.sql
@oms-run Install/Schema/Last/Local/Private/Main/op_group_role.sql


-- �������� ������

@oms-run Install/Schema/Last/Local/Private/Main/op_action_type.tab


-- ���������� ������

@oms-run Install/Data/1.0.0/Local/Private/Main/op_action_type.sql


-- ������� ����������� �����������

@oms-run Install/Schema/Last/Local/Private/Main/op_action_type.con
@oms-run Install/Schema/Last/Local/Private/Main/op_operator.con
@oms-run Install/Schema/Last/Local/Private/Main/op_role.con
@oms-run Install/Schema/Last/Local/Private/Main/op_group.con
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_role.con
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_group.con
@oms-run Install/Schema/Last/Local/Private/Main/op_group_role.con


-- ������

@oms-run Local/Private/Main/pkg_AccessOperator.pks


-- �������� �������������� ��������

@oms-run drop_unused_objects.sql


-- ��������

@oms-run Install/Schema/Last/Local/Private/Main/op_action_type_bi_define.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_bi_define.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_bu_history.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_role_bi_define.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_role_bu_history.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_role_aiud_add_event.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_group_bi_define.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_group_bu_history.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_group_aiud_add_event.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_role_bi_define.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_role_bu_history.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_role_aid_add_event.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_group_bi_define.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_group_bu_history.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_grp_aid_add_event.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_group_role_bi_define.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_group_role_bu_history.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_group_role_aid_add_event.trg
