-- script: Install/Schema/3.13.0/Local/Private/Main/run.sql
-- ��������� �������� ������ 3.13.0 ������


-- ������ ��������

@oms-run drop-old-objects.sql


-- ��������

@oms-run Install/Schema/Last/Local/Private/Main/op_group_aiud_add_event.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_aiud_add_event.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_bi_define.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_role_aiud_add_event.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_role_bi_define.trg
