-- script: Install/Schema/3.10.3/Local/Private/Main/run.sql
-- ��������� �������� ������ 3.10.3 ������


-- ������ ��������

@oms-run drop_object.sql


-- ������

@oms-run ./pkg_OperatorInternal.pks
@oms-run ./pkg_OperatorInternal.pkb


-- ��������

@oms-run Install/Schema/Last/Local/Private/Main/op_role_ai_add_to_admin_group.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_group_ai_add_to_adm_grt_grp.trg
